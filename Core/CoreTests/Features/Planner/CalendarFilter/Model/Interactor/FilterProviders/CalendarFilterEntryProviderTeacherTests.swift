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

class CalendarFilterEntryProviderTeacherTests: CoreTestCase {

    func testFetchForViewing() {
        AppEnvironment.shared.currentSession = .init(
            baseURL: .make(),
            userID: "testTeacherId",
            userName: "testTeacher"
        )
        let coursesRequest = GetCurrentUserCoursesRequest(
            enrollmentState: .active,
            state: [],
            includes: []
        )
        let groupsRequest = GetGroupsRequest(context: .currentUser)

        api.mock(coursesRequest, value: [
                .make(id: "c1", workflow_state: .unpublished)
            ]
        )
        api.mock(groupsRequest, value: [.make(id: "g1")])

        // WHEN
        let testee = CalendarFilterEntryProviderTeacher(purpose: .viewing)

        // THEN
        XCTAssertFirstValueAndCompletion(testee.make(ignoreCache: false)!) { filters in
            let sortedFilters = filters.sorted()
            XCTAssertEqual(sortedFilters.count, 3)
            XCTAssertEqual(sortedFilters[0].context, .user("testTeacherId"))
            XCTAssertEqual(sortedFilters[0].name, "testTeacher")
            XCTAssertEqual(sortedFilters[1].context, .course("c1"))
            XCTAssertEqual(sortedFilters[1].name, "Course One")
            XCTAssertEqual(sortedFilters[2].context, .group("g1"))
            XCTAssertEqual(sortedFilters[2].name, "Group One")
        }
    }

    func testFetchForWriting() {
        AppEnvironment.shared.currentSession = .init(
            baseURL: .make(),
            userID: "testTeacherId",
            userName: "testTeacher"
        )
        let coursesRequest = GetCoursesRequest(
            enrollmentState: .active,
            enrollmentType: .teacher,
            state: [],
            perPage: 100
        )
        let groupsRequest = GetGroupsRequest(context: .currentUser)

        let enrollment = APIEnrollment.make(
            id: nil,
            enrollment_state: .active,
            type: "teacher",
            user_id: "12",
            role: "TeacherEnrollment",
            role_id: "3"
        )

        api.mock(coursesRequest, value: [
                .make(id: "c3", name: "Course Three", workflow_state: .available, enrollments: [enrollment]),
                .make(id: "c4", name: "Course Four", workflow_state: .completed)
            ]
        )
        api.mock(groupsRequest, value: [.make(id: "g1")])

        // WHEN
        let testee = CalendarFilterEntryProviderTeacher(purpose: .creating)

        // THEN
        XCTAssertFirstValueAndCompletion(testee.make(ignoreCache: false)!) { filters in
            let sortedFilters = filters.sorted()
            XCTAssertEqual(sortedFilters.count, 4)
            XCTAssertEqual(sortedFilters[0].context, .user("testTeacherId"))
            XCTAssertEqual(sortedFilters[0].name, "testTeacher")
            XCTAssertEqual(sortedFilters[1].context, .course("c4"))
            XCTAssertEqual(sortedFilters[1].name, "Course Four")
            XCTAssertEqual(sortedFilters[2].context, .course("c3"))
            XCTAssertEqual(sortedFilters[2].name, "Course Three")
            XCTAssertEqual(sortedFilters[3].context, .group("g1"))
            XCTAssertEqual(sortedFilters[3].name, "Group One")
        }
    }
}
