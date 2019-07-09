//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
    @objc public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    @objc public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
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
