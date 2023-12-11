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

        // MARK: Get the user logged in
        logInDSUser(student)
        let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
        XCTAssertTrue(profileButton.isVisible)

        // MARK: Navigate to quizzes, check Quiz labels
        Helper.navigateToQuizzes(course: course)
        let navBar = Helper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        let quizCell = Helper.cell(index: 0).waitUntil(.visible)
        XCTAssertTrue(quizCell.isVisible)

        let titleLabel = Helper.titleLabel(cell: quizCell).waitUntil(.visible)
        XCTAssertTrue(titleLabel.isVisible)
        XCTAssertTrue(titleLabel.hasLabel(label: quiz.title))

        let dueDateLabel = Helper.dueDateLabel(cell: quizCell).waitUntil(.visible)
        XCTAssertTrue(dueDateLabel.isVisible)
        XCTAssertTrue(dueDateLabel.hasLabel(label: "No Due Date"))

        let pointsLabel = Helper.pointsLabel(cell: quizCell).waitUntil(.visible)
        XCTAssertTrue(pointsLabel.isVisible)
        XCTAssertTrue(pointsLabel.hasLabel(label: "\(Int(quiz.points_possible!)) pts"))

        let questionsLabel = Helper.questionsLabel(cell: quizCell).waitUntil(.visible)
        XCTAssertTrue(questionsLabel.isVisible)
        XCTAssertTrue(questionsLabel.hasLabel(label: "\(quiz.question_count) Questions"))

        // MARK: Check Quiz details
        quizCell.hit()
        let detailsNavBar = DetailsHelper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(detailsNavBar.isVisible)

        let detailsTitleLabel = DetailsHelper.nameLabel.waitUntil(.visible)
        XCTAssertTrue(detailsTitleLabel.isVisible)
        XCTAssertTrue(detailsTitleLabel.hasLabel(label: quiz.title))

        let detailsPointsLabel = DetailsHelper.pointsLabel.waitUntil(.visible)
        XCTAssertTrue(detailsPointsLabel.isVisible)
        XCTAssertTrue(detailsPointsLabel.hasLabel(label: "\(Int(quiz.points_possible!)) pts"))

        let detailsStatusLabel = DetailsHelper.statusLabel.waitUntil(.visible)
        XCTAssertTrue(detailsStatusLabel.isVisible)
        XCTAssertTrue(detailsStatusLabel.hasLabel(label: "Not Submitted"))

        let detailsDueDateLabel = DetailsHelper.dueLabel.waitUntil(.visible)
        XCTAssertTrue(detailsDueDateLabel.isVisible)
        XCTAssertTrue(detailsDueDateLabel.hasLabel(label: "No Due Date"))

        let detailsQuestionsLabel = DetailsHelper.questionsLabel.waitUntil(.visible)
        XCTAssertTrue(detailsQuestionsLabel.isVisible)
        XCTAssertTrue(detailsQuestionsLabel.hasLabel(label: String(quiz.question_count)))

        let detailsTimeLimitLabel = DetailsHelper.timeLimitLabel.waitUntil(.visible)
        XCTAssertTrue(detailsTimeLimitLabel.isVisible)
        XCTAssertTrue(detailsTimeLimitLabel.hasLabel(label: "None"))

        let detailsAllowedAttemptsLabel = DetailsHelper.attemptsLabel.waitUntil(.visible)
        XCTAssertTrue(detailsAllowedAttemptsLabel.isVisible)
        XCTAssertTrue(detailsAllowedAttemptsLabel.hasLabel(label: String(quiz.allowed_attempts!)))

        let detailsDescriptionLabel = DetailsHelper.descriptionLabel(quiz: quiz).waitUntil(.visible)
        XCTAssertTrue(detailsDescriptionLabel.isVisible)

        let detailsTakeQuizButton = DetailsHelper.takeQuizButton.waitUntil(.visible)
        XCTAssertTrue(detailsTakeQuizButton.isVisible)
    }

    func testTakeQuiz() {
        // MARK: Seed the usual stuff with a Quiz containing 2 questions
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        Helper.createTestQuizWith2Questions(course: course)

        // MARK: Get the user logged in
        logInDSUser(student)
        let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
        XCTAssertTrue(profileButton.isVisible)

        // MARK: Navigate to quizzes, open quiz and tap "Take Quiz" button
        Helper.navigateToQuizzes(course: course)
        let quizCell = Helper.cell(index: 0).waitUntil(.visible)
        XCTAssertTrue(quizCell.isVisible)

        quizCell.hit()
        var detailsTakeQuizButton = DetailsHelper.takeQuizButton.waitUntil(.visible)
        XCTAssertTrue(detailsTakeQuizButton.isVisible)

        detailsTakeQuizButton.hit()

        // MARK: Check "Take Quiz" screen, tick the correct answers, submit quiz
        let takeQuizNavBar = TakeQuizHelper.navBar.waitUntil(.visible)
        XCTAssertTrue(takeQuizNavBar.isVisible)

        var takeQuizExitButton = TakeQuizHelper.exitButton.waitUntil(.visible)
        XCTAssertTrue(takeQuizExitButton.isVisible)

        let takeQuizTakeTheQuizButton = TakeQuizHelper.takeTheQuizButton.waitUntil(.visible)
        XCTAssertTrue(takeQuizTakeTheQuizButton.isVisible)

        takeQuizTakeTheQuizButton.hit()
        TakeQuizHelper.answerFirstQuestion()
        TakeQuizHelper.answerSecondQuestion()
        let takeQuizSubmitQuizButton = TakeQuizHelper.submitQuizButton.waitUntil(.visible)
        XCTAssertTrue(takeQuizSubmitQuizButton.actionUntilElementCondition(action: .swipeUp(), condition: .visible))
        XCTAssertTrue(takeQuizSubmitQuizButton.isVisible)

        takeQuizSubmitQuizButton.hit()
        takeQuizExitButton = TakeQuizHelper.exitButton.waitUntil(.visible)
        XCTAssertTrue(takeQuizExitButton.isVisible)

        takeQuizExitButton.hit()
        let detailsStatusLabel = DetailsHelper.statusLabel.waitUntil(.visible)
        XCTAssertTrue(detailsStatusLabel.isVisible)

        detailsStatusLabel.actionUntilElementCondition(action: .pullToRefresh, condition: .labelHasPrefix(expected: "Submitted"))
        XCTAssertTrue(detailsStatusLabel.labelHasPrefix("Submitted"))

        detailsTakeQuizButton = DetailsHelper.takeQuizButton.waitUntil(.visible)
        XCTAssertTrue(detailsTakeQuizButton.isVisible)
        XCTAssertTrue(detailsTakeQuizButton.hasLabel(label: "View Results"))
    }
}
