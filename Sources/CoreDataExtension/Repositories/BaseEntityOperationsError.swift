//
//  BaseEntityOperationsError.swift
//  CoreDataDomain
//
//  Created by Amine Bensalah on 16/04/2020.
//  Copyright © 2020 Amine Bensalah. All rights reserved.
//

import Foundation

public enum BaseEntityOperationsError: Error, CustomStringConvertible {
    case emptyNameIsIllegal

    public var description: String {
        switch self {
        case .emptyNameIsIllegal:
            return "File may not be given an empty name"
        }
    }
}
