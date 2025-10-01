//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

final class CDModuleItemAssignmentInfo: NSManagedObject {
    @NSManaged var courseId: String
    @NSManaged var moduleItemId: String
    @NSManaged private var pointsPossibleRaw: NSNumber?
    public var pointsPossible: Double? {
        get { pointsPossibleRaw?.doubleValue } set { pointsPossibleRaw = .init(newValue) }
    }
    @NSManaged var dueDate: Date?
    @NSManaged var isPastDue: Bool
    @NSManaged var todoDate: Date?
    @NSManaged private var subAssignmentsRaw: NSOrderedSet
    var subAssignments: [CDModuleItemAssignmentInfoSubAssignment] {
        get { subAssignmentsRaw.typedArray() ?? [] } set { subAssignmentsRaw = .init(newValue) }
    }

    @discardableResult
    static func save(
        item: APIModuleItemAssignmentInfo,
        courseId: String,
        moduleItemId: String,
        in context: NSManagedObjectContext
    ) -> CDModuleItemAssignmentInfo {
        let predicate = NSPredicate(\CDModuleItemAssignmentInfo.courseId, equals: courseId)
            .and(NSPredicate(\CDModuleItemAssignmentInfo.moduleItemId, equals: moduleItemId))
        let model: CDModuleItemAssignmentInfo = context.fetch(predicate).first ?? context.insert()

        model.courseId = courseId
        model.moduleItemId = moduleItemId

        model.pointsPossible = item.points_possible

        model.dueDate = item.due_date
        model.isPastDue = item.past_due ?? false
        model.todoDate = item.todo_date

        let apiSubAssignments = item.sub_assignments ?? []
        // always clear existing subAssignments
        model.subAssignments.forEach { context.delete($0) }
        model.subAssignments = apiSubAssignments
            .map {
                CDModuleItemAssignmentInfoSubAssignment.save(
                    item: $0,
                    moduleItemId: moduleItemId,
                    in: context
                )
            }
            .sorted(by: <)

        return model
    }
}
