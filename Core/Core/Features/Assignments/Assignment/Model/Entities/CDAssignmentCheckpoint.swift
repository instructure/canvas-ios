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

public class CDAssignmentCheckpoint: NSManagedObject {

    @NSManaged public var assignmentId: String
    @NSManaged public var assignmentName: String

    @NSManaged public var tag: String
    @NSManaged private var discussionCheckpointStepRaw: DiscussionCheckpointStepWrapper?
    public var discussionCheckpointStep: DiscussionCheckpointStep? {
        get { return discussionCheckpointStepRaw?.value } set { discussionCheckpointStepRaw = .init(value: newValue) }
    }

    @NSManaged private var pointsPossibleRaw: NSNumber?
    public var pointsPossible: Double? {
        get { return pointsPossibleRaw?.doubleValue } set { pointsPossibleRaw = .init(newValue) }
    }

    @NSManaged public var dueDate: Date?
    @NSManaged public var unlockDate: Date?
    @NSManaged public var lockDate: Date?

    @NSManaged public var isOnlyVisibleToOverrides: Bool
    @NSManaged public var overrides: Set<AssignmentOverride>

    // MARK: - Save

    @discardableResult
    public static func save(
        _ item: APIAssignmentCheckpoint,
        requiredReplyCount: Int?,
        assignmentId: String,
        in moContext: NSManagedObjectContext
    ) -> Self {
        let predicate = NSPredicate(\CDAssignmentCheckpoint.assignmentId, equals: assignmentId)
            .and(NSPredicate(\CDAssignmentCheckpoint.tag, equals: item.tag))
        let model: Self = moContext.fetch(predicate).first ?? moContext.insert()

        model.assignmentId = assignmentId
        model.assignmentName = item.name

        model.tag = item.tag
        model.discussionCheckpointStep = .init(tag: item.tag, requiredReplyCount: requiredReplyCount)

        model.pointsPossible = item.points_possible

        model.dueDate = item.due_at
        model.unlockDate = item.unlock_at
        model.lockDate = item.lock_at

        model.isOnlyVisibleToOverrides = item.only_visible_to_overrides ?? false
        if let overrides = item.overrides {
            model.overrides = Set(overrides.map { AssignmentOverride.save($0, in: moContext) })
        }

        return model
    }
}

extension CDAssignmentCheckpoint: Comparable {
    /// Compares by `discussionCheckpointStep`.
    /// It is assumed both checkpoints belong to the same assignment, otherwise comparison is meaningless.
    public static func < (lhs: CDAssignmentCheckpoint, rhs: CDAssignmentCheckpoint) -> Bool {
        guard let lhsStep = lhs.discussionCheckpointStep,
              let rhsStep = rhs.discussionCheckpointStep else {
            return false
        }

        return lhsStep < rhsStep
    }
}
