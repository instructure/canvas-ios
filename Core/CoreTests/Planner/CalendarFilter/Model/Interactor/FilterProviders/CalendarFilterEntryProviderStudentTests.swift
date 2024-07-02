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

class CalendarFilterEntryProviderStudentTests: CoreTestCase {

    func testFetch() {
        AppEnvironment.shared.currentSession = .init(
            baseURL: URL(string: "/")!,
            userID: "testStudentId",
            userName: "testStudent"
        )
        let coursesRequest = GetCurrentUserCoursesRequest(
            enrollmentState: .active,
            state: [.current_and_concluded],
            includes: []
        )
        let groupsRequest = GetGroupsRequest(context: .currentUser)

        api.mock(coursesRequest, value: [
                .make(id: "c1"),
                .make(id: "c2", workflow_state: .unpublished)
            ]
        )
        api.mock(groupsRequest, value: [.make(id: "g1")])

        // WHEN
        let testee = CalendarFilterEntryProviderStudent()

        // THEN
        XCTAssertFirstValueAndCompletion(testee.make(ignoreCache: false)!) { filters in
            let sortedFilters = filters.sorted()
            XCTAssertEqual(sortedFilters.count, 3)
            XCTAssertEqual(sortedFilters[0].context, .user("testStudentId"))
            XCTAssertEqual(sortedFilters[0].name, "testStudent")
            XCTAssertEqual(sortedFilters[1].context, .course("c1"))
            XCTAssertEqual(sortedFilters[1].name, "Course One")
            XCTAssertEqual(sortedFilters[2].context, .group("g1"))
            XCTAssertEqual(sortedFilters[2].name, "Group One")
        }
    }
}
