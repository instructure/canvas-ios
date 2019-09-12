//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public final class AssignmentGroup: NSManagedObject {
    public typealias JSON = APIAssignmentGroup

    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var position: Int
    @NSManaged public var courseID: String
    @NSManaged public var assignments: Set<Assignment>

    @discardableResult
    public static func save(_ item: APIAssignmentGroup, courseID: String, in context: NSManagedObjectContext) -> AssignmentGroup {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(AssignmentGroup.id), item.id.value)
        let model: AssignmentGroup = context.fetch(predicate).first ?? context.insert()
        model.id = item.id.value
        model.name = item.name
        model.position = item.position
        model.courseID = courseID

        if let apiAssignments = item.assignments, apiAssignments.count > 0 {
            model.assignments = Set<Assignment>()
            for a in apiAssignments {
                let assignmentPred = NSPredicate(format: "%K == %@", #keyPath(Assignment.id), a.id.value)
                let dbModel: Assignment = context.fetch(assignmentPred).first ?? context.insert()
                dbModel.update(fromApiModel: a, in: context, updateSubmission: false)
                model.assignments.insert(dbModel)
            }
        }

        return model
    }
}
