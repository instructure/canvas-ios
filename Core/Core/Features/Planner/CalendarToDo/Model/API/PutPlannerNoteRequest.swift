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

// https://canvas.instructure.com/doc/api/planner.html#method.planner_notes.update
struct PutPlannerNoteRequest: APIRequestable {
    typealias Response = APIPlannerNote

    struct Body: Codable, Equatable {
        let title: String
        let details: String?
        let todo_date: Date
        let course_id: String?

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(title, forKey: .title)
            try container.encode(details, forKey: .details)
            try container.encode(todo_date, forKey: .todo_date)
            try container.encode(course_id, forKey: .course_id)
        }
    }

    var method: APIMethod { .put }
    var path: String { "planner_notes/\(id)" }

    let id: String
    let body: Body?
}

#if DEBUG
extension PutPlannerNoteRequest.Body {
    static func make(
        title: String = "",
        details: String? = nil,
        todo_date: Date = Clock.now,
        course_id: String? = nil
    ) -> PutPlannerNoteRequest.Body {
        .init(
            title: title,
            details: details,
            todo_date: todo_date,
            course_id: course_id
        )
    }
}
#endif
