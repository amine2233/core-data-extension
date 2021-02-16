//
//  FetchedResultsChangeType.swift
//  CoreDataDomain
//
//  Created by Amine Bensalah on 16/04/2020.
//  Copyright © 2020 Amine Bensalah. All rights reserved.
//

import CoreData

public enum FetchedResultsChangeType {
    case insert
    case delete
    case move
    case update
    case nothing

    public init(_ type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self = .insert
        case .delete:
            self = .delete
        case .move:
            self = .move
        case .update:
            self = .update
        @unknown default:
            self = .nothing
        }
    }
}
