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

import CoreData
import Foundation

public class GetQuiz: APIUseCase {
    public typealias Model = Quiz

    public let courseID: String
    public let quizID: String

    public init(courseID: String, quizID: String) {
        self.courseID = courseID
        self.quizID = quizID
    }

    public var cacheKey: String? {
        return "get-courses-\(courseID)-quizzes-\(quizID)"
    }

    public var request: GetQuizRequest {
        return GetQuizRequest(courseID: courseID, quizID: quizID)
    }

    public var scope: Scope {
        return .where(#keyPath(Quiz.id), equals: quizID)
    }

    public func write(response: APIQuiz?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else { return }
        let quiz = Quiz.save(item, in: client)
        quiz.courseID = courseID
        quiz.submission = client.first(where: #keyPath(QuizSubmission.quizID), equals: quizID)
    }
}
