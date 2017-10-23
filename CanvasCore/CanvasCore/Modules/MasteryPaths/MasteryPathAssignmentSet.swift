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


public final class MasteryPathAssignmentSet: NSManagedObject {
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var position: Int64
    @NSManaged internal (set) public var masteryPathsItem: MasteryPathsItem
    @NSManaged internal (set) public var assignments: NSSet
}

import Marshal

extension MasteryPathAssignmentSet: SynchronizedModel {
    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
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
