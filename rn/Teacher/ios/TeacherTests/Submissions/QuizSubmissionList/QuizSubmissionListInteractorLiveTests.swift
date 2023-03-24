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

    func testFilter() {
        XCTAssertEqual(testee.submissions.value.count, 2)

        testee
            .setFilter(.submitted)
            .sink()
            .store(in: &subscriptions)

        XCTAssertEqual(testee.state.value, .data)
        XCTAssertEqual(testee.submissions.value.count, 1)
    }

    func testRefresh() {
        let quizSubmissionUsersRequest = GetQuizSubmissionUsers(courseID: courseID)
        api.mock(quizSubmissionUsersRequest, value: nil, response: nil, error: NSError.instructureError("Failed"))
        performRefresh()
        waitForState(.error)

        api.mock(quizSubmissionUsersRequest, value: [.make(id: ID("5"), name: "Fifth")])
        performRefresh()
        waitForState(.data)

        XCTAssertEqual(testee.state.value, .data)
        XCTAssertEqual(testee.submissions.value.map { $0.name }, ["Fifth"])
    }

    func testCreateMessageUserInfo() {
        let expectedRecipients = [
            ["id": "1", "name": "First", "avatar_url": nil],
            ["id": "2", "name": "Second", "avatar_url": nil],
        ]

        let expectation = expectation(description: "Expected state reached")
        var result: [String: Any] = [:]
        testee
            .createMessageUserInfo()
            .sink {
                result = $0
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        wait(for: [expectation], timeout: 1)

        XCTAssertFalse(result.isEmpty)
        XCTAssertEqual(result["recipients"] as? [[String: String?]], expectedRecipients)
        XCTAssertEqual(result["subject"] as? String, "test quiz")
        XCTAssertEqual(result["contextName"] as? String, "test course")
        XCTAssertEqual(result["contextCode"] as? String, "course_1")
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
