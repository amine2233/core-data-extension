//
//  NSManagedObjectContext+Extension.swift
//  CoreDataDomain
//
//  Created by Amine Bensalah on 01/07/2019.
//  Copyright © 2019 Amine Bensalah. All rights reserved.
//

import CoreData
import Foundation

public enum ManagedObjectContextError: Error {
    case createEntityClass(String)
    case invalidEntityClass(String)
}

public extension NSManagedObjectContext {
    func create<T: Persistable>() throws -> T {
        guard
            let entity =
                NSEntityDescription
                .insertNewObject(
                    forEntityName: String(describing: T.self),
                    into: self) as? T
        else { throw ManagedObjectContextError.createEntityClass("Can't create an entity \(String(describing: T.self))") }
        return entity
    }

    func syncDelete<C: CoreDataRepresentable, P>(entity: C) throws where C.CoreDataType == P {
        let request = Request<P>().filtered(P.primaryAttribute, equalTo: entity.id)
        try remove(request)
    }

    func first<P: Persistable>(_ request: Request<P>) -> P? {
        do {
            let result = try fetch(request).first
            return result
        } catch {
            return nil
        }
    }

    func sync<C: CoreDataRepresentable, P>(entity: C, update: @escaping (P) -> Void) throws -> P
    where C.CoreDataType == P, C.ID == P.Identifier {
        let request = Request<P>().filtered(P.primaryAttribute, identifier: entity.id)
        let entity = try first(request) ?? create()
        update(entity)
        return entity
    }

    func wipe<T: Persistable>(_: T.Type) throws {
        let request = Request<T>(sort: nil, predicate: nil)
        let entities = try fetch(request)
        try remove(entities)
    }

    func remove<T: Persistable>(_ request: Request<T>) throws {
        let entities = try fetch(request)
        try remove(entities)
    }

    func remove<T: Persistable>(_ entities: [T]) throws {
        for entity in entities {
            delete(entity)
        }
    }

    func fetch<T: Persistable>(_ request: Request<T>, includeProps: Bool = true) throws -> [T] {
        let request = buildFetchRequest(request)
        request.includesPropertyValues = includeProps
        let result = try fetch(request)
        return result.compactMap { $0 as? T }
    }

    func count<T: Persistable>(_ request: Request<T>) throws -> Int {
        let entities = try fetch(request)
        return entities.count
    }

    func save(recursively: Bool) throws {
        var errorSave: Error?

        performAndWait {
            if self.hasChanges {
                do {
                    try self.saveThisAndParentContext(recursively)
                } catch {
                    errorSave = error
                }
            }
        }

        if let error = errorSave {
            throw error
        }
    }

    func saveThisAndParentContext(_ recursively: Bool) throws {
        try save()

        if recursively {
            if let parent = parent {
                try parent.save(recursively: recursively)
            }
        }
    }

    private func buildFetchRequest<T: Persistable>(_ request: Request<T>) -> NSFetchRequest<
        NSFetchRequestResult
    > {
        return buildFetchRequest(T.entityName, predicate: request.predicate, sort: request.sort)
    }

    private func buildFetchRequest(
        _ entityName: String, predicate: NSPredicate?, sort: NSSortDescriptor?
    ) -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)

        if let predicate = predicate {
            request.predicate = predicate
        }

        if let sort = sort {
            request.sortDescriptors = [sort]
        }

        return request
    }
}
