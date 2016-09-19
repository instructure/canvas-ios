//
//  NSManagedObject+SoAutomated.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 3/10/16.
//  Copyright © 2016 instructure. All rights reserved.
//

import Foundation
import CoreData
import SoPersistent

extension NSManagedObject {

    public var isValid: Bool {
        do {
            try self.validateForInsert()
            return true
        } catch {
            return false
        }
    }

}

extension NSManagedObject {
    public static func count(inContext context: NSManagedObjectContext) -> Int {
        let all = fetch(nil, sortDescriptors: nil, inContext: context)
        return context.countForFetchRequest(all, error: nil)
    }
}
