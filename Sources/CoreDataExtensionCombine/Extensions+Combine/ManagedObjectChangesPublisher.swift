//
//  ManagedObjectChangesPublisher.swift
//  CoreDataDomain
//
//  Created by Amine Bensalah on 20/04/2020.
//  Copyright © 2020 Amine Bensalah. All rights reserved.
//

import Combine
import CoreData
import CoreDataExtension

extension NSManagedObjectContext {
    public func changesPublisher<Object: Persistable>(for fetchRequest: Request<Object>)
        -> ManagedObjectChangesPublisher<Object>
    {
        return ManagedObjectChangesPublisher(
            fetchRequest: fetchRequest.buildFetchRequest(), context: self)
    }

    public func changesPublisher<Object: Persistable>(for fetchRequest: NSFetchRequest<Object>)
        -> ManagedObjectChangesPublisher<Object>
    {
        return ManagedObjectChangesPublisher(fetchRequest: fetchRequest, context: self)
    }
}

public struct ManagedObjectChangesPublisher<Object: Persistable>: Publisher
where Object.DomainType: Equatable {
    public typealias Output = CollectionDifference<Object.DomainType>
    public typealias Failure = Error

    let fetchRequest: NSFetchRequest<Object>
    let context: NSManagedObjectContext

    public init(fetchRequest: NSFetchRequest<Object>, context: NSManagedObjectContext) {
        self.fetchRequest = fetchRequest
        self.context = context
    }

    public func receive<S>(subscriber: S)
    where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let inner = Inner(downstream: subscriber, fetchRequest: fetchRequest, context: context)
        subscriber.receive(subscription: inner)
    }
}

extension ManagedObjectChangesPublisher {
    private final class Inner<Downstream: Subscriber>: NSObject, Subscription,
        NSFetchedResultsControllerDelegate
    where
        Downstream.Input == CollectionDifference<Object.DomainType>, Downstream.Failure == Error,
        Object.DomainType: Equatable
    {

        private let downstream: Downstream
        private var fetchedResultsController: NSFetchedResultsController<Object>?

        init(
            downstream: Downstream, fetchRequest: NSFetchRequest<Object>,
            context: NSManagedObjectContext
        ) {
            self.downstream = downstream
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil)
            super.init()

            guard let fetchedResultsController = fetchedResultsController else { return }
            fetchedResultsController.delegate = self

            do {
                try fetchedResultsController.performFetch()
                updateDiff()
            } catch {
                downstream.receive(completion: .failure(error))
            }
        }

        private var demand: Subscribers.Demand = .none

        func request(_ demand: Subscribers.Demand) {
            self.demand = demand
            fulfillDemand()
        }

        private var lastSentState: [Object.DomainType] = []
        private var currentDifferences = CollectionDifference<Object.DomainType>([])

        private func updateDiff() {
            currentDifferences = Array(fetchedResultsController?.fetchedObjects?.asDomains ?? [])
                .difference(from: lastSentState)
            fulfillDemand()
        }

        private func fulfillDemand() {
            if let currentDifferences = currentDifferences,
                demand > 0 && !currentDifferences.isEmpty
            {
                let newDemand = downstream.receive(currentDifferences)
                lastSentState = Array(fetchedResultsController?.fetchedObjects?.asDomains ?? [])
                self.currentDifferences = lastSentState.difference(from: lastSentState)

                demand += newDemand
                demand -= 1
            }
        }

        func cancel() {
            fetchedResultsController?.delegate = nil
            fetchedResultsController = nil
        }

        func controllerDidChangeContent(
            _ controller: NSFetchedResultsController<NSFetchRequestResult>
        ) {
            updateDiff()
        }

        override var description: String {
            "ManagedObjectChanges(\(Object.self))"
        }
    }
}
