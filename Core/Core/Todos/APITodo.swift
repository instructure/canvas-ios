//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public enum TodoType: String, Codable {
    case grading, submitting
}

public struct APITodo: Codable {
    let type: TodoType
    let ignore: URL
    let ignore_permanently: URL
    let html_url: URL
    let needs_grading_count: UInt?
    let assignment: APIAssignment
    let context_type: String
    let course_id: ID?
    let group_id: ID?
}

struct GetTodosRequest: APIRequestable {
    typealias Response = [APITodo]
    let path = "users/self/todo"
    let query = [ APIQueryItem.value("per_page", "100") ]
}

struct DeleteTodoRequest: APIRequestable {
    typealias Response = APINoContent

    let ignoreURL: URL
    let method = APIMethod.delete
    var path: String {
        ignoreURL.absoluteString
    }
}
