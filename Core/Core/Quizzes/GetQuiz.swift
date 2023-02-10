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

public class GetQuiz: UseCase {
    public typealias Model = Quiz
    public struct Response: Codable {
        let quiz: APIQuiz?
        let submission: APIQuizSubmission?
    }

    public let courseID: String
    public let quizID: String

    public init(courseID: String, quizID: String) {
        self.courseID = courseID
        self.quizID = quizID
    }

    public var cacheKey: String? {
        return "get-courses-\(courseID)-quizzes-\(quizID)"
    }

    public var scope: Scope {
        return .where(#keyPath(Quiz.id), equals: quizID)
    }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping (Response?, URLResponse?, Error?) -> Void) {
        let getQuiz = GetQuizRequest(courseID: courseID, quizID: quizID)
        let getSubmission = GetQuizSubmissionRequest(courseID: courseID, quizID: quizID)
        environment.api.makeRequest(getQuiz) { apiQuiz, urlResponse, error in
            guard error == nil else { return completionHandler(nil, urlResponse, error) }
            environment.api.makeRequest(getSubmission) { submissionResponse, urlResponse, error in
                let response = Response(quiz: apiQuiz, submission: submissionResponse?.quiz_submissions.first)
                completionHandler(response, urlResponse, error)
            }
        }
    }

    public func write(response: Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let apiQuiz = response?.quiz else { return }
        let quiz = Quiz.save(apiQuiz, in: client)
        quiz.courseID = courseID
        let submission = response?.submission.flatMap { QuizSubmission.save($0, in: client) }
        submission?.quiz = quiz
        quiz.submission = submission
    }
}
