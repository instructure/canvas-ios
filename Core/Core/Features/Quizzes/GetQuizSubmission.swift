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

public class GetQuizSubmission: APIUseCase {
    public typealias Model = QuizSubmission

    public let courseID: String
    public let quizID: String

    public init(courseID: String, quizID: String) {
        self.courseID = courseID
        self.quizID = quizID
    }

    public var cacheKey: String? {
        "get-courses-\(courseID)-quizzes-\(quizID)-submission"
    }

    public var request: GetQuizSubmissionRequest {
        GetQuizSubmissionRequest(courseID: courseID, quizID: quizID)
    }

    public var scope: Scope {
        .where(#keyPath(QuizSubmission.quizID), equals: quizID, orderBy: #keyPath(QuizSubmission.attempt), ascending: false)
    }

    public func write(response: GetQuizSubmissionRequest.Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response?.quiz_submissions.first else { return }
        let submission = QuizSubmission.save(item, in: client)
        let quiz: Quiz? = client.first(where: #keyPath(Quiz.id), equals: quizID)
        quiz?.submission = submission
    }
}

public class GetAllQuizSubmissions: CollectionUseCase {
    public typealias Model = QuizSubmission

    public let courseID: String
    public let quizID: String

    public init(courseID: String, quizID: String) {
        self.courseID = courseID
        self.quizID = quizID
    }

    public var cacheKey: String? {
        "get-courses-\(courseID)-quizzes-\(quizID)-submissions"
    }

    public var request: GetAllQuizSubmissionsRequest {
        GetAllQuizSubmissionsRequest(courseID: courseID, quizID: quizID, includes: [.submission], perPage: 100)
    }

    public var scope: Scope {
        .where(#keyPath(QuizSubmission.quizID), equals: quizID, orderBy: #keyPath(QuizSubmission.userID), ascending: false)
    }

    public func write(response: GetAllQuizSubmissionsRequest.Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        response?.quiz_submissions.forEach { item in
            QuizSubmission.save(item, in: client)
        }
    }
}
