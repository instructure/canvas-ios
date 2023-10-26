//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Combine
@testable import Core
import TestsFoundation
import XCTest

class CourseListInteractorLiveTests: CoreTestCase {
    private var subscriptions = Set<AnyCancellable>()
    private var testee: CourseListInteractorLive!

    override func setUp() {
        super.setUp()

        let activeCourseRequest = GetCourseListCourses(enrollmentState: .active)
        api.mock(activeCourseRequest, value: [.make(id: "1", name: "A")])
        let pastCourseRequest = GetCourseListCourses(enrollmentState: .completed)
        api.mock(pastCourseRequest, value: [.make(id: "2", name: "AB")])
        let futureCourseRequest = GetCourseListCourses(enrollmentState: .invited_or_pending)
        api.mock(futureCourseRequest, value: [.make(id: "3", name: "ABC", workflow_state: .available)])

        testee = CourseListInteractorLive(env: environment)
        testee.loadAsync()
        waitForState(.data)
    }

    override func tearDown() {
        subscriptions.removeAll()
        testee = nil
        super.tearDown()
    }

    func testPopulatesListItems() {
        XCTAssertEqual(testee.state.value, .data)
        XCTAssertEqual(testee.courseList.value.current.map { $0.courseId }, ["1"])
        XCTAssertEqual(testee.courseList.value.past.map { $0.courseId }, ["2"])
        XCTAssertEqual(testee.courseList.value.future.map { $0.courseId }, ["3"])
    }

    func testFilter() {
        testee
            .setFilter("b")
            .sink()
            .store(in: &subscriptions)

        XCTAssertEqual(testee.state.value, .data)
        XCTAssertEqual(testee.courseList.value.current.map { $0.courseId }, [])
        XCTAssertEqual(testee.courseList.value.past.map { $0.courseId }, ["2"])
        XCTAssertEqual(testee.courseList.value.future.map { $0.courseId }, ["3"])
    }

    func testRefresh() {
        let activeCourseRequest = GetCourseListCourses(enrollmentState: .active)

        api.mock(activeCourseRequest, value: nil, response: nil, error: NSError.instructureError("Failed"))
        performRefresh()
        waitForState(.error)

        api.mock(activeCourseRequest, value: [.make(id: "4", name: "ABCD")])
        performRefresh()
        waitForState(.data)

        XCTAssertEqual(testee.state.value, .data)
        XCTAssertEqual(testee.courseList.value.current.map { $0.courseId }, ["4"])
        XCTAssertEqual(testee.courseList.value.past.map { $0.courseId }, ["2"])
        XCTAssertEqual(testee.courseList.value.future.map { $0.courseId }, ["3"])
    }

    func testFutureUnpublishedCoursesAreHiddenForStudents() {
        let futureCourseRequest = GetCourseListCourses(enrollmentState: .invited_or_pending)
        api.mock(futureCourseRequest, value: [
            .make(id: "3", name: "ABC", workflow_state: .available),
            .make(id: "4", name: "unpublished", workflow_state: .unpublished),
        ])

        performRefresh()
        waitUntil(shouldFail: true) {
            testee.courseList.value.future.map { $0.courseId } == ["3"]
        }
    }

    func testFutureUnpublishedCoursesAreShownForTeachers() {
        environment.app = .teacher

        let futureCourseRequest = GetCourseListCourses(enrollmentState: .invited_or_pending)
        api.mock(futureCourseRequest, value: [
            .make(id: "3", name: "ABC", workflow_state: .available),
            .make(id: "4", name: "unpublished", workflow_state: .unpublished),
        ])

        performRefresh()
        waitUntil(shouldFail: true) {
            testee.courseList.value.future.map { $0.courseId } == ["3", "4"]
        }
    }

    private func performRefresh() {
        let refreshed = expectation(description: "Expected state reached")
        testee
            .refresh()
            .sink { refreshed.fulfill() }
            .store(in: &subscriptions)
        wait(for: [refreshed], timeout: 1)
    }

    private func waitForState(_ state: StoreState) {
        let stateUpdate = expectation(description: "Expected state reached")
        stateUpdate.assertForOverFulfill = false
        let subscription = testee
            .state
            .sink {
                if $0 == state {
                    stateUpdate.fulfill()
                }
            }
        wait(for: [stateUpdate], timeout: 1)
        subscription.cancel()
    }
}
