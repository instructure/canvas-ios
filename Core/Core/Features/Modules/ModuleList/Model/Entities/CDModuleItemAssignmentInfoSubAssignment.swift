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

final class CDModuleItemAssignmentInfoSubAssignment: NSManagedObject {
    @NSManaged var moduleItemId: String
    @NSManaged var tag: String
    @NSManaged private var discussionCheckpointStepRaw: DiscussionCheckpointStepWrapper?
    var discussionCheckpointStep: DiscussionCheckpointStep? {
        get { return discussionCheckpointStepRaw?.value } set { discussionCheckpointStepRaw = .init(value: newValue) }
    }
    @NSManaged private var pointsPossibleRaw: NSNumber?
    public var pointsPossible: Double? {
        get { pointsPossibleRaw?.doubleValue } set { pointsPossibleRaw = .init(newValue) }
    }
    @NSManaged var dueDate: Date?

    @discardableResult
    static func save(
        item: APIModuleItemAssignmentInfo.APISubAssignment,
        moduleItemId: String,
        in context: NSManagedObjectContext
    ) -> CDModuleItemAssignmentInfoSubAssignment {
        let model: CDModuleItemAssignmentInfoSubAssignment = context.insert()

        model.moduleItemId = moduleItemId
        model.tag = item.sub_assignment_tag
        model.discussionCheckpointStep = .init(tag: item.sub_assignment_tag, requiredReplyCount: item.replies_required)

        model.pointsPossible = item.points_possible
        model.dueDate = item.due_date

        return model
    }
}

extension CDModuleItemAssignmentInfoSubAssignment: Comparable {
    /// Compares by `discussionCheckpointStep`.
    /// It is assumed both sub-assignments belong to the same assignment, otherwise comparison is meaningless.
    public static func < (lhs: CDModuleItemAssignmentInfoSubAssignment, rhs: CDModuleItemAssignmentInfoSubAssignment) -> Bool {
        guard let lhsStep = lhs.discussionCheckpointStep,
              let rhsStep = rhs.discussionCheckpointStep else {
            return false
        }

        return lhsStep < rhsStep
    }
}
