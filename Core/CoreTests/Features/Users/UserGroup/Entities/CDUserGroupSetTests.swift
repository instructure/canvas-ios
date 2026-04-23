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

class CDUserGroupSetTests: CoreTestCase {

    func testSave() {
        // Test creating new group set with comprehensive group data
        let groupSetData = GetUserGroupsResponse.GroupSet(
            _id: "groupset-1",
            name: "Test Group Set",
            groups: [
                GetUserGroupsResponse.Group(
                    _id: "group-1",
                    name: "Collaborative Group",
                    nonCollaborative: false,
                    membersConnection: GetUserGroupsResponse.MembersConnection(nodes: [])
                ),
                GetUserGroupsResponse.Group(
                    _id: "group-2",
                    name: "Differentiation Tag",
                    nonCollaborative: true,
                    membersConnection: GetUserGroupsResponse.MembersConnection(
                        nodes: [
                            GetUserGroupsResponse.MembersConnection.Member(
                                user: GetUserGroupsResponse.MembersConnection.Member.User(_id: "user-1")
                            ),
                            GetUserGroupsResponse.MembersConnection.Member(
                                user: GetUserGroupsResponse.MembersConnection.Member.User(_id: "user-2")
                            )
                        ]
                    )
                )
            ]
        )

        let groupSet = CDUserGroupSet.save(groupSetData, courseId: "course-123", in: databaseClient)

        // Test basic group set properties
        XCTAssertEqual(groupSet.id, "groupset-1")
        XCTAssertEqual(groupSet.name, "Test Group Set")
        XCTAssertEqual(groupSet.courseId, "course-123")
        XCTAssertNotNil(groupSet)

        // Test that associated groups were created
        XCTAssertEqual(groupSet.userGroups.count, 2)

        let groups = Array(groupSet.userGroups).sorted { $0.id < $1.id }

        // Test collaborative group properties
        XCTAssertEqual(groups[0].id, "group-1")
        XCTAssertEqual(groups[0].name, "Collaborative Group")
        XCTAssertEqual(groups[0].isDifferentiationTag, false)
        XCTAssertEqual(groups[0].parentGroupSet, groupSet)
        XCTAssertEqual(groups[0].userIdsInGroup, Set<String>())

        // Test differentiation tag properties and member handling
        XCTAssertEqual(groups[1].id, "group-2")
        XCTAssertEqual(groups[1].name, "Differentiation Tag")
        XCTAssertEqual(groups[1].isDifferentiationTag, true)
        XCTAssertEqual(groups[1].parentGroupSet, groupSet)
        XCTAssertEqual(groups[1].userIdsInGroup, Set(["user-1", "user-2"]))

        // Test bidirectional relationships
        XCTAssertEqual(groups[0].parentGroupSet, groupSet)
        XCTAssertEqual(groups[1].parentGroupSet, groupSet)
        XCTAssertTrue(groupSet.userGroups.contains(groups[0]))
        XCTAssertTrue(groupSet.userGroups.contains(groups[1]))
    }
}
