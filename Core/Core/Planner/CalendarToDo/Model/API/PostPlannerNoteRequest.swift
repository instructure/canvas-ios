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
public struct PostPlannerNoteRequest: APIRequestable {
    public typealias Response = APINoContent

    public init(body: Body) {
        self.body = body
    }

    public var method: APIMethod = .post

    public var path: String = "planner_notes"

    public let body: Body?

    public struct Body: Codable, Equatable {
        let title: String?
        let details: String?
        let todo_date: Date
        let course_id: String?
        let linked_object_type: PlannableType?
        let linked_object_id: String?
    }
}
