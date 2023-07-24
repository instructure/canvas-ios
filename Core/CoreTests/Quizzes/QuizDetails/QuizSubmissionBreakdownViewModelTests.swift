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

import XCTest
@testable import Core

class QuizSubmissionBreakdownViewModelTests: CoreTestCase {
    let courseID = "1"
    let quizID = "2"

    func testProperties() {
        mockSubmissions()
        mockEnrollments()
        let testee = QuizSubmissionBreakdownViewModel(courseID: courseID, quizID: quizID)
        testee.viewDidAppear()

        XCTAssertEqual(testee.graded, 2)
        XCTAssertEqual(testee.ungraded, 0)
        XCTAssertEqual(testee.unsubmitted, 3)
        XCTAssertEqual(testee.submissionCount, 5)
    }

    func testRouting() {
        let testee = QuizSubmissionBreakdownViewModel(courseID: courseID, quizID: quizID)

        testee.routeToAll(router: router, viewController: WeakViewController(UIViewController()))
        XCTAssertTrue(router.lastRoutedTo(URL(string: "courses/1/quizzes/2/submissions")!))

        testee.routeToGraded(router: router, viewController: WeakViewController(UIViewController()))
        XCTAssertTrue(router.lastRoutedTo(URL(string: "courses/1/quizzes/2/submissions?filter=submitted")!))

        testee.routeToUnsubmitted(router: router, viewController: WeakViewController(UIViewController()))
        XCTAssertTrue(router.lastRoutedTo(URL(string: "courses/1/quizzes/2/submissions?filter=not_submitted")!))
    }

    private func mockSubmissions() {
        let useCase = GetAllQuizSubmissions(courseID: courseID, quizID: quizID)
        let quizSubmissions: [APIQuizSubmission] = [
            .make(id: "1", quiz_id: ID(quizID), user_id: "1", workflow_state: .complete),
            .make(id: "2", quiz_id: ID(quizID), user_id: "2", workflow_state: .complete),
        ]
        api.mock(useCase, value: GetAllQuizSubmissionsRequest.Response(quiz_submissions: quizSubmissions, submissions: nil))
    }

    private func mockEnrollments() {
        let usecase = GetEnrollments(context: .course(courseID), types: [ "StudentEnrollment" ])
        let enrollments: [APIEnrollment] = [
            .make(id: "1", course_id: courseID),
            .make(id: "2", course_id: courseID),
            .make(id: "3", course_id: courseID),
            .make(id: "4", course_id: courseID),
            .make(id: "5", course_id: courseID),
        ]
        api.mock(usecase, value: enrollments)
    }
}
