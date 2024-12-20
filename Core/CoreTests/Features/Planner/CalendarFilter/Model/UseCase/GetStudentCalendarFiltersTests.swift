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

class GetStudentCalendarFiltersTests: CoreTestCase {

    /// If a course's end date has passed and "Restrict students from viewing course after course end date"
    /// is checked then fetching events for a group in this course will give 403 unauthorized.
    func testRemovesCourseGroupsWhereCourseIsUnavailable() {
        let coursesRequest = GetCurrentUserCoursesRequest(
            enrollmentState: .active,
            state: [],
            includes: []
        )
        api.mock(coursesRequest, value: [])

        let groupsRequest = GetGroupsRequest(context: .currentUser)
        api.mock(
            groupsRequest,
            value: [
                .make(id: "LockedCourseGroup", course_id: "1"),
                .make(id: "AccountGroup", course_id: nil)
            ]
        )

        let testee = GetStudentCalendarFilters(
            currentUserName: "",
            currentUserId: "",
            states: [],
            filterUnpublishedCourses: true
        )
        let requestCompleted = expectation(description: "requestCompleted")

        testee.makeRequest(environment: environment) { response, _, _ in
            XCTAssertEqual(response?.groups.count, 1)
            XCTAssertEqual(response?.groups.first?.id, "AccountGroup")
            requestCompleted.fulfill()
        }

        wait(for: [requestCompleted])
    }
}
