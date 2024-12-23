//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

class APIGroupTests: XCTestCase {
    func testGetGroupsRequest() {
        XCTAssertEqual(GetGroupsRequest(context: .course("2")).path, "courses/2/groups")
        XCTAssertEqual(GetGroupsRequest(context: .course("2")).queryItems, [
            URLQueryItem(name: "include[]", value: "favorites"),
            URLQueryItem(name: "include[]", value: "can_access"),
            URLQueryItem(name: "per_page", value: "100")
        ])
    }

    func testFavoriteGroupsRequest() {
        XCTAssertEqual(GetFavoriteGroupsRequest(context: .user("1")).path, "users/1/favorites/groups")
        XCTAssertEqual(GetFavoriteGroupsRequest(context: .user("1")).queryItems, [
            URLQueryItem(name: "per_page", value: "100")
        ])
    }

    func testGetGroupUsersRequest() {
        XCTAssertEqual(GetGroupUsersRequest(groupID: "2").path, "groups/2/users")
        XCTAssertEqual(GetGroupUsersRequest(groupID: "2").queryItems, [
            URLQueryItem(name: "include[]", value: "avatar_url")
        ])
    }

    func testGetGroupRequest() {
        XCTAssertEqual(GetGroupRequest(id: "2").path, "groups/2")
    }
}
