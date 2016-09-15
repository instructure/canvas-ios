//
//  Group.swift
//  Enrollments
//
//  Created by Derrick Hathaway on 2/9/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import CoreData
import SoPersistent
import TooLegit


public final class Group: Enrollment, Model {
    public override var contextID: ContextID {
        return ContextID(id: id, context: .Group)
    }
}

import Marshal
import SoLazy

extension Group: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }
    
    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id      = try json.stringID("id")
        name    = try json <| "name"
    }
}