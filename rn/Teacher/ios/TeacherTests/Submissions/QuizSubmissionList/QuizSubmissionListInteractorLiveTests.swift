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
import CoreData
import XCTest
@testable import Core
@testable import Teacher

class QuizSubmissionListInteractorLiveTests: TeacherTestCase {
    private var subscriptions = Set<AnyCancellable>()
    private var testee: QuizSubmissionListInteractorLive!
    private let courseID = "1"
    private let quizID = "2"

    override func setUp() {
        super.setUp()

        let quizSubmissionUsersRequest = GetQuizSubmissionUsers(courseID: courseID)
        api.mock(quizSubmissionUsersRequest, value: [
            .make(id: ID("1"), name: "First"),
            .make(id: ID("2"), name: "Second"),
        ])

        let quizSubmissionsRequest = GetAllQuizSubmissions(courseID: courseID, quizID: quizID)
        let quizSubmissions: [APIQuizSubmission] = [
            .make(id: "1", quiz_id: ID(quizID), user_id: "1", workflow_state: .complete)
        ]
        api.mock(quizSubmissionsRequest, value: GetAllQuizSubmissionsRequest.Response(quiz_submissions: quizSubmissions, submissions: nil))

        let getQuizRequest = GetQuizRequest(courseID: courseID, quizID: quizID)
        api.mock(getQuizRequest, value: .make(id: ID(quizID), title: "test quiz"))

        let getCourseRequest = GetCourse(courseID: courseID)
        api.mock(getCourseRequest, value: .make(id: "1", name: "test course"))

        testee = QuizSubmissionListInteractorLive(env: environment, courseID: courseID, quizID: quizID)

        waitForState(.data)
    }

    override func tearDown() {
        subscriptions.removeAll()
        super.tearDown()
    }

    func testPopulatesListItems() {
        XCTAssertEqual(testee.state.value, .data)
        XCTAssertEqual(testee.submissions.value.map { $0.name }, ["First", "Second"])
        XCTAssertEqual(testee.quizTitle.value, "test quiz")
    }

/*
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

    private func performRefresh() {
        let refreshed = expectation(description: "Expected state reached")
        testee
            .refresh()
            .sink { refreshed.fulfill() }
            .store(in: &subscriptions)
        wait(for: [refreshed], timeout: 1)
    }
*/
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
