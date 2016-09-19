//
//  AssignmentGroup.swift
//  Assignments
//
//  Created by Derrick Hathaway on 3/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
import SoPersistent
import TooLegit
import Marshal


public final class AssignmentGroup: NSManagedObject {
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var name: String
    @NSManaged internal (set) public var position: Int32
    @NSManaged internal (set) public var weight: Double

    @NSManaged internal (set) public var assignments: Set<Assignment>
}


extension AssignmentGroup: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }
    
    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        try id          = json.stringID("id")
        try name        = json <| "name"
        try position    = json <| "position"
        try weight      = json <| "group_weight"

        try updateAssignments(json, inContext: context)
        let assignments: [Assignment] = try context.findAll(withValue: id, forKey: "assignmentGroupID")
        assignments.forEach { $0.assignmentGroup = self }
    }

    func updateAssignments(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        let gradingPeriodID: String? = try json.stringID("grading_period_id")
        let assignmentsJSON: [JSONObject] = try json <| "assignments" ?? []
        let assignmentIDs: [String] = try assignmentsJSON.map { try $0.stringID("id") }

        let assignments: [Assignment] = try context.findAll(withValues: assignmentIDs, forKey: "id")

        assignments.forEach { assignment in
            assignment.gradingPeriodID = gradingPeriodID
        }
    }
}
