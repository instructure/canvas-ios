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

import Foundation
@testable import Core
import XCTest
import TestsFoundation

class GetContextUsersTests: CoreTestCase {
    func testCacheKey() {
        XCTAssertEqual(GetContextUsers(context: ContextModel(.course, id: "1")).cacheKey, "courses/1/users")
        XCTAssertEqual(GetContextUsers(context: ContextModel(.group, id: "2")).cacheKey, "groups/2/users")
    }

    func testRequest() {
        let useCase = GetContextUsers(context: ContextModel(.course, id: "1"))
        XCTAssertEqual(useCase.request.path, "courses/1/users")
        XCTAssertEqual(useCase.request.queryItems, [
            URLQueryItem(name: "sort", value: "username"),
            URLQueryItem(name: "per_page", value: "50"),
            URLQueryItem(name: "include[]", value: "avatar_url"),
            URLQueryItem(name: "include[]", value: "enrollments"),
        ])
    }

    func testScopeCourse() {
        let useCase = GetContextUsers(context: ContextModel(.course, id: "1"))
        let one = User.make(from: .make(id: "1", sortable_name: "A"), courseID: "1")
        let two = User.make(from: .make(id: "2", sortable_name: "B"), courseID: "1")
        User.make(from: .make(id: "3"), courseID: nil)
        User.make(from: .make(id: "4"), courseID: "2")
        let users: [User] = databaseClient.fetch(useCase.scope.predicate)
        XCTAssertEqual([one, two], users)
    }

    func testScopeGroup() {
        let useCase = GetContextUsers(context: ContextModel(.group, id: "1"))
        let one = User.make(from: .make(id: "1", sortable_name: "A"), groupID: "1")
        let two = User.make(from: .make(id: "2", sortable_name: "B"), groupID: "1")
        User.make(from: .make(id: "3"), groupID: nil)
        User.make(from: .make(id: "4"), groupID: "2")
        let users: [User] = databaseClient.fetch(useCase.scope.predicate)
        XCTAssertEqual([one, two], users)
    }

    func testWriteCourseUsers() {
        let useCase = GetContextUsers(context: ContextModel(.course, id: "1"))
        let response = [APIUser.make(id: "1"), APIUser.make(id: "2")]
        useCase.write(response: response, urlResponse: nil, to: databaseClient)
        let user: [User] = databaseClient.fetch()
        XCTAssertEqual(user.count, 2)
        XCTAssertEqual(user.first?.courseID, "1")
        XCTAssertEqual(user.last?.courseID, "1")
    }

    func testWriteGroupUsers() {
        let useCase = GetContextUsers(context: ContextModel(.group, id: "1"))
        let response = [APIUser.make(id: "1"), APIUser.make(id: "2")]
        useCase.write(response: response, urlResponse: nil, to: databaseClient)
        let user: [User] = databaseClient.fetch()
        XCTAssertEqual(user.count, 2)
        XCTAssertEqual(user.first?.groupID, "1")
        XCTAssertEqual(user.last?.groupID, "1")
    }
}
