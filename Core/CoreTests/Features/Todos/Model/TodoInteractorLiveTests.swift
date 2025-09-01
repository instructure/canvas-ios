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

@testable import Core
import TestsFoundation
import XCTest
import Combine

class TodoInteractorLiveTests: CoreTestCase {

    private var testee: TodoInteractorLive!

    // MARK: - Setup and teardown

    override func setUp() {
        super.setUp()
        environment.currentSession = LoginSession.make(userID: "1")
        testee = TodoInteractorLive(env: environment)
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testInitialTodosIsEmpty() {
        XCTAssertFirstValue(testee.todos) { todos in
            XCTAssertEqual(todos, [])
        }
    }

    func testRefreshWithPublishedCourses() {
        // Given
        let courses = [
            makeCourse(id: "1", name: "Published Course 1"),
            makeCourse(id: "2", name: "Published Course 2"),
            makeCourse(id: "3", name: "Unpublished Course", state: .unpublished)
        ]
        let plannables = [
            makePlannable(courseId: "1", plannableId: "p1", type: "assignment", title: "Assignment 1"),
            makePlannable(courseId: "2", plannableId: "p2", type: "quiz", title: "Quiz 1", date: Clock.now.addDays(2))
        ]

        // When
        mockCourses(courses)
        mockPlannables(plannables, contextCodes: makeContextCodes(courseIds: ["1", "2"]))

        // Then
        XCTAssertFirstValueAndCompletion(testee.refresh(ignoreCache: false)) { isEmpty in
            XCTAssertFalse(isEmpty)
        }
        XCTAssertFirstValue(testee.todos) { todos in
            XCTAssertEqual(todos.count, 2)
            XCTAssertEqual(todos[0].title, "Assignment 1")
            XCTAssertEqual(todos[1].title, "Quiz 1")
        }
    }

    func testRefreshWithNoCourses() {
        // When
        mockCourses([])
        mockPlannables([], contextCodes: makeUserContextCodes())

        // Then
        XCTAssertCompletableSingleOutputEquals(testee.refresh(ignoreCache: false), true)
        XCTAssertFirstValue(testee.todos) { todos in
            XCTAssertEqual(todos, [])
        }
    }

    func testRefreshFiltersUnpublishedCourses() {
        // Given
        let courses = [
            makeCourse(id: "1", name: "Published Course"),
            makeCourse(id: "2", name: "Unpublished Course", state: .unpublished)
        ]
        let plannables = [
            makePlannable(courseId: "1", plannableId: "p1", type: "assignment", title: "Assignment 1")
        ]

        // When
        mockCourses(courses)
        mockPlannables(plannables, contextCodes: makeContextCodes(courseIds: ["1"]))

        // Then
        XCTAssertFirstValueAndCompletion(testee.refresh(ignoreCache: false)) { isEmpty in
            XCTAssertFalse(isEmpty)
        }
        XCTAssertFirstValue(testee.todos) { todos in
            XCTAssertEqual(todos.count, 1)
            XCTAssertEqual(todos[0].title, "Assignment 1")
        }
    }

    func testRefreshWithIgnoreCache() {
        // Given
        let courses = [makeCourse(id: "1", name: "Course 1")]
        let plannables = [makePlannable(courseId: "1", plannableId: "p1", type: "assignment", title: "Assignment 1")]

        // When
        mockCourses(courses)
        mockPlannables(plannables, contextCodes: makeContextCodes(courseIds: ["1"]))

        // Then
        XCTAssertFirstValueAndCompletion(testee.refresh(ignoreCache: true)) { isEmpty in
            XCTAssertFalse(isEmpty)
        }
        XCTAssertFirstValue(testee.todos) { todos in
            XCTAssertEqual(todos.count, 1)
            XCTAssertEqual(todos[0].title, "Assignment 1")
        }
    }

    func testRefreshWithPlannablesOutsideDateRange() {
        // Given
        let courses = [makeCourse(id: "1", name: "Course 1")]
        let plannables = [
            makePlannable(courseId: "1", plannableId: "p2", type: "assignment", title: "Assignment 2")
        ]

        // When
        mockCourses(courses)
        mockPlannables(plannables, contextCodes: makeContextCodes(courseIds: ["1"]))

        // Then
        XCTAssertFirstValueAndCompletion(testee.refresh(ignoreCache: false)) { isEmpty in
            XCTAssertFalse(isEmpty)
        }
        XCTAssertFirstValue(testee.todos) { todos in
            XCTAssertEqual(todos.count, 1)
            XCTAssertEqual(todos[0].title, "Assignment 2")
        }
    }

    func testRefreshHandlesError() {
        // When
        api.mock(GetCoursesRequest(enrollmentState: .active, perPage: 100), error: NSError.internalError())

        // Then
        XCTAssertFailure(testee.refresh(ignoreCache: false))
        XCTAssertFirstValue(testee.todos) { todos in
            XCTAssertEqual(todos, [])
        }
    }

    func testCustomDateRange() {
        // Given
        let startDate = Clock.now.addDays(-1)
        let endDate = Clock.now.addDays(7)
        let courses = [makeCourse(id: "1", name: "Course 1")]
        let plannables = [makePlannable(courseId: "1", plannableId: "p1", type: "assignment", title: "Assignment 1")]

        // When
        testee = TodoInteractorLive(startDate: startDate, endDate: endDate, env: environment)
        mockCourses(courses)
        mockPlannables(plannables, contextCodes: makeContextCodes(courseIds: ["1"]), startDate: startDate, endDate: endDate)

        // Then
        XCTAssertFirstValueAndCompletion(testee.refresh(ignoreCache: false)) { isEmpty in
            XCTAssertFalse(isEmpty)
        }
        XCTAssertFirstValue(testee.todos) { todos in
            XCTAssertEqual(todos.count, 1)
        }
    }

    // MARK: - Helpers

    private func mockCourses(_ courses: [APICourse]) {
        api.mock(GetCoursesRequest(enrollmentState: .active, perPage: 100), value: courses)
    }

    private func mockPlannables(_ plannables: [APIPlannable], contextCodes: [String]) {
        api.mock(GetPlannablesRequest(
            userID: nil,
            startDate: Date.now,
            endDate: Date.distantFuture,
            contextCodes: contextCodes
        ), value: plannables)
    }

    private func mockPlannables(_ plannables: [APIPlannable], contextCodes: [String], startDate: Date, endDate: Date) {
        api.mock(GetPlannablesRequest(
            userID: nil,
            startDate: startDate,
            endDate: endDate,
            contextCodes: contextCodes
        ), value: plannables)
    }

    private func makeCourse(id: String, name: String, state: CourseWorkflowState = .available) -> APICourse {
        APICourse.make(id: ID(id), name: name, workflow_state: state)
    }

    private func makePlannable(
        courseId: String,
        plannableId: String,
        type: String,
        title: String,
        date: Date = Clock.now.addDays(1)
    ) -> APIPlannable {
        APIPlannable.make(
            course_id: ID(courseId),
            plannable_id: ID(plannableId),
            plannable_type: type,
            plannable: .make(title: title),
            plannable_date: date
        )
    }

    private func makeUserContextCodes() -> [String] {
        ["user_1"]
    }

    private func makeCourseContextCodes(_ courseIds: [String]) -> [String] {
        courseIds.map { "course_\($0)" }
    }

    private func makeContextCodes(courseIds: [String]) -> [String] {
        makeCourseContextCodes(courseIds) + makeUserContextCodes()
    }
}
