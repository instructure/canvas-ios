//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

// https://canvas.instructure.com/doc/api/quizzes.html#method.quizzes/quizzes_api.create
public struct CreateDSQuizRequest: APIRequestable {
    public typealias Response = DSQuiz

    public let method = APIMethod.post
    public var path: String
    public let body: Body?

    public init(body: Body, courseId: String) {
        self.body = body
        self.path = "courses/\(courseId)/quizzes"
    }
}

extension CreateDSQuizRequest {
    public struct RequestedDSQuiz: Encodable {
        let title: String
        let description: String?
        let quiz_type: String?
        let published: Bool?

        public init(title: String = "Quiz Title", description: String? = nil, quiz_type: String? = nil, published: Bool? = true) {
            self.title = title
            self.description = description
            self.quiz_type = quiz_type
            self.published = published
        }
    }

    public struct Body: Encodable {
        let quiz: RequestedDSQuiz
    }
}
