//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import Student
import TestsFoundation

class QuizDetailsViewControllerTests: StudentTestCase {
    lazy var controller = QuizDetailsViewController.create(courseID: "1", quizID: "1")

    override func setUp() {
        super.setUp()
        api.mock(controller.colors, value: .init(custom_colors: [ "course_1": "#0000ff" ]))
        api.mock(controller.courses, value: .make())
        api.mock(GetQuizRequest(courseID: "1", quizID: "1"), value: .make(allowed_attempts: 2, id: "1"))
        api.mock(GetQuizSubmissionRequest(courseID: "1", quizID: "1"), value: .init(quiz_submissions: [
            .make(attempts_left: 2),
        ]))
    }

    func testLayout() {
        let date = DateComponents(calendar: .current, year: 2020, month: 7, day: 20, hour: 9).date
        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(nav.navigationBar.barTintColor?.hexString, "#0000ff")
        XCTAssertEqual(controller.titleSubtitleView.title, "Quiz Details")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Course One")
        XCTAssertEqual(controller.titleLabel.text, "What kind of pokemon are you?")
        XCTAssertEqual(controller.pointsLabel.text, "11.1 pts")
        XCTAssertEqual(controller.statusLabel.text, "Not Submitted")
        XCTAssertEqual(controller.statusIconView.image, .noSolid)
        XCTAssertEqual(controller.dueLabel.text, "No Due Date")
        XCTAssertEqual(controller.attemptsValueLabel.text, "2")
        XCTAssertEqual(controller.questionsValueLabel.text, "5")
        XCTAssertEqual(controller.timeLimitValueLabel.text, "None")
        XCTAssertEqual(controller.instructionsHeadingLabel.text, "Instructions")
        XCTAssertEqual(controller.takeButton.title(for: .normal), "Take Quiz")

        api.mock(GetQuizSubmissionRequest(courseID: "1", quizID: "1"), value: .init(quiz_submissions: []))
        controller.scrollView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.statusLabel.text, "Not Submitted")
        XCTAssertEqual(controller.takeButton.title(for: .normal), "Take Quiz")
        controller.takeButton.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.presented is QuizWebViewController)

        api.mock(GetQuizSubmissionRequest(courseID: "1", quizID: "1"), value: .init(quiz_submissions: [
            .make(attempt: 2, attempts_left: 0, started_at: date),
        ]))
        controller.scrollView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.statusLabel.text, "Submitted")
        XCTAssertEqual(controller.takeButton.title(for: .normal), "Resume Quiz")
        controller.takeButton.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.presented is QuizWebViewController)

        api.mock(GetQuizSubmissionRequest(courseID: "1", quizID: "1"), value: .init(quiz_submissions: [
            .make(attempt: 1, attempts_left: 1, finished_at: date, workflow_state: .complete),
        ]))
        controller.scrollView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.statusLabel.text, "Submitted Jul 20, 2020 at 9:00 AM")
        XCTAssertEqual(controller.takeButton.title(for: .normal), "Retake Quiz")
        controller.takeButton.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.presented is QuizWebViewController)

        api.mock(GetQuizSubmissionRequest(courseID: "1", quizID: "1"), value: .init(quiz_submissions: [
            .make(attempt: 2, attempts_left: 0, finished_at: date, workflow_state: .complete),
        ]))
        controller.scrollView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.statusLabel.text, "Submitted Jul 20, 2020 at 9:00 AM")
        XCTAssertEqual(controller.takeButton.title(for: .normal), "View Results")
        controller.takeButton.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.lastRoutedTo(URL(string: "/courses/1/quizzes/1/history")!))

        api.mock(GetQuizRequest(courseID: "1", quizID: "1"), value: .make(id: "1", lock_explanation: "", locked_for_user: true))
        controller.scrollView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.instructionsHeadingLabel.text, "Locked")
        XCTAssertEqual(controller.takeButton.title(for: .normal), "View Results")

        api.mock(GetQuizSubmissionRequest(courseID: "1", quizID: "1"), value: .init(quiz_submissions: []))
        controller.scrollView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.instructionsHeadingLabel.text, "Locked")
        XCTAssertEqual(controller.takeButton.isHidden, true)

        XCTAssertNoThrow(controller.viewWillDisappear(false))
    }

    func testNoQuiz() {
        api.mock(GetQuizRequest(courseID: "1", quizID: "1"), value: nil)
        controller.view.layoutIfNeeded()
        XCTAssertNoThrow(controller.takeButton.sendActions(for: .primaryActionTriggered))
    }

    // MARK: - Quantitative Data Display Tests

    func testPointsTextWhenQuantitativeDataEnabled() {
        // MARK: GIVEN
        mockDataForQuantitativeDataTests(restrict_quantitative_data: true)
        let testee = QuizDetailsViewController.create(courseID: "1", quizID: "123")

        // MARK: WHEN
        testee.loadViewIfNeeded()

        // MARK: THEN
        XCTAssertNil(testee.pointsLabel.text)
    }

    func testPointsTextWhenQuantitativeDataDisabled() {
        // MARK: GIVEN
        mockDataForQuantitativeDataTests(restrict_quantitative_data: false)
        let testee = QuizDetailsViewController.create(courseID: "1", quizID: "123")

        // MARK: WHEN
        testee.loadViewIfNeeded()

        // MARK: THEN
        XCTAssertEqual(testee.pointsLabel.text, "11.1 pts")
    }

    func testPointsTextWhenQuantitativeDataNotSpecified() {
        // MARK: GIVEN
        mockDataForQuantitativeDataTests(restrict_quantitative_data: nil)
        let testee = QuizDetailsViewController.create(courseID: "1", quizID: "123")

        // MARK: WHEN
        testee.loadViewIfNeeded()

        // MARK: THEN
        XCTAssertEqual(testee.pointsLabel.text, "11.1 pts")
    }

    private func mockDataForQuantitativeDataTests(restrict_quantitative_data: Bool?) {
        api.mock(GetCourse(courseID: "1"),
                 value: .make(settings: .make(restrict_quantitative_data: restrict_quantitative_data)))
        api.mock(GetQuizRequest(courseID: "1", quizID: "123"),
                 value: .make())
    }
}
