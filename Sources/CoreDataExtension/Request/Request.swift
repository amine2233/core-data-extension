//
//  Request.swift
//  CoreDataDomain
//
//  Created by Amine Bensalah on 15/04/2020.
//  Copyright © 2020 Amine Bensalah. All rights reserved.
//

import CoreData
import Foundation

public struct Request<P: Persistable> {
    public let sort: NSSortDescriptor?
    public let predicate: NSPredicate?

    // MARK: - Init

    public init(sort: NSSortDescriptor? = nil, predicate: NSPredicate? = nil) {
        self.sort = sort
        self.predicate = predicate
    }

    // MARK: - Chaining specification methods

    public func filtered(_ key: String, identifier: P.Identifier) -> Request<P> {
        redef(predicate: NSPredicate(format: "\(key) == %ld", argumentArray: [identifier]))
    }

    public func filtered(_ key: String, equalTo value: Any) -> Request<P> {
        redef(predicate: NSPredicate(format: "\(key) == %@", argumentArray: [value]))
    }

    public func filtered(_ key: String, oneOf value: [Any]) -> Request<P> {
        redef(predicate: NSPredicate(format: "\(key) IN %@", argumentArray: [value]))
    }

    public func sorted(_ key: String?, ascending: Bool) -> Request<P> {
        redef(sort: NSSortDescriptor(key: key, ascending: ascending))
    }

    public func sorted(_ key: String?, ascending: Bool, comparator cmptr: @escaping Comparator)
        -> Request<P>
    {
        redef(sort: NSSortDescriptor(key: key, ascending: ascending, comparator: cmptr))
    }

    public func sorted(_ key: String?, ascending: Bool, selector: Selector) -> Request<P> {
        redef(sort: NSSortDescriptor(key: key, ascending: ascending, selector: selector))
    }

    public func buildFetchRequest() -> NSFetchRequest<P> {
        let request = NSFetchRequest<P>(entityName: P.entityNameObject)

        if let predicate = predicate {
            request.predicate = predicate
        }

        if let sort = sort {
            request.sortDescriptors = [sort]
        }

        return request
    }

    // MARK: - Internal

    private func redef(predicate: NSPredicate) -> Request<P> {
        Request<P>(sort: sort, predicate: predicate)
    }

    private func redef(sort: NSSortDescriptor) -> Request<P> {
        Request<P>(sort: sort, predicate: predicate)
    }
}
