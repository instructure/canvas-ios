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

public final class AssignmentDate: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var base: Bool
    @NSManaged public var title: String?
    @NSManaged public var dueAt: Date?
    @NSManaged public var unlockAt: Date?
    @NSManaged public var lockAt: Date?

    @discardableResult
    public static func save(_ item: APIAssignmentDate, assignmentID: String, in context: NSManagedObjectContext) -> AssignmentDate {
        let id = item.id?.value ?? "base-\(assignmentID)"
        let model: AssignmentDate = context.first(where: #keyPath(AssignmentDate.id), equals: id) ?? context.insert()
        model.id = id
        model.base = item.base == true
        model.title = item.title
        model.dueAt = item.due_at
        model.unlockAt = item.unlock_at
        model.lockAt = item.lock_at
        return model
    }

    @discardableResult
    public static func save(_ item: APIAssignmentDate, quizID: String, in context: NSManagedObjectContext) -> AssignmentDate {
        let id = item.id?.value ?? "base-quiz-\(quizID)"
        let model: AssignmentDate = context.first(where: #keyPath(AssignmentDate.id), equals: id) ?? context.insert()
        model.id = id
        model.base = item.base == true
        model.title = item.title
        model.dueAt = item.due_at
        model.unlockAt = item.unlock_at
        model.lockAt = item.lock_at
        return model
    }
}
