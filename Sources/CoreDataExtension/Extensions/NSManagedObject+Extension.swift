//
//  NSManagedObject+Extension.swift
//  CoreDataDomain
//
//  Created by Amine Bensalah on 16/04/2020.
//  Copyright © 2020 Amine Bensalah. All rights reserved.
//

import CoreData

extension NSManagedObject {
    public class var entityName: String {
        let stringFromClass = NSStringFromClass(self)
        guard let last = stringFromClass.components(separatedBy: ".").last else {
            return stringFromClass
        }
        return last
    }
}
