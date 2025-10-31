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

/// Stores DiscussionCheckpoint data for a ModuleItem's DiscussionCheckpoint,
/// based on the item's `moduleItemId` and the checkpoints `tag`.
final class CDModuleItemDiscussionCheckpoint: NSManagedObject {

    @NSManaged var moduleItemId: String
    @NSManaged var tag: String

    @NSManaged private var discussionCheckpointStepRaw: DiscussionCheckpointStepWrapper?
    var discussionCheckpointStep: DiscussionCheckpointStep? {
        get { discussionCheckpointStepRaw?.value } set { discussionCheckpointStepRaw = .init(newValue) }
    }

    @NSManaged private var pointsPossibleRaw: NSNumber?
    public var pointsPossible: Double? {
        get { pointsPossibleRaw?.doubleValue } set { pointsPossibleRaw = .init(newValue) }
    }

    @NSManaged var dueDate: Date?

    /// Saves all checkpoints for a given `moduleItemId`.
    @discardableResult
    static func save(
        checkpointsData: APIModuleItemsDiscussionCheckpoints.Data,
        moduleItemId: String,
        in context: NSManagedObjectContext
    ) -> [CDModuleItemDiscussionCheckpoint] {
        checkpointsData.checkpoints
            .map { item in
                let model: CDModuleItemDiscussionCheckpoint = context.insert()

                model.moduleItemId = moduleItemId
                model.tag = item.tag
                model.discussionCheckpointStep = .init(
                    tag: item.tag,
                    requiredReplyCount: checkpointsData.replyToEntryRequiredCount
                )

                model.pointsPossible = item.pointsPossible
                model.dueDate = item.dueAt

                return model
            }
            .sorted(by: <)
    }
}

extension CDModuleItemDiscussionCheckpoint: Comparable {
    /// Compares by `discussionCheckpointStep`, moves `nil` to the end.
    /// It is assumed both sub-assignments belong to the same assignment, otherwise comparison is meaningless.
    public static func < (lhs: CDModuleItemDiscussionCheckpoint, rhs: CDModuleItemDiscussionCheckpoint) -> Bool {
        switch (lhs.discussionCheckpointStep, rhs.discussionCheckpointStep) {
        case (nil, nil):
            return false
        case (nil, _):
            return false
        case (_, nil):
            return true // nil goes to the end
        case (let lhsStep?, let rhsStep?):
            return lhsStep < rhsStep
        }
    }
}
