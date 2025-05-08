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
public struct CreateDSQuizQuestionRequest: APIRequestable {
    public typealias Response = DSQuizQuestion

    public let method = APIMethod.post
    public var path: String
    public let body: Body?

    public init(body: Body, courseId: String, quizId: String) {
        self.body = body
        self.path = "courses/\(courseId)/quizzes/\(quizId)/questions"
    }
}

extension CreateDSQuizQuestionRequest {
    public struct RequestedDSQuizQuestion: Encodable {
        let question_text: String
        let question_type: String
        let points_possible: Float
        let answers: [DSAnswer]

        public init(question_text: String,
                    question_type: DSQuestionType,
                    points_possible: Float = 5,
                    answers: [DSAnswer]) {
            self.question_text = question_text
            self.question_type = question_type.rawValue
            self.points_possible = points_possible
            self.answers = answers
        }
    }

    public struct Body: Encodable {
        let question: RequestedDSQuizQuestion
    }
}
