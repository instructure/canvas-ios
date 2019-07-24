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

public class GetQuizSubmissions: APIUseCase {
    public typealias Model = QuizSubmission

    public let courseID: String
    public let quizID: String

    public init(courseID: String, quizID: String) {
        self.courseID = courseID
        self.quizID = quizID
    }

    public var cacheKey: String? {
        return "get-courses-\(courseID)-quizzes-\(quizID)-submissions"
    }

    public var request: GetQuizSubmissionsRequest {
        return GetQuizSubmissionsRequest(courseID: courseID, quizID: quizID)
    }

    public var scope: Scope {
        return .where(#keyPath(QuizSubmission.quizID), equals: quizID, orderBy: #keyPath(QuizSubmission.attempt), ascending: false)
    }

    public func write(response: GetQuizSubmissionsRequest.Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let items = response?.quiz_submissions.sorted(by: { $0.attempt > $1.attempt }) else { return }
        if let item = items.first {
            let quiz: Quiz? = client.first(where: #keyPath(Quiz.id), equals: quizID)
            quiz?.submission = QuizSubmission.save(item, in: client)
        }
        for item in items.dropFirst() {
            QuizSubmission.save(item, in: client)
        }
    }
}
