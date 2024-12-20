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
        XCTAssertEqual(GetContextUsers(context: .course("1")).cacheKey, nil)
    }

    func testRequest() {
        let useCase = GetContextUsers(context: .course("1"))
        XCTAssertEqual(useCase.request.path, "courses/1/users")
        XCTAssertEqual(useCase.request.queryItems, [
            URLQueryItem(name: "exclude_inactive", value: "true"),
            URLQueryItem(name: "sort", value: "username"),
            URLQueryItem(name: "per_page", value: "50"),
            URLQueryItem(name: "include[]", value: "avatar_url"),
            URLQueryItem(name: "include[]", value: "enrollments")
        ])
        let useCase2 = GetContextUsers(context: .group("1"), type: .ta, search: "fred")
        XCTAssertEqual(useCase2.request.path, "groups/1/users")
        XCTAssertEqual(useCase2.request.queryItems, [
            URLQueryItem(name: "exclude_inactive", value: "true"),
            URLQueryItem(name: "sort", value: "username"),
            URLQueryItem(name: "per_page", value: "50"),
            URLQueryItem(name: "include[]", value: "avatar_url"),
            URLQueryItem(name: "include[]", value: "enrollments"),
            URLQueryItem(name: "enrollment_type", value: "ta"),
            URLQueryItem(name: "search_term", value: "fred")
        ])
    }

    func testScopeCourse() {
        let useCase = GetContextUsers(context: .course("1"))
        let one = User.make(from: .make(id: "1", sortable_name: "A"), courseID: "1")
        let two = User.make(from: .make(id: "2", sortable_name: "B"), courseID: "1")
        User.make(from: .make(id: "3"), courseID: nil)
        User.make(from: .make(id: "4"), courseID: "2")
        let users: [User] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual([one, two], users)
    }

    func testScopeGroup() {
        let useCase = GetContextUsers(context: .group("1"))
        let one = User.make(from: .make(id: "1", sortable_name: "A"), groupID: "1")
        let two = User.make(from: .make(id: "2", sortable_name: "B"), groupID: "1")
        User.make(from: .make(id: "3"), groupID: nil)
        User.make(from: .make(id: "4"), groupID: "2")
        let users: [User] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual([one, two], users)
    }

    func testWriteCourseUsers() {
        let useCase = GetContextUsers(context: .course("1"))
        let response = [APIUser.make(id: "1"), APIUser.make(id: "2")]
        useCase.write(response: response, urlResponse: nil, to: databaseClient)
        let user: [User] = databaseClient.fetch()
        XCTAssertEqual(user.count, 2)
        XCTAssertEqual(user.first?.courseID, "1")
        XCTAssertEqual(user.last?.courseID, "1")
    }

    func testWriteGroupUsers() {
        let useCase = GetContextUsers(context: .group("1"))
        let response = [APIUser.make(id: "1"), APIUser.make(id: "2")]
        useCase.write(response: response, urlResponse: nil, to: databaseClient)
        let user: [User] = databaseClient.fetch()
        XCTAssertEqual(user.count, 2)
        XCTAssertEqual(user.first?.groupID, "1")
        XCTAssertEqual(user.last?.groupID, "1")
    }
}
