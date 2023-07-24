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

public struct GetDSQuizRequest: APIRequestable {
    public typealias Response = DSQuiz

    public let method = APIMethod.get
    public var path: String

    public init(courseId: String, quizId: String) {
        self.path = "courses/\(courseId)/quizzes/\(quizId)"
    }
}

extension CreateDSQuizRequest {
    public struct RequestedDSQuiz: Encodable {
        let title: String
        let description: String?
        let quiz_type: String
        let points_possible: Float
        let published: Bool?

        public init(title: String = "Quiz Title",
                    description: String? = "Quiz Description",
                    quiz_type: DSQuizType,
                    points_possible: Float = 10,
                    published: Bool? = true) {
            self.title = title
            self.description = description
            self.quiz_type = quiz_type.rawValue
            self.points_possible = points_possible
            self.published = published
        }
    }

    public struct Body: Encodable {
        let quiz: RequestedDSQuiz
    }
}
