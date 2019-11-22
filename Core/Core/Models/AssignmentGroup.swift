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

    @discardableResult
    public static func save(_ item: APIAssignmentGroup, courseID: String, gradingPeriodID: String?, cacheKey: String?, in context: NSManagedObjectContext) -> AssignmentGroup {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(AssignmentGroup.id), item.id.value)
        let model: AssignmentGroup = context.fetch(predicate).first ?? context.insert()
        model.id = item.id.value
        model.name = item.name
        model.position = item.position
        model.courseID = courseID

        for a in item.assignments ?? [] {
            let assignment = Assignment.save(a, in: context, updateSubmission: false, cacheKey: cacheKey)
            assignment.assignmentGroupPosition = item.position
            assignment.gradingPeriodID = gradingPeriodID
            assignment.assignmentGroup = model
        }

        return model
    }
}
