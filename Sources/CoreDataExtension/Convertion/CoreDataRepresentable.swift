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

public extension CoreDataRepresentable {
    /// Synchronise the core data entity with remote entity
    /// - Parameter context: The CoreData Context
    @discardableResult func sync(
        in context: NSManagedObjectContext
    ) throws -> CoreDataType? where ID == CoreDataType.Identifier {
        try context.sync(entity: self, update: update)
    }

    /// Save entity
    /// - Parameters:
    ///   - context: The CoreData Context
    ///   - recursively: save data recursivly
    func save(
        in context: NSManagedObjectContext,
        recursively: Bool = false
    ) throws {
        try context.save(recursively: recursively)
    }

    /// Delete entity
    /// - Parameter context: The CoreData Context
    func delete(in context: NSManagedObjectContext) throws {
        try context.syncDelete(entity: self)
    }
    
    /// Get entiry from CoreData
    /// - Parameter context: The CoreData Context
    func get(
        in context: NSManagedObjectContext
    ) throws -> CoreDataType where ID == CoreDataType.Identifier {
        let request = Request<CoreDataType>().filtered(CoreDataType.primaryAttribute, identifier: self.id)
        return try context.first(request)
    }
    
    /// Create the core data entiry
    /// - Parameter context: The CoreData Context
    @discardableResult func create(
        in context: NSManagedObjectContext
    ) throws -> CoreDataType? where ID == CoreDataType.Identifier {
        let data = try context.create() as CoreDataType
        return try context.sync(entity: self, update: update)
    }
}

public extension Collection where Element: CoreDataRepresentable, Element.ID == Element.CoreDataType.Identifier {
    func syncs(in context: NSManagedObjectContext) throws -> [Element.CoreDataType] {
        let elements = try compactMap { try $0.sync(in: context) }
        try context.save()
        return elements
    }

    func deletes(in context: NSManagedObjectContext) throws {
        try forEach { try $0.delete(in: context) }
        try context.save()
    }
}
