//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

class CDUserGroupTests: CoreTestCase {

    func test_save() {
        let groupSet = CDUserGroupSet(context: databaseClient)
        groupSet.id = "group-set-1"
        groupSet.name = "Test Group Set"
        groupSet.courseId = "course-1"

        // Create some test users
        let user1 = User.save(APIUser.make(id: "user-1", name: "User One"), in: databaseClient)
        let user2 = User.save(APIUser.make(id: "user-2", name: "User Two"), in: databaseClient)
        let user3 = User.save(APIUser.make(id: "user-3", name: "User Three"), in: databaseClient)

        let groupData = GetUserGroupsResponse.Group(
            _id: "group-1",
            name: "Test Group",
            nonCollaborative: true,
            membersConnection: .init(
                nodes: [
                    .init(user: .init(_id: "user-1")),
                    .init(user: .init(_id: "user-2"))
                ]
            )
        )

        let group = CDUserGroup.save(groupData, parentGroupSet: groupSet, in: databaseClient)

        // Test that userIdsInGroup contains the correct IDs
        XCTAssertEqual(group.userIdsInGroup, Set(["user-1", "user-2"]))

        // Test that usersInGroup contains the actual User objects
        XCTAssertEqual(group.usersInGroup.count, 2)
        XCTAssertTrue(group.usersInGroup.contains(user1))
        XCTAssertTrue(group.usersInGroup.contains(user2))
        XCTAssertFalse(group.usersInGroup.contains(user3))

        // Test the relationship from user side
        XCTAssertTrue(user1.userGroups.contains(group))
        XCTAssertTrue(user2.userGroups.contains(group))
        XCTAssertFalse(user3.userGroups.contains(group))

        XCTAssertEqual(group.id, "group-1")
        XCTAssertEqual(group.name, "Test Group")
        XCTAssertEqual(group.isDifferentiationTag, true)
        XCTAssertEqual(group.parentGroupSet, groupSet)
        XCTAssertEqual(group.userIdsInGroup, Set(["user-1", "user-2"]))
    }
}
