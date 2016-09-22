//
//  Override.swift
//  Assignments
//
//  Created by Derrick Hathaway on 4/15/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData

public final class DueDateOverride: NSManagedObject {
    @NSManaged private (set) public var id: String
    @NSManaged private (set) public var title: String
    @NSManaged private (set) public var due: NSDate
    
    @NSManaged var assignment: Assignment?
}


import SoPersistent
import Marshal

extension DueDateOverride: SynchronizedModel {
    
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }
    
    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id      = try json.stringID("id")
        title   = try json <| "title"
        due     = try json <| "due_at"
        
        let assignmentID: String = try json.stringID("assignment_id")
        let assignment: Assignment? = try context.findOne(withValue: assignmentID, forKey: "id")
        self.assignment = assignment
    }
}