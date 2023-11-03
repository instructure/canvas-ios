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

@testable import Core
import Foundation
import XCTest

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

class GetGroupTests: CoreTestCase {
    func testGetGroup() {
        XCTAssertEqual(GetGroup(groupID: "1").cacheKey, "get-group-1")
        XCTAssertEqual(GetGroup(groupID: "1").scope, Scope(predicate: NSPredicate(format: "%K == %@", #keyPath(Group.id), "1"), order: []))
    }
}

class GetDashboardGroupsTest: CoreTestCase {
    func testItSavesUserGroups() {
        let request = GetFavoriteGroupsRequest(context: .currentUser)
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
        let request = GetFavoriteGroupsRequest(context: .currentUser)
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
        let request = GetFavoriteGroupsRequest(context: .currentUser)
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

    func testItDoesNotShowRestrictedCourseGroups() {
        let course: Course = .make(from: .make(access_restricted_by_date: true))
        let group = Group.make(from: .make(id: "1", name: "Old Name"), showOnDashboard: true, course: course)
        let getGroup = GetDashboardGroups()
        var groups: [Group] = databaseClient.fetch(.all, sortDescriptors: getGroup.scope.order)
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups.first, group)
        groups = databaseClient.fetch(getGroup.scope.predicate, sortDescriptors: getGroup.scope.order)
        XCTAssertEqual(groups.count, 0)
    }

    func testShowsGroupsWithoutCourse() {
        let group = Group.make(from: .make(id: "1", name: "Old Name"), showOnDashboard: true)
        let getGroup = GetDashboardGroups()
        let groups: [Group] = databaseClient.fetch(getGroup.scope.predicate, sortDescriptors: getGroup.scope.order)
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups.first, group)
        XCTAssertNil(groups.first?.course)
    }
}

class MarkFavoriteGroupTests: CoreTestCase {
    func testCacheKey() {
        XCTAssertEqual(MarkFavoriteGroup(groupID: "1", markAsFavorite: true).cacheKey, nil)
    }

    func testScope() {
        XCTAssertEqual(MarkFavoriteGroup(groupID: "1", markAsFavorite: true).scope, .where(#keyPath(Group.id), equals: "1"))
    }

    func testItWritesData() {
        let group = Group.make()
        let groupItem = CDAllCoursesGroupItem.save(.make(), in: databaseClient)

        let testee = MarkFavoriteGroup(groupID: "1", markAsFavorite: true)
        testee.write(response: APIFavorite(context_id: ID("1"), context_type: "group"), urlResponse: nil, to: databaseClient)

        XCTAssertTrue(group.isFavorite)
        XCTAssertTrue(groupItem.isFavorite)
    }
}
