//
//  FetchedResultsControllerEntityObserver.swift
//  CoreDataDomain
//
//  Created by Amine Bensalah on 15/04/2020.
//  Copyright © 2020 Amine Bensalah. All rights reserved.
//

import Combine
import CoreData
import Foundation
import CoreDataExtension

public final class FetchedResultsControllerEntityPublisher<T: Persistable>: NSObject,
    NSFetchedResultsControllerDelegate
{

    public var publisher: AnyPublisher<[T]?, FetchedResultsControllerEntityObserverError> {
        return subject.eraseToAnyPublisher()
    }

    private let subject = PassthroughSubject<[T]?, FetchedResultsControllerEntityObserverError>()
    private let fetcher: NSFetchedResultsController<T>
    private var disposeBag: Set<AnyCancellable> = []

    public init(
        request: Request<T>,
        managedObjectContext context: NSManagedObjectContext,
        sectionNameKeyPath: String?,
        cacheName: String?
    ) {
        fetcher = NSFetchedResultsController(
            fetchRequest: request.buildFetchRequest(),
            managedObjectContext: context,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: cacheName
        )
        super.init()
        context.perform {
            self.fetcher.delegate = self

            do {
                try self.fetcher.performFetch()
            } catch {
                self.subject.send(completion: .failure(.performFetch(error)))
            }

            self.sendNextElement()
        }
    }

    private func sendNextElement() {
        fetcher.managedObjectContext.perform {
            let entities = self.fetcher.fetchedObjects ?? []
            self.subject.send(entities)
        }
    }

    public func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        sendNextElement()
    }

    deinit {
        self.fetcher.delegate = nil
    }
}
