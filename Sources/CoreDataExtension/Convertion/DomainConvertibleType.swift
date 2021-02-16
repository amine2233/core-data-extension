//
//  DomainConvertibleType.swift
//  Entities
//
//  Created by Amine Bensalah on 10/06/2019.
//  Copyright © 2019 BENSALA. All rights reserved.
//

import Foundation

public protocol DomainConvertibleType {
    associatedtype DomainType: CoreDataRepresentable

    /// Convert the CoreData Entity to the remote model
    func asDomain() -> DomainType
}

extension Array where Element: DomainConvertibleType {
    /// All the domains
    public var asDomains: [Element.DomainType] {
        map { $0.asDomain() }
    }
}
