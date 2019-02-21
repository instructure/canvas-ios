//
// Copyright (C) 2018-present Instructure, Inc.
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

import Foundation
import XCTest
@testable import Core

class GetUserGroupsTest: CoreTestCase {
    func testItSavesUserGroups() {
        let request = GetGroupsRequest(context: ContextModel.currentUser)
        let group = APIGroup.make(["id": "1", "name": "Group One", "members_count": 2])
        api.mock(request, value: [group])

        let getUserGroups = GetUserGroups()
        try! getUserGroups.write(response: [group], urlResponse: nil, to: databaseClient)

        let groups: [Group] = databaseClient.fetch()
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups.first?.id, "1")
        XCTAssertEqual(groups.first?.showOnDashboard, true)
    }

    func testItDeletesOldUserGroups() {
        let old = Group.make(["showOnDashboard": true])
        let request = GetGroupsRequest(context: ContextModel.currentUser)
        api.mock(request, value: [])

        let expectation = XCTestExpectation(description: "fetch")
        let getUserGroups = GetUserGroups()
        getUserGroups.fetch(environment: environment, force: true) { _, _, _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)

        databaseClient.refresh()
        let groups: [Group] = databaseClient.fetch()
        XCTAssertFalse(groups.contains(old))
    }

    func testItDoesNotDeleteNonUserGroups() {
        let notMember = Group.make(["showOnDashboard": false])
        let request = GetGroupsRequest(context: ContextModel.currentUser)
        api.mock(request, value: [])

        let expectation = XCTestExpectation(description: "fetch")
        let getUserGroups = GetUserGroups()
        getUserGroups.fetch(environment: environment, force: true) { _, _, _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)

        let groups: [Group] = databaseClient.fetch()
        XCTAssert(groups.contains(notMember))
    }
}
