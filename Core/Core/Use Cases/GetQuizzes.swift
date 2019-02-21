//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public struct GetQuizzes: CollectionUseCase {
    public typealias Model = Quiz

    public let courseID: String

    public init(courseID: String) {
        self.courseID = courseID
    }

    public var cacheKey: String {
        return "get-\(courseID)-quizzes"
    }

    public var request: GetQuizzesRequest {
        return GetQuizzesRequest(courseID: courseID)
    }

    public var scope: Scope {
        return .where(#keyPath(Quiz.courseID), equals: courseID, orderBy: #keyPath(Quiz.title), naturally: true)
    }

    public func write(response: [APIQuiz]?, urlResponse: URLResponse?, to client: PersistenceClient) throws {
        guard let response = response else {
            return
        }
        for item in response {
            let predicate = NSPredicate(format: "%K == %@", #keyPath(Quiz.htmlURL), item.html_url as CVarArg)
            let model: Quiz = client.fetch(predicate).first ?? client.insert()
            model.courseID = courseID
            model.details = item.description
            model.dueAt = item.due_at
            model.htmlURL = item.html_url
            model.id = item.id
            model.lockAt = item.lock_at
            model.pointsPossible = item.points_possible
            model.questionCount = item.question_count
            model.quizType = item.quiz_type
            model.title = item.title
        }
    }
}
