//
//  CoreDataStack.swift
//  CoreDataDomain
//
//  Created by Amine Bensalah on 01/07/2019.
//  Copyright © 2019 Amine Bensalah. All rights reserved.
//

import CoreData
import Foundation

public protocol CoreDataStackProtocol {
    var mainContext: NSManagedObjectContext { get }

    func newDerivedContext() -> NSManagedObjectContext
    func clearCoreData() throws
    func clear<P: Persistable>(_ sequence: [P.Type]) throws
}

open class CoreDataStack: CoreDataStackProtocol {
    public let databaseName: String
    public let bundle: Bundle

    public lazy var managerObjectModel: NSManagedObjectModel? = {
        guard
            let modelURL = bundle.url(forResource: databaseName, withExtension: "momd")
        else { return nil }
        return NSManagedObjectModel(contentsOf: modelURL)
    }()

    public init(databaseName: String, bundle: Bundle = .main) {
        self.databaseName = databaseName
        self.bundle = bundle
    }

    public lazy var mainContext: NSManagedObjectContext = {
        self.storeContainer.viewContext
    }()

    public lazy var storeContainer: NSPersistentContainer = {
        guard let model = managerObjectModel else {
            fatalError("not found model database url")
        }
        let container = NSPersistentContainer(
            name: databaseName, managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    public func newDerivedContext() -> NSManagedObjectContext {
        let context = storeContainer.newBackgroundContext()
        return context
    }

    public func saveContext() {
        saveContext(mainContext)
    }

    public func saveContext(_ context: NSManagedObjectContext) {
        context.perform {
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }

            if context != self.mainContext {
                self.saveContext(self.mainContext)
            }
        }
    }
    open func clearCoreData() throws {}

    open func clear<P: Persistable>(_ sequence: [P.Type]) throws {
        try sequence.forEach {
            try self.mainContext.wipe($0)
        }
        try mainContext.save(recursively: true)
    }
}
