//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public class MasteryPath: NSManagedObject {
    @NSManaged public var locked: Bool
    @NSManaged public var selectedSetID: String?
    @NSManaged public var moduleItem: ModuleItem?
    @NSManaged public var assignmentSets: Set<MasteryPathAssignmentSet>

    public var needsSelection: Bool { selectedSetID == nil }
    public var numberOfOptions: Int { assignmentSets.count }

    public static func save(_ item: APIMasteryPath, in context: NSManagedObjectContext) -> MasteryPath {
        let model = context.insert() as MasteryPath
        model.locked = item.locked
        model.selectedSetID = item.selected_set_id?.value
        model.assignmentSets = Set(item.assignment_sets.map { .save($0, in: context) })
        return model
    }
}

public class MasteryPathAssignmentSet: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var position: Int
    @NSManaged public var masteryPath: MasteryPath?
    @NSManaged public var assignments: Set<MasteryPathAssignment>

    public static func save(_ item: APIMasteryPath.AssignmentSet, in context: NSManagedObjectContext) -> MasteryPathAssignmentSet {
        let model = context.insert() as MasteryPathAssignmentSet
        model.id = item.id.value
        model.assignments = Set(item.assignment_set_associations?.map { .save($0, in: context) } ?? [])
        model.position = item.position ?? 0
        return model
    }
}

public class MasteryPathAssignment: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var courseID: String
    @NSManaged public var name: String
    @NSManaged public var position: Int
    @NSManaged public var pointsPossible: NSNumber?
    @NSManaged public var assignmentSet: MasteryPathAssignmentSet?
    @NSManaged public var model: Assignment?

    public static func save(_ item: APIMasteryPath.Assignment, in context: NSManagedObjectContext) -> MasteryPathAssignment {
        let model = context.insert() as MasteryPathAssignment
        model.position = item.position ?? 0
        model.id = item.model.id.value
        model.courseID = item.model.course_id.value
        model.name = item.model.name
        model.pointsPossible = NSNumber(value: item.model.points_possible)
        model.model = Assignment.save(item.model, in: context, updateSubmission: false, updateScoreStatistics: false)
        return model
    }
}
