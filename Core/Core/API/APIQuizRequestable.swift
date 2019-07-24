//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

// https://canvas.instructure.com/doc/api/quizzes.html#method.quizzes/quizzes_api.index
public struct GetQuizzesRequest: APIRequestable {
    public typealias Response = [APIQuiz]

    let courseID: String

    public var path: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/quizzes?per_page=100"
    }
}

// https://canvas.instructure.com/doc/api/quizzes.html#method.quizzes/quizzes_api.show
public struct GetQuizRequest: APIRequestable {
    public typealias Response = APIQuiz

    let courseID: String
    let quizID: String

    public var path: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/quizzes/\(quizID)"
    }
}

// https://canvas.instructure.com/doc/api/quiz_submissions.html#method.quizzes/quiz_submissions_api.index
public struct GetQuizSubmissionsRequest: APIRequestable {
    public struct Response: Codable {
        let quiz_submissions: [APIQuizSubmission]
    }

    let courseID: String
    let quizID: String

    public var path: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/quizzes/\(quizID)/submissions"
    }
}
