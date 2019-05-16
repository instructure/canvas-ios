//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
@testable import Core

class APIGroupRequestableTests: XCTestCase {
    func testGetGroupsRequest() {
        XCTAssertEqual(GetGroupsRequest(context: ContextModel(.course, id: "2")).path, "courses/2/groups")
        XCTAssertEqual(GetGroupsRequest(context: ContextModel(.course, id: "2")).queryItems, [
            URLQueryItem(name: "include[]", value: "users"),
        ])
    }

    func testGetGroupUsersRequest() {
        XCTAssertEqual(GetGroupUsersRequest(groupID: "2").path, "groups/2/users")
        XCTAssertEqual(GetGroupUsersRequest(groupID: "2").queryItems, [
            URLQueryItem(name: "include[]", value: "avatar_url"),
        ])
    }

    func testGetGroupRequest() {
        XCTAssertEqual(GetGroupRequest(id: "2").path, "groups/2")
    }
}
