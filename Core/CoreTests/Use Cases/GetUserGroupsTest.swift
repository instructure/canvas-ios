//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

class GetUserGroupsTest: CoreTestCase {
    func testItSavesUserGroups() {
        let request = GetGroupsRequest(context: ContextModel.currentUser)
        let group = APIGroup.make(id: "1", name: "Group One", members_count: 2)
        api.mock(request, value: [group])

        let getUserGroups = GetUserGroups()
        getUserGroups.write(response: [group], urlResponse: nil, to: databaseClient)

        let groups: [Group] = databaseClient.fetch()
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups.first?.id, "1")
        XCTAssertEqual(groups.first?.showOnDashboard, true)
    }

    func testItDeletesOldUserGroups() {
        let old = Group.make(showOnDashboard: true)
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
        let notMember = Group.make(showOnDashboard: false)
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
