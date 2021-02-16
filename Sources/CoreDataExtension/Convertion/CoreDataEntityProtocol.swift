//
//  BaseEntityProtocol.swift
//  Entities
//
//  Created by BENSALA on 03/05/2019.
//  Copyright
//

import CoreData
import Foundation

public protocol CoreDataEntityProtocol: AnyObject {
    associatedtype Identifier: Hashable

    /// The remote identity
    var identifier: Self.Identifier { get }

    /// The entity name
    static func entityName() -> String

    /// Create an `NSEntityDescription`
    static func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription?

    /// Create a fetch request of entity
    static func fetchRequest<T: NSManagedObject>() -> NSFetchRequest<T>
}

extension CoreDataEntityProtocol {
    public static var modelIdentifier: String {
        String(describing: Self.self)
    }
}

extension CoreDataEntityProtocol where Self: NSManagedObject {
    // MARK: - Class methods

    public static func entityName() -> String {
        Self.modelIdentifier
    }

    public static func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription?
    {
        NSEntityDescription.entity(forEntityName: entityName(), in: managedObjectContext)
    }

    public static func fetchRequest<T: NSManagedObject>() -> NSFetchRequest<T> {
        NSFetchRequest(entityName: entityName())
    }
}
