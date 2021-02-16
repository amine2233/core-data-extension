//
//  FetchedResultsControllerSectionObserver.swift
//  CoreDataDomain
//
//  Created by Amine Bensalah on 16/04/2020.
//  Copyright © 2020 Amine Bensalah. All rights reserved.
//

import Combine
import CoreData
import Foundation
import CoreDataExtension

public final class FetchedResultsControllerSectionObserver<T: Persistable> {

    public var publisher: AnyPublisher<[NSFetchedResultsSectionInfo]?, Never> {
        return subject.eraseToAnyPublisher()
    }

    private let subject = PassthroughSubject<[NSFetchedResultsSectionInfo]?, Never>()
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
        bind()
    }

    private func bind() {
        fetcher.managedObjectContext.perform { [unowned self] in
            self.fetcher
                .publisher(for: \.sections)
                .sink { [weak self] sections in
                    self?.subject.send(sections)
                }
                .store(in: &self.disposeBag)
        }
    }
}
