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

public final class AssignmentOverride: NSManagedObject, WriteableModel {
    @NSManaged public var assignmentID: String
    @NSManaged public var courseSectionID: String?
    @NSManaged public var dueAt: Date?
    @NSManaged public var id: String
    @NSManaged public var groupID: String?
    @NSManaged public var lockAt: Date?
    @NSManaged var studentIDsRaw: String?
    @NSManaged public var title: String
    @NSManaged public var unlockAt: Date?

    public var studentIDs: [String]? {
        get { studentIDsRaw?.components(separatedBy: ",") }
        set { studentIDsRaw = newValue?.joined(separator: ",") }
    }

    @discardableResult
    public static func save(_ item: APIAssignmentOverride, in context: NSManagedObjectContext) -> AssignmentOverride {
        let model: AssignmentOverride = context.first(where: #keyPath(AssignmentOverride.id), equals: item.id.value) ?? context.insert()
        model.assignmentID = item.assignment_id.value
        model.courseSectionID = item.course_section_id?.value
        model.dueAt = item.due_at
        model.groupID = item.group_id?.value
        model.id = item.id.value
        model.lockAt = item.lock_at
        model.studentIDs = item.student_ids?.map { $0.value }
        model.title = item.title
        model.unlockAt = item.unlock_at
        return model
    }
}
