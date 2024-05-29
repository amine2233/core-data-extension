//
//  CoreDataRepresentable.swift
//  CoreDataDomain
//
//  Created by Amine Bensalah on 16/04/2020.
//  Copyright © 2020 Amine Bensalah. All rights reserved.
//

import CoreData

public protocol CoreDataRepresentable: Identifiable {
    /// The representation of model on CoreData
    associatedtype CoreDataType: Persistable

    /// The identifiable
    var id: Self.ID { get }

    /// Update the core data entity
    func update(entity: CoreDataType)
}

extension CoreDataRepresentable {
    /// Synchronise the core data entity with remote entity
    /// - Parameter context: The CoreData Context
    @discardableResult public func sync(in context: NSManagedObjectContext) throws -> CoreDataType? where ID == CoreDataType.Identifier {
        try context.sync(entity: self, update: update)
    }

    /// Save entity
    /// - Parameters:
    ///   - context: The CoreData Context
    ///   - recursively: save data recursivly
    public func save(in context: NSManagedObjectContext, recursively: Bool = false) throws {
        try context.save(recursively: recursively)
    }

    /// Delete entity
    /// - Parameter context: The CoreData Context
    public func delete(in context: NSManagedObjectContext) throws {
        try context.syncDelete(entity: self)
    }
}

extension Array where Element: CoreDataRepresentable, Element.ID == Element.CoreDataType.Identifier {
    public func syncs(in context: NSManagedObjectContext) throws -> [Element.CoreDataType] {
        let elements = try compactMap { try $0.sync(in: context) }
        try context.save()
        return elements
    }

    public func deletes(in context: NSManagedObjectContext) throws {
        try forEach { try $0.delete(in: context) }
        try context.save()
    }
}
