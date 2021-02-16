//
//  FetchedResultsControllerEntityObserverError.swift
//  CoreDataDomain
//
//  Created by Amine Bensalah on 16/04/2020.
//  Copyright © 2020 Amine Bensalah. All rights reserved.
//

import Foundation
import CoreDataExtension

public enum FetchedResultsControllerEntityObserverError: Error {
    case performFetch(Error)
}
