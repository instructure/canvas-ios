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

class UserTests: CoreTestCase {
    func testSave() {
        let item = APIUser.make(
            id: "1",
            name: "John Doe",
            sortable_name: "Doe, John",
            short_name: "JD",
            avatar_url: .make(),
            enrollments: [.make(user_id: "1", role: "Custom Role")],
            email: "john@doe.com"
        )
        let user = User.save(item, in: databaseClient)
        XCTAssertEqual(user.id, "1")
        XCTAssertEqual(user.name, "John Doe")
        XCTAssertEqual(user.sortableName, "Doe, John")
        XCTAssertEqual(user.shortName, "JD")
        XCTAssertEqual(user.avatarURL, .make())
        XCTAssertEqual(user.email, "john@doe.com")
        XCTAssertNotNil(user.enrollments)
        XCTAssertEqual(user.enrollments.count, 1)
        XCTAssertEqual(user.enrollments.first?.role, "Custom Role")
    }

    func testSaveDoesNotOverwriteEnrollments() {
        let enrollment = Enrollment.make(from: .make(id: "1", user_id: "1"))
        let user = User.make(from: .make(id: "1", name: "A", enrollments: [.make(user_id: "1")]))
        let api = APIUser.make(id: "1", name: "B", enrollments: nil)
        User.save(api, in: databaseClient)
        databaseClient.refresh(user, mergeChanges: true)

        let fetchedEnrollments: [Enrollment] = databaseClient.fetch()
        XCTAssertEqual(user.name, "B")
        XCTAssertEqual(user.enrollments.count, 1)
        XCTAssertEqual(fetchedEnrollments.count, 1)
        XCTAssertEqual(fetchedEnrollments[0].objectID, enrollment.objectID)
    }

    func testDisplayName() {
        XCTAssertEqual(User.displayName("Jane Doe", pronouns: nil), "Jane Doe")
        XCTAssertEqual(User.displayName("Jane Doe", pronouns: "She/Her"), "Jane Doe (She/Her)")
    }

    func testConnectsUserToGroups() {
        let groupSet: CDUserGroupSet = databaseClient.insert()
        groupSet.id = "groupset"
        groupSet.name = "Test Group Set"

        let userGroup1: CDUserGroup = databaseClient.insert()
        userGroup1.id = "group1"
        userGroup1.name = "Group 1"
        userGroup1.isDifferentiationTag = false
        userGroup1.parentGroupSet = groupSet
        userGroup1.userIdsInGroup = Set(["user1", "user2"])

        let userGroup2: CDUserGroup = databaseClient.insert()
        userGroup2.id = "group2"
        userGroup2.name = "Group 2"
        userGroup2.isDifferentiationTag = true
        userGroup2.parentGroupSet = groupSet
        userGroup2.userIdsInGroup = Set(["user2", "user3"])

        let userGroup3: CDUserGroup = databaseClient.insert()
        userGroup3.id = "group3"
        userGroup3.name = "Group 3"
        userGroup3.isDifferentiationTag = false
        userGroup3.parentGroupSet = groupSet
        userGroup3.userIdsInGroup = Set(["user3", "user4"])

        let apiUser = APIUser.make(id: "user2", name: "Test User")

        // WHEN
        let user = User.save(apiUser, in: databaseClient)

        // THEN
        XCTAssertEqual(
            Set(user.userGroups.map { $0.id }),
            Set(["group1", "group2"])
        )
    }
}
