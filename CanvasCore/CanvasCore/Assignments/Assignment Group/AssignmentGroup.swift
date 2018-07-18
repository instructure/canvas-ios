//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import Foundation
import CoreData


import Marshal


public final class AssignmentGroup: NSManagedObject {
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var name: String
    @NSManaged internal (set) public var position: Int32
    @NSManaged internal (set) public var weight: Double

    @NSManaged internal (set) public var assignments: Set<Assignment>
}


extension AssignmentGroup: SynchronizedModel {
    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }
    
    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        try id          = json.stringID("id")
        try name        = json <| "name"
        try position    = json <| "position"
        try weight      = (json <| "group_weight") ?? 0.0

        try updateAssignments(json, inContext: context)
        
        let assignments: [Assignment] = try context.findAll(withValue: id, forKey: "assignmentGroupID")
        assignments.forEach { $0.assignmentGroup = self }
    }

    func updateAssignments(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        let gradingPeriodID: String? = try json.stringID("grading_period_id")
        let assignmentsJSON: [JSONObject] = (try json <| "assignments") ?? []
        let assignmentIDs: [String] = try assignmentsJSON.map { try $0.stringID("id") }

        let assignments: [Assignment] = try context.findAll(withValues: assignmentIDs, forKey: "id")

        assignments.forEach { assignment in
            assignment.gradingPeriodID = gradingPeriodID
        }
    }
}
