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

import XCTest
import TestsFoundation

class QuizzesTests: E2ETestCase {
    typealias Helper = QuizzesHelper
    typealias DetailsHelper = Helper.Details
    typealias TakeQuizHelper = DetailsHelper.TakeQuiz

    func testQuizListAndQuizDetails() {
        // MARK: Seed the usual stuff with a Quiz containing 2 questions
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        let quiz = Helper.createTestQuizWith2Questions(course: course)

        // MARK: Get the user logged in, navigate to Quizzes
        logInDSUser(student)
        Helper.navigateToQuizzes(course: course)

        // MARK: Check Quiz labels
        let navBar = Helper.navBar(course: course).waitToExist()
        XCTAssertTrue(navBar.isVisible)

        let quizCell = Helper.cell(index: 0).waitToExist()
        XCTAssertTrue(quizCell.isVisible)

        let titleLabel = Helper.titleLabel(cell: quizCell).waitToExist()
        XCTAssertTrue(titleLabel.isVisible)
        XCTAssertEqual(titleLabel.label(), quiz.title)

        let dueDateLabel = Helper.dueDateLabel(cell: quizCell).waitToExist()
        XCTAssertTrue(dueDateLabel.isVisible)
        XCTAssertEqual(dueDateLabel.label(), "No Due Date")

        let pointsLabel = Helper.pointsLabel(cell: quizCell).waitToExist()
        XCTAssertTrue(pointsLabel.isVisible)
        XCTAssertEqual(pointsLabel.label(), "\(Int(quiz.points_possible!)) pts")

        let questionsLabel = Helper.questionsLabel(cell: quizCell).waitToExist()
        XCTAssertTrue(questionsLabel.isVisible)
        XCTAssertEqual(questionsLabel.label(), "\(quiz.question_count) Questions")

        quizCell.tap()

        // MARK: Check Quiz details
        let detailsNavBar = DetailsHelper.navBar(course: course).waitToExist()
        XCTAssertTrue(detailsNavBar.isVisible)

        let detailsTitleLabel = DetailsHelper.nameLabel.waitToExist()
        XCTAssertTrue(detailsTitleLabel.isVisible)
        XCTAssertEqual(detailsTitleLabel.label(), quiz.title)

        let detailsPointsLabel = DetailsHelper.pointsLabel.waitToExist()
        XCTAssertTrue(detailsPointsLabel.isVisible)
        XCTAssertEqual(detailsPointsLabel.label(), "\(Int(quiz.points_possible!)) pts")

        let detailsStatusLabel = DetailsHelper.statusLabel.waitToExist()
        XCTAssertTrue(detailsStatusLabel.isVisible)
        XCTAssertEqual(detailsStatusLabel.label(), "Not Submitted")

        let detailsDueDateLabel = DetailsHelper.dueLabel.waitToExist()
        XCTAssertTrue(detailsDueDateLabel.isVisible)
        XCTAssertEqual(detailsDueDateLabel.label(), "No Due Date")

        let detailsQuestionsLabel = DetailsHelper.questionsLabel.waitToExist()
        XCTAssertTrue(detailsQuestionsLabel.isVisible)
        XCTAssertEqual(detailsQuestionsLabel.label(), String(quiz.question_count))

        let detailsTimeLimitLabel = DetailsHelper.timeLimitLabel.waitToExist()
        XCTAssertTrue(detailsTimeLimitLabel.isVisible)
        XCTAssertEqual(detailsTimeLimitLabel.label(), "None")

        let detailsAllowedAttemptsLabel = DetailsHelper.attemptsLabel.waitToExist()
        XCTAssertTrue(detailsAllowedAttemptsLabel.isVisible)
        XCTAssertEqual(detailsAllowedAttemptsLabel.label(), String(quiz.allowed_attempts!))

        let detailsDescriptionLabel = DetailsHelper.descriptionLabel(quiz: quiz).waitToExist()
        XCTAssertTrue(detailsDescriptionLabel.isVisible)

        let detailsTakeQuizButton = DetailsHelper.takeQuizButton.waitToExist()
        XCTAssertTrue(detailsTakeQuizButton.isVisible)
    }

    func testTakeQuiz() {
        // MARK: Seed the usual stuff with a Quiz containing 2 questions
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        Helper.createTestQuizWith2Questions(course: course)

        // MARK: Get the user logged in and navigate to Quizzes
        logInDSUser(student)
        Helper.navigateToQuizzes(course: course)

        // MARK: Open Quiz and tap "Take Quiz" button
        let quizCell = Helper.cell(index: 0).waitToExist()
        XCTAssertTrue(quizCell.isVisible)

        quizCell.tap()
        var detailsTakeQuizButton = DetailsHelper.takeQuizButton.waitToExist()
        XCTAssertTrue(detailsTakeQuizButton.isVisible)

        detailsTakeQuizButton.tap()

        // MARK: Check "Take Quiz" screen, tick the correct answers, submit quiz
        let takeQuizNavBar = TakeQuizHelper.navBar.waitToExist()
        XCTAssertTrue(takeQuizNavBar.isVisible)

        var takeQuizExitButton = TakeQuizHelper.exitButton.waitToExist()
        XCTAssertTrue(takeQuizExitButton.isVisible)

        let takeQuizTakeTheQuizButton = TakeQuizHelper.takeTheQuizButton.waitToExist()
        XCTAssertTrue(takeQuizTakeTheQuizButton.isVisible)

        takeQuizTakeTheQuizButton.tap()
        TakeQuizHelper.answerFirstQuestion()
        TakeQuizHelper.answerSecondQuestion()
        let takeQuizSubmitQuizButton = TakeQuizHelper.submitQuizButton.waitToExist()
        XCTAssertTrue(takeQuizSubmitQuizButton.swipeUntilVisible())
        XCTAssertTrue(takeQuizSubmitQuizButton.isVisible)

        takeQuizSubmitQuizButton.tap()
        takeQuizExitButton = TakeQuizHelper.exitButton.waitToExist()
        XCTAssertTrue(takeQuizExitButton.isVisible)

        takeQuizExitButton.tap()
        let detailsStatusLabel = DetailsHelper.statusLabel.waitToExist()
        XCTAssertTrue(detailsStatusLabel.isVisible)
        XCTAssertTrue(detailsStatusLabel.label().hasPrefix("Submitted"))

        detailsTakeQuizButton = DetailsHelper.takeQuizButton.waitToExist()
        XCTAssertTrue(detailsTakeQuizButton.isVisible)
        XCTAssertEqual(detailsTakeQuizButton.label(), "View Results")
    }
}
