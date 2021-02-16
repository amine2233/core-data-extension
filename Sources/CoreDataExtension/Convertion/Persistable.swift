//
//  Persistable.swift
//  Entities
//
//  Created by Amine Bensalah on 10/06/2019.
//  Copyright © 2019 BENSALA. All rights reserved.
//

import CoreData
import Foundation

// NSFetchRequestResult is used by NSManagedObject
public protocol Persistable: NSManagedObject, DomainConvertibleType {
    /// A type representing the stable identity of the entity associated with
    /// an instance.
    associatedtype Identifier: Hashable

    /// The identity of the entity associated with this instance.
    var identifier: Self.Identifier? { get set }

    /// The object name entity associated with this instance.
    static var entityNameObject: String { get }

    /// The primary attribute of this name, can be an "id" or "uuid".
    static var primaryAttribute: String { get }
}

extension Persistable {
    // Need to override
    public static var primaryAttribute: String {
        fatalError("Need to override this primary attribute")
    }

    public static var entityNameObject: String {
        String(describing: self)
    }
}
