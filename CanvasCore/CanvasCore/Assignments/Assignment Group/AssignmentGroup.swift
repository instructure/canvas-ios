//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
