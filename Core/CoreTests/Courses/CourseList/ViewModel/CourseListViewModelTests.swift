//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import TestsFoundation

class CourseListViewModelTests: CoreTestCase {

    func testCreatesAssignmentList() {
        setupMocks()
        let testee = CourseListViewModel()

        let uiRefreshExpectation = expectation(description: "ui refresh received")
        uiRefreshExpectation.expectedFulfillmentCount = 2 // initial loading state, data state
        let refreshCallbackExpectation = expectation(description: "refresh callback called")
        let subscription = testee.$state.sink { _ in uiRefreshExpectation.fulfill() }
        testee.refresh { refreshCallbackExpectation.fulfill() }
        drainMainQueue()

        wait(for: [uiRefreshExpectation, refreshCallbackExpectation], timeout: 0.1)

        guard case .data(let sections) = testee.state else { XCTFail("No data in view model"); return }

        XCTAssertEqual(sections.current.count, 2)
        XCTAssertEqual(sections.past.count, 1)
        XCTAssertEqual(sections.future.count, 1)

        subscription.cancel()
    }

    func testFilter() {
        setupMocks()
        let testee = CourseListViewModel()
        testee.viewDidAppear()
        drainMainQueue()

        let uiRefreshExpectation = expectation(description: "ui refresh received")
        uiRefreshExpectation.expectedFulfillmentCount = 2 // initial data state, filtered data state
        let subscription = testee.$state.sink { _ in uiRefreshExpectation.fulfill() }

        testee.filter = "fall"
        wait(for: [uiRefreshExpectation], timeout: 0.1)

        guard case .data(let sections) = testee.state else { XCTFail("No data in view model"); return }

        XCTAssertEqual(sections.current.count, 1)
        XCTAssertEqual(sections.current.first?.name, "Fall 2020")
        XCTAssertEqual(sections.past.count, 0)
        XCTAssertEqual(sections.future.count, 0)

        subscription.cancel()
    }

    private func setupMocks() {
        let currentCourses: [APICourse] = [
            .make(id: "1", name: "Fall 2020", workflow_state: .available, enrollments: [.make(course_id: "1")], term: .make(name: "Fall 2020"), is_favorite: true),
            .make(id: "2", workflow_state: .available, enrollments: [.make(course_id: "2")]),
        ]

        let pastCourse: APICourse = .make(
            id: "3",
            workflow_state: .completed,
            start_at: .distantPast,
            end_at: .distantPast,
            enrollments: [ .make(
                id: "6",
                course_id: "3",
                enrollment_state: .completed,
                type: "TeacherEnrollment",
                user_id: "1",
                role: "TeacherEnrollment"
            ), ]
        )
        let futureCourse: APICourse = .make(id: "4", workflow_state: .available, start_at: .distantFuture, end_at: .distantFuture, enrollments: [.make(course_id: "4")])
        api.mock(GetAllCourses(), value: [futureCourse, pastCourse] + currentCourses)

        // Enrollments mock
        let enrollments: [APIEnrollment] = [
            currentCourses[0].enrollments![0],
            currentCourses[1].enrollments![0],
        ]
        let request = GetEnrollmentsRequest(context: .currentUser, states: [.active])
        api.mock(request, value: enrollments)
    }
}
