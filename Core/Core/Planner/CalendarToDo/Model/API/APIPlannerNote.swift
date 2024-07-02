//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

// https://canvas.instructure.com/doc/api/planner.html#PlannerNote
// Used only when creating or updating a PlannerNote (aka. Calendar ToDo),
// not when fetching ToDos together with other plannables.
public struct APIPlannerNote: Codable, Equatable {
    let id: String
    let title: String
    let details: String?
    let todo_date: Date
    let user_id: String?
    let course_id: String?
    let workflow_state: String?
    let created_at: Date?
    let updated_at: Date?
}

#if DEBUG
extension APIPlannerNote {
    public static func make(
        id: String = "",
        title: String = "",
        details: String? = nil,
        todo_date: Date = Clock.now,
        user_id: String? = nil,
        course_id: String? = nil,
        workflow_state: String? = nil,
        created_at: Date? = nil,
        updated_at: Date? = nil
    ) -> APIPlannerNote {
        .init(
            id: id,
            title: title,
            details: details,
            todo_date: todo_date,
            user_id: user_id,
            course_id: course_id,
            workflow_state: workflow_state,
            created_at: created_at,
            updated_at: updated_at
        )
    }
}
#endif
