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

import Foundation
import XCTest
@testable import Core

class GetQuizSubmissionUsersTest: CoreTestCase {
    let courseID = "1"

    func testProperties() {
        let useCase = GetQuizSubmissionUsers(courseID: courseID)
        XCTAssertEqual(useCase.cacheKey, "quizsubmission-users-1")
        XCTAssertEqual(useCase.request.context.id, courseID)
        XCTAssertEqual(useCase.request.enrollment_type, .student)
        XCTAssertNil(useCase.request.search_term)

        XCTAssertEqual(useCase.scope, Scope.where(#keyPath(QuizSubmissionUser.courseID), equals: courseID, orderBy: #keyPath(QuizSubmissionUser.name)))
    }

    func testWriteNothing() {
        GetQuizSubmissionUsers(courseID: courseID).write(response: nil, urlResponse: nil, to: databaseClient)
        let users: [QuizSubmissionUser] = databaseClient.fetch()
        XCTAssertEqual(users.count, 0)
    }

    func testWrite() {
        let useCase = GetQuizSubmissionUsers(courseID: courseID)
        let response = [APIUser.make(id: "1"), APIUser.make(id: "2")]

        useCase.write(response: response, urlResponse: nil, to: databaseClient)
        XCTAssertNoThrow(try databaseClient.save())

        let users: [QuizSubmissionUser] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(users.count, 2)
    }
}
