//
//  FetchedResultsControllerDelegate.swift
//  Services
//
//  Created by Amine Bensalah on 15/05/2019.
//  Copyright © 2019 BENSALA. All rights reserved.
//

import CoreData

public protocol FetchResultsSection: NSFetchedResultsSectionInfo {}

public protocol FetchedResultsControllerDelegate: AnyObject {
    func controller(sectionIndex: IndexSet, for type: FetchedResultsChangeType)
    func controller(
        object anObject: Any, at indexPath: IndexPath?, for type: FetchedResultsChangeType,
        newIndexPath: IndexPath?)
    func controllerDidChangeContent()
    func controllerWillChangeContent()
}
