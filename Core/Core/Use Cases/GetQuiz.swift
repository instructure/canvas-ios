//
// Copyright (C) 2019-present Instructure, Inc.
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
        guard let response = response else { return }
        let model = Quiz.save(response, in: client)
        model.courseID = courseID
    }
}
