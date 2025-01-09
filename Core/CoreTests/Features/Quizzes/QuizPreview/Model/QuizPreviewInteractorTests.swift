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
import XCTest

class QuizPreviewInteractorTests: CoreTestCase {
    private var subscriptions = Set<AnyCancellable>()

    override func tearDown() {
        super.tearDown()
        subscriptions.removeAll()
    }

    public func testURLResponse() {
        // MARK: - GIVEN
        let getQuiz = GetQuizRequest(courseID: "testCourse", quizID: "testQuiz")
        let getSubmission = GetQuizSubmissionRequest(courseID: "testCourse", quizID: "testQuiz")
        api.mock(getQuiz, value: .make(html_url: URL(string: "https://test.instructure.com/quiz/testQuiz")!, id: "testQuiz"))
        api.mock(getSubmission, value: nil)

        // MARK: - WHEN
        let testee = QuizPreviewInteractorLive(courseID: "testCourse",
                                               quizID: "testQuiz",
                                               env: environment)

        // MARK: - THEN
        waitForState(.data(launchURL: URL(string: "https://test.instructure.com/quiz/testQuiz/take?preview=1&persist_headless=1&force_user=1")!),
                     on: testee)
    }

    public func testError() {
        // MARK: - GIVEN
        let getQuiz = GetQuizRequest(courseID: "testCourse", quizID: "testQuiz")
        api.mock(getQuiz, value: nil, error: NSError.instructureError("testError"))

        // MARK: - WHEN
        let testee = QuizPreviewInteractorLive(courseID: "testCourse",
                                               quizID: "testQuiz",
                                               env: environment)

        // MARK: - THEN
        waitForState(.error, on: testee)
    }

    public func testLoading() {
        // MARK: - GIVEN
        let getQuiz = GetQuizRequest(courseID: "testCourse", quizID: "testQuiz")
        let mock = api.mock(getQuiz, value: nil, error: NSError.instructureError("testError"))
        mock.suspend()

        // MARK: - WHEN
        let testee = QuizPreviewInteractorLive(courseID: "testCourse",
                                               quizID: "testQuiz",
                                               env: environment)

        // MARK: - THEN
        waitForState(.loading, on: testee)
    }

    private func waitForState(_ expectedState: QuizPreviewInteractorState = .loading, on testee: QuizPreviewInteractor) {
        let stateReached = expectation(description: "state reached \(expectedState)")
        testee
            .state
            .sink { state in
                if state == expectedState {
                    stateReached.fulfill()
                }
            }
            .store(in: &subscriptions)
        wait(for: [stateReached], timeout: 3)
    }
}
