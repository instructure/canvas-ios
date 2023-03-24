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

import CoreData
import Foundation

public class GetQuizSubmissionUsers: CollectionUseCase {
    public typealias Model = QuizSubmissionUser

    public let courseID: String

    public init(courseID: String) {
        self.courseID = courseID
    }

    public var cacheKey: String? { "quizsubmission-users-\(courseID)" }
    public var request: GetContextUsersRequest {
        GetContextUsersRequest(context: .course(courseID), enrollment_type: .student, search_term: nil)
    }
    public var scope: Scope {
        Scope.where(#keyPath(QuizSubmissionUser.courseID), equals: courseID, orderBy: #keyPath(QuizSubmissionUser.name))
    }

    public func write(response: [APIUser]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }
        for item in response {
            let user = QuizSubmissionUser.save(item, in: client)
            user.courseID = courseID
        }
    }
}
