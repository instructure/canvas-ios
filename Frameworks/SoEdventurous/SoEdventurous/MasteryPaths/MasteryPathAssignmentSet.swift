//
//  MasteryPathAssignmentSet.swift
//  SoEdventurous
//
//  Created by Ben Kraus on 9/9/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
import SoPersistent

public final class MasteryPathAssignmentSet: NSManagedObject {
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var position: Int
    @NSManaged internal (set) public var masteryPathsItem: MasteryPathsItem
    @NSManaged internal (set) public var assignments: NSSet
}

import Marshal

extension MasteryPathAssignmentSet: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id              = try json.stringID("id")
        position        = try json <| "position"

        var existingAssignments = assignments as! Set<MasteryPathAssignment>
        let assignmentsJSON: [JSONObject] = try json <| "assignments"
        for assignmentJSON in assignmentsJSON {
            let assignment: MasteryPathAssignment = try context.findOne(withPredicate: MasteryPathAssignment.uniquePredicateForObject(assignmentJSON)) ?? MasteryPathAssignment(inContext: context)
            try assignment.updateValues(assignmentJSON, inContext: context)
            assignment.assignmentSet = self

            existingAssignments.remove(assignment)
        }

        for item in existingAssignments {
            item.delete(inContext: context)
        }
    }
}
