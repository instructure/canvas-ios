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

class QuizDetailsViewModelTests: CoreTestCase {
    let courseID = "1"
    let quizID = "2"

    override func setUp() {
        super.setUp()
        mockCourse()
        mockQuiz()
        mockAssignments()
    }

    func testProperties() {
        let testee = QuizDetailsViewModel(courseID: courseID, quizID: quizID)
        testee.viewDidAppear()

        XCTAssertEqual(testee.title, "Quiz Details")
        XCTAssertEqual(testee.subtitle, "test course")
        XCTAssertEqual(testee.quizTitle, "test quiz")
        XCTAssertEqual(testee.pointsPossibleText, "5 pts")
        XCTAssertTrue(testee.published)
        XCTAssertEqual(testee.quizDetailsHTML, "test description")

        let quizAttribute = testee.attributes.first(where: {$0.id == "Time Limit:"})
        XCTAssertEqual(quizAttribute?.value, "10 Minutes")
    }

    func testEditTapped() {
        let testee = QuizDetailsViewModel(courseID: courseID, quizID: quizID)
        testee.viewDidAppear()
        testee.editTapped(router: router, viewController: WeakViewController(UIViewController()))
        XCTAssertTrue(router.lastRoutedTo(URL(string: "courses/1/quizzes/2/edit")!))
    }

    func testPreviewTapped() {
        let testee = QuizDetailsViewModel(courseID: courseID, quizID: quizID)
        testee.viewDidAppear()
        testee.previewTapped(router: router, viewController: WeakViewController(UIViewController()))
        XCTAssertTrue(router.lastRoutedTo(URL(string: "courses/1/quizzes/2/preview")!))
    }

    func testRefresh() {
        let refreshExpectation = expectation(description: "Refresh finished")
        let testee = QuizDetailsViewModel(courseID: courseID, quizID: quizID)
        testee.refresh {
            refreshExpectation.fulfill()
        }

        wait(for: [refreshExpectation], timeout: 2.5)
    }

    private func mockCourse() {
        let useCase = GetCourse(courseID: courseID)
        api.mock(useCase, value: .make(name: "test course"))
    }

    private func mockQuiz() {
        let getQuiz = GetQuizRequest(courseID: courseID, quizID: quizID)
        let getSubmission = GetQuizSubmissionRequest(courseID: courseID, quizID: quizID)
        let apiQuiz = APIQuiz.make(
            access_code: "TrustNo1",
            assignment_id: "3",
            description: "test description",
            id: ID(quizID),
            points_possible: 5,
            published: true,
            time_limit: 10,
            title: "test quiz"
        )
        api.mock(getQuiz, value: apiQuiz)
        api.mock(getSubmission, value: GetQuizSubmissionRequest.Response(quiz_submissions: [.make()]))
    }

    private func mockAssignments() {
        api.mock(GetAssignmentsByGroup(courseID: courseID), value: [
            .make(id: "AG1", name: "AGroup1", position: 1, assignments: [.make(assignment_group_id: "AG1", id: "3", name: "test quiz")]),
        ])
    }

    // MARK: - Quantitative Data Display Tests

    func testPointsPossibleTextWhenQuantitativeDataEnabled() {
        // MARK: GIVEN
        mockDataForQuantitativeDataTests(restrict_quantitative_data: true)
        let testee = QuizDetailsViewModel(courseID: "1", quizID: "123")

        // MARK: WHEN
        testee.viewDidAppear()

        // MARK: THEN
        XCTAssertEqual(testee.pointsPossibleText, "")
    }

    func testPointsPossibleTextWhenQuantitativeDataDisabled() {
        // MARK: GIVEN
        mockDataForQuantitativeDataTests(restrict_quantitative_data: false)
        let testee = QuizDetailsViewModel(courseID: "1", quizID: "123")

        // MARK: WHEN
        testee.viewDidAppear()

        // MARK: THEN
        XCTAssertEqual(testee.pointsPossibleText, "11.1 pts")
    }

    func testPointsPossibleTextWhenQuantitativeDataNotSpecified() {
        // MARK: GIVEN
        mockDataForQuantitativeDataTests(restrict_quantitative_data: nil)
        let testee = QuizDetailsViewModel(courseID: "1", quizID: "123")

        // MARK: WHEN
        testee.viewDidAppear()

        // MARK: THEN
        XCTAssertEqual(testee.pointsPossibleText, "11.1 pts")
    }

    private func mockDataForQuantitativeDataTests(restrict_quantitative_data: Bool?) {
        api.mock(GetCourse(courseID: "1"),
                 value: .make(settings: .make(restrict_quantitative_data: restrict_quantitative_data)))
        api.mock(GetQuizRequest(courseID: "1", quizID: "123"),
                 value: .make())
        api.mock(GetQuizSubmissionRequest(courseID: "1", quizID: "123"),
                 value: .init(quiz_submissions: []))
        api.mock(GetAssignmentsByGroup(courseID: "1"),
                 value: [])
    }
}
