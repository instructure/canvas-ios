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

public struct APITodo: Codable {
    let assignment: APIAssignment?
    let quiz: APIQuiz?
    let context_type: String
    let course_id: ID?
    let group_id: ID?
    let html_url: URL
    let ignore: URL
    let ignore_permanently: URL
    let needs_grading_count: UInt?
    let type: TodoType
}

#if DEBUG
extension APITodo {
    public static func make(
        assignment: APIAssignment? = .make(),
        quiz: APIQuiz? = nil,
        context_type: String = "Course",
        course_id: ID? = "1",
        group_id: ID? = nil,
        html_url: URL = URL(string: "https://canvas.instructure.com/api/v1/courses/1/assignments/1")!,
        ignore: URL = URL(string: "https://canvas.instructure.com/api/v1/users/self/todo_ignore/1")!,
        ignore_permanently: URL = URL(string: "https://canvas.instructure.com/api/v1/users/self/todo_ignore/1")!,
        needs_grading_count: UInt? = nil,
        type: TodoType = .submitting
    ) -> APITodo {
        return APITodo(
            assignment: assignment,
            quiz: quiz,
            context_type: context_type,
            course_id: course_id,
            group_id: group_id,
            html_url: html_url,
            ignore: ignore,
            ignore_permanently: ignore_permanently,
            needs_grading_count: needs_grading_count,
            type: type
        )
    }
}
#endif

public struct GetTodosRequest: APIRequestable {
    public typealias Response = [APITodo]
    public var path: String { "users/self/todo" }
    let include: [GetTodosInclude]

    public enum GetTodosInclude: String, CaseIterable {
        case ungraded_quizzes
    }

    init(include: [GetTodosInclude] = GetTodosRequest.GetTodosInclude.allCases) {
        self.include = include
    }

    public var query: [APIQueryItem] {
        [
            .include(include.map { $0.rawValue }),
            .perPage(100)
        ]
    }
}

struct DeleteTodoRequest: APIRequestable {
    typealias Response = APINoContent

    let ignoreURL: URL
    var method: APIMethod { .delete }
    var path: String { ignoreURL.absoluteString }
}
