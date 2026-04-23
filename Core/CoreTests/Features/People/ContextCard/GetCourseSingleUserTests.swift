//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

@testable import Core
import XCTest
import TestsFoundation

class GetCourseSingleUserTests: CoreTestCase {
    func testRequest() {
        let useCase = GetCourseSingleUser(context: .course("1"), userID: "2")
        XCTAssertEqual(useCase.request.path, "courses/1/users/2")
    }

    func testScope() {
        let useCase = GetCourseSingleUser(context: .course("1"), userID: "2")
        let one = User.make(from: .make(id: "2"), courseID: "1")
        User.make(from: .make(id: "3"), courseID: "1")

        let users: [User] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(one, users.first)
    }
}
