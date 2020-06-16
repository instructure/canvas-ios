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

class GetGroupsTest: CoreTestCase {
    func testItCreatesGroup() {
        let response = APIGroup.make()

        let getGroup = GetGroup(groupID: "1")
        getGroup.write(response: response, urlResponse: nil, to: databaseClient)

        let groups: [Group] = databaseClient.fetch()
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups.first?.id, response.id.value)
        XCTAssertEqual(groups.first?.name, response.name)
    }

    func testItUpdatesGroup() {
        let group = Group.make(from: .make(id: "1", name: "Old Name"))
        let response = APIGroup.make(id: "1", name: "New Name")

        let getGroup = GetGroup(groupID: "1")
        getGroup.write(response: response, urlResponse: nil, to: databaseClient)
        databaseClient.refresh()
        XCTAssertEqual(group.name, "New Name")
    }

    func testCacheKey() {
        let getGroup = GetGroup(groupID: "1")
        XCTAssertEqual("get-group-1", getGroup.cacheKey)
    }

    func testScope() {
        let group = Group.make(from: .make(id: "1", name: "Old Name"))
        let getGroup = GetGroup(groupID: "1")

        let groups: [Group] = databaseClient.fetch(getGroup.scope.predicate, sortDescriptors: getGroup.scope.order)

        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups.first, group)
    }

    func testGetGroups() {
        XCTAssertEqual(GetGroups().cacheKey, "users/self/groups")
        XCTAssertEqual(GetGroups().request.context.canvasContextID, "user_self")
        XCTAssertEqual(GetGroups(context: .course("2")).cacheKey, "courses/2/groups")
        XCTAssertEqual(GetGroups(context: .account("7")).request.context.canvasContextID, "account_7")
    }
}

class GetDashboardGroupsTest: CoreTestCase {
    func testItSavesUserGroups() {
        let request = GetGroupsRequest(context: .currentUser)
        let group = APIGroup.make(id: "1", name: "Group One", members_count: 2)
        api.mock(request, value: [group])

        let getUserGroups = GetDashboardGroups()
        getUserGroups.write(response: [group], urlResponse: nil, to: databaseClient)

        let groups: [Group] = databaseClient.fetch()
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups.first?.id, "1")
        XCTAssertEqual(groups.first?.showOnDashboard, true)
    }

    func testItDeletesOldUserGroups() {
        let old = Group.make(showOnDashboard: true)
        let request = GetGroupsRequest(context: .currentUser)
        api.mock(request, value: [])

        let expectation = XCTestExpectation(description: "fetch")
        let getUserGroups = GetDashboardGroups()
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
        let request = GetGroupsRequest(context: .currentUser)
        api.mock(request, value: [])

        let expectation = XCTestExpectation(description: "fetch")
        let getUserGroups = GetDashboardGroups()
        getUserGroups.fetch(environment: environment, force: true) { _, _, _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)

        let groups: [Group] = databaseClient.fetch()
        XCTAssert(groups.contains(notMember))
    }
}
