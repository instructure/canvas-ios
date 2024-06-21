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

// https://canvas.instructure.com/doc/api/planner.html#method.planner_notes.create
struct PostPlannerNoteRequest: APIRequestable {
    typealias Response = ResponseBody

    init(body: Body) {
        self.body = body
    }

    var method: APIMethod = .post

    var path: String = "planner_notes"

    let body: Body?

    struct Body: Codable, Equatable {
        let title: String
        let details: String?
        let todo_date: Date
        let course_id: String?
        let linked_object_type: PlannableType?
        let linked_object_id: String?
    }

    // Currently unused. It's defined only for error detection, because HTTP response codes are ignored at the moment.
    struct ResponseBody: Codable, Equatable {
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
}
