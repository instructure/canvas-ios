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

import Core

// https://canvas.instructure.com/doc/api/pages.html#method.wiki_pages_api.create
public struct CreateDSPlannerNotesRequest: APIRequestable {
    public typealias Response = DSPlannerNote

    public let method = APIMethod.post
    public var path: String
    public let body: Body?

    public init(body: Body) {
        self.body = body
        self.path = "planner_notes"
    }
}

extension CreateDSPlannerNotesRequest {
    public struct Body: Encodable {
        let title: String
        let details: String
        let type: String
        let todo_date: Date
        let context_code: String
        let user_id: String

        public init(title: String, details: String, type: String, todoDate: Date, contextCode: String, userId: String) {
            self.title = title
            self.details = details
            self.type = type
            self.todo_date = todoDate
            self.context_code = contextCode
            self.user_id = userId
        }
    }
}
