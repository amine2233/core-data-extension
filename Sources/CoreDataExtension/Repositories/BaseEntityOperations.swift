//
//  SportOperations.swift
//  Services
//
//  Created by BENSALA on 10/04/2019.
//  Copyright © 2019 BENSALA. All rights reserved.
//

import Foundation

public protocol BaseEntityOperations {
    func update<T: CoreDataRepresentable>(baseEntity: T)
    func delete<T: CoreDataRepresentable>(baseEntity: T) throws
    func save<T: CoreDataRepresentable>(baseEntity: T, recursively: Bool) throws
}
