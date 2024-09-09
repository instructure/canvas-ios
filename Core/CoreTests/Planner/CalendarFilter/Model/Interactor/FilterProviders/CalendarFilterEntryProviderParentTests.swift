//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import XCTest

class CalendarFilterEntryProviderParentTests: CoreTestCase {

    func testFetch() {
        AppEnvironment.shared.currentSession = .init(
            baseURL: .make(),
            userID: "testParentId",
            userName: "testParent"
        )
        let coursesRequest = GetCoursesRequest(
            enrollmentState: .active,
            enrollmentType: .observer,
            state: [.available],
            perPage: 100
        )
        let groupsRequest = GetGroupsRequest(context: .currentUser)

        api.mock(coursesRequest, value: [
                .make(id: "c1", enrollments: [.make(associated_user_id: "observedId")])
            ]
        )
        api.mock(groupsRequest, value: [.make(id: "g1")])

        // WHEN
        let testee = CalendarFilterEntryProviderParent(observedUserId: "observedId")

        // THEN
        XCTAssertFirstValueAndCompletion(testee.make(ignoreCache: false)!) { filters in
            let sortedFilters = filters.sorted()
            XCTAssertEqual(sortedFilters.count, 3)
            XCTAssertEqual(sortedFilters[0].context, .user("testParentId"))
            XCTAssertEqual(sortedFilters[0].name, "testParent")
            XCTAssertEqual(sortedFilters[0].observedUserId, "observedId")
            XCTAssertEqual(sortedFilters[1].context, .course("c1"))
            XCTAssertEqual(sortedFilters[1].name, "Course One")
            XCTAssertEqual(sortedFilters[1].observedUserId, "observedId")
            XCTAssertEqual(sortedFilters[2].context, .group("g1"))
            XCTAssertEqual(sortedFilters[2].name, "Group One")
            XCTAssertEqual(sortedFilters[2].observedUserId, "observedId")
        }
    }
}
