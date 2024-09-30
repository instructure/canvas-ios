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

class GetTeacherCalendarFiltersTests: CoreTestCase {

    func test_for_viewing() {
        let coursesRequest = GetCurrentUserCoursesRequest(
            enrollmentState: .active,
            state: [],
            includes: []
        )
        api.mock(coursesRequest, value: [
            .make(id: "11", name: "Course 11")
        ])

        let groupsRequest = GetGroupsRequest(context: .currentUser)
        api.mock(
            groupsRequest,
            value: [
                .make(id: "Some-Group", course_id: "11"),
                .make(id: "Group-22", course_id: "22"),
                .make(id: "Another-Group", course_id: nil)
            ]
        )

        let testee = GetTeacherCalendarFilters(currentUserName: "", currentUserId: "", purpose: .viewing)
        let requestCompleted = expectation(description: "requestCompleted")

        testee.makeRequest(environment: environment) { response, _, _ in
            XCTAssertEqual(response?.groups.count, 2)
            XCTAssertEqual(response?.groups[0].id, "Some-Group")
            XCTAssertEqual(response?.groups[1].id, "Another-Group")

            XCTAssertEqual(response?.courses.count, 1)
            XCTAssertEqual(response?.courses.first?.id, "11")
            requestCompleted.fulfill()
        }

        wait(for: [requestCompleted])
    }

    func test_for_creation() {
        let coursesRequest = GetCoursesRequest(
            enrollmentState: .active,
            enrollmentType: .teacher,
            state: [],
            perPage: 100
        )
        api.mock(coursesRequest, value: [
            .make(id: "22", name: "Course 22"),
            .make(id: "77", name: "Course 77")
        ])

        let groupsRequest = GetGroupsRequest(context: .currentUser)
        api.mock(
            groupsRequest,
            value: [
                .make(id: "Some-Group", course_id: "22")
            ]
        )

        let testee = GetTeacherCalendarFilters(currentUserName: "", currentUserId: "", purpose: .creating)
        let requestCompleted = expectation(description: "requestCompleted")

        testee.makeRequest(environment: environment) { response, _, _ in
            XCTAssertEqual(response?.groups.count, 1)
            XCTAssertEqual(response?.groups.first?.id, "Some-Group")

            XCTAssertEqual(response?.courses.count, 2)
            XCTAssertEqual(response?.courses[0].id, "22")
            XCTAssertEqual(response?.courses[1].id, "77")

            requestCompleted.fulfill()
        }

        wait(for: [requestCompleted])
    }
}
