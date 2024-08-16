//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import XCTest
@testable import Core
@testable import Parent

class GetObservedStudentsTests: ParentTestCase {
    func testSavesUserWithObserverID() {
        let useCase = GetObservedStudents(observerID: "1")
        let userA = APIUser.make(id: "1", name: "A")
        let userB = APIUser.make(id: "2", name: "B")
        let enrollments: [APIEnrollment] = [
            .make(id: "1", course_id: "1", type: "ObserverEnrollment", observed_user: userB),
            .make(id: "2", course_id: "2", type: "ObserverEnrollment", observed_user: userA),
            .make(id: "3", course_id: "3", type: "ObserverEnrollment", observed_user: userA)
        ]
        useCase.write(response: enrollments, urlResponse: nil, to: databaseClient)

        let users: [User] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users.first?.observerID, "1")
    }

    func testCacheKey() {
        let useCase = GetObservedStudents(observerID: "1")
        XCTAssertEqual(useCase.cacheKey, "get-observed-students-1")
    }

    func testRequest() {
        let useCase = GetObservedStudents(observerID: "1")
        XCTAssertEqual(useCase.request.path, "users/self/enrollments")
    }
}
