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
    typealias DetailsHelper = Helper.TeacherDetails
    typealias EditorHelper = DetailsHelper.Editor

    func testQuizListAndQuizDetails() {
        // MARK: Seed the usual stuff with a test quiz containing 2 questions
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)
        let quiz = Helper.createTestQuizWith2Questions(course: course)

        // MARK: Get the user logged in
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Quizzes, Check elements
        Helper.navigateToQuizzes(course: course)
        let navBar = Helper.navBar(course: course).waitUntil(.visible)
        let quizCell = Helper.cell(index: 0).waitUntil(.visible)
        let titleLabel = Helper.titleLabel(cell: quizCell).waitUntil(.visible)
        let dueDateLabel = Helper.dueDateLabel(cell: quizCell).waitUntil(.visible)
        let pointsLabel = Helper.pointsLabel(cell: quizCell).waitUntil(.visible)
        let questionsLabel = Helper.questionsLabel(cell: quizCell).waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(quizCell.isVisible)
        XCTAssertTrue(titleLabel.isVisible)
        XCTAssertTrue(titleLabel.hasLabel(label: quiz.title))
        XCTAssertTrue(dueDateLabel.isVisible)
        XCTAssertTrue(dueDateLabel.hasLabel(label: "No Due Date"))
        XCTAssertTrue(pointsLabel.isVisible)
        XCTAssertTrue(pointsLabel.hasLabel(label: "\(Int(quiz.points_possible!)) pts"))
        XCTAssertTrue(questionsLabel.isVisible)
        XCTAssertTrue(questionsLabel.hasLabel(label: "\(quiz.question_count) Questions"))

        // MARK: Check details
        quizCell.hit()
        let detailsTitleLabel = DetailsHelper.title.waitUntil(.visible)
        let detailsPointsLabel = DetailsHelper.points.waitUntil(.visible)
        let detailsPublishedLabel = DetailsHelper.published.waitUntil(.visible)
        let detailsDateSectionLabel = DetailsHelper.dateSection.waitUntil(.visible)
        let detailsDescriptionLabel = DetailsHelper.description.waitUntil(.visible)
        let detailsEditButton = DetailsHelper.editButton.waitUntil(.visible)
        XCTAssertTrue(detailsTitleLabel.isVisible)
        XCTAssertTrue(detailsTitleLabel.hasLabel(label: quiz.title))
        XCTAssertTrue(detailsPointsLabel.isVisible)
        XCTAssertTrue(detailsPointsLabel.hasLabel(label: "\(Int(quiz.points_possible!)) pts"))
        XCTAssertTrue(detailsPublishedLabel.isVisible)
        XCTAssertTrue(detailsPublishedLabel.hasLabel(label: "Published"))
        XCTAssertTrue(detailsDateSectionLabel.isVisible)
        XCTAssertTrue(detailsDateSectionLabel.hasLabel(label: "No due date", strict: false))
        XCTAssertTrue(detailsDescriptionLabel.isVisible)
        XCTAssertTrue(detailsEditButton.isVisible)
    }

    func testQuizEditor() {
        // MARK: Seed the usual stuff with a test quiz containing 2 questions
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)
        Helper.createTestQuizWith2Questions(course: course)

        // MARK: Get the user logged in, navigate to the quiz
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        Helper.navigateToQuizzes(course: course)
        let quizCell = Helper.cell(index: 0).waitUntil(.visible)
        XCTAssertTrue(quizCell.isVisible)

        // MARK: Check elements of Quiz Editor
        quizCell.hit()
        DetailsHelper.editButton.hit()
        let cancelButton = EditorHelper.cancel.waitUntil(.visible)
        let doneButton = EditorHelper.done.waitUntil(.visible)
        let title = EditorHelper.title.waitUntil(.visible)
        let description = EditorHelper.description.waitUntil(.visible)
        let quizType = EditorHelper.quizType.waitUntil(.visible)
        let publish = EditorHelper.publish.waitUntil(.visible)
        let assignmentGroup = EditorHelper.assignmentGroup.waitUntil(.visible)
        let shuffleAnswers = EditorHelper.shuffle.waitUntil(.visible)

        let timeLimit = EditorHelper.timeLimit.waitUntil(.visible)
        let length = EditorHelper.length.waitUntil(.vanish)

        let allowMultipleAttempts = EditorHelper.attempts.waitUntil(.visible)
        let allowedAttempts = EditorHelper.allowedAttempts.waitUntil(.vanish)
        let scoreToKeep = EditorHelper.scoreToKeep.waitUntil(.vanish)

        let showOneQuestionAtATime = EditorHelper.oneQuestion.waitUntil(.visible)
        let lockQuestions = EditorHelper.lockQuestions.waitUntil(.vanish)

        let requireAccessCode = EditorHelper.requireAccessCode.waitUntil(.visible)
        let accessCode = EditorHelper.accessCode.waitUntil(.vanish)

        let assignTo = EditorHelper.assignTo.waitUntil(.visible)
        let due = EditorHelper.due.waitUntil(.visible)
        let availableFrom = EditorHelper.availableFrom.waitUntil(.visible)
        let availableUntil = EditorHelper.availableUntil.waitUntil(.visible)
        let addDueDate = EditorHelper.addDueDate.waitUntil(.visible)
        XCTAssertTrue(cancelButton.isVisible)
        XCTAssertTrue(doneButton.isVisible)
        XCTAssertTrue(title.isVisible)
        XCTAssertTrue(description.isVisible)
        XCTAssertTrue(quizType.isVisible)
        XCTAssertTrue(publish.isVisible)
        XCTAssertTrue(assignmentGroup.isVisible)
        XCTAssertTrue(shuffleAnswers.isVisible)
        XCTAssertTrue(timeLimit.isVisible)
        XCTAssertTrue(length.isVanished)
        XCTAssertTrue(allowMultipleAttempts.isVisible)
        XCTAssertTrue(allowedAttempts.isVanished)
        XCTAssertTrue(scoreToKeep.isVanished)
        XCTAssertTrue(showOneQuestionAtATime.isVisible)
        XCTAssertTrue(lockQuestions.isVanished)
        XCTAssertTrue(requireAccessCode.isVisible)
        XCTAssertTrue(accessCode.isVanished)
        XCTAssertTrue(assignTo.isVisible)
        XCTAssertTrue(due.isVisible)
        XCTAssertTrue(availableFrom.isVisible)
        XCTAssertTrue(availableUntil.isVisible)
        XCTAssertTrue(addDueDate.isVisible)

        timeLimit.actionUntilElementCondition(action: .swipeUp(.onApp), condition: .hittable)
        timeLimit.hit()
        XCTAssertTrue(length.waitUntil(.visible).isVisible)

        allowMultipleAttempts.actionUntilElementCondition(action: .swipeUp(.onApp), condition: .hittable)
        allowMultipleAttempts.hit()
        XCTAssertTrue(allowedAttempts.waitUntil(.visible).isVisible)
        XCTAssertTrue(scoreToKeep.waitUntil(.visible).isVisible)

        showOneQuestionAtATime.actionUntilElementCondition(action: .swipeUp(.onApp), condition: .hittable)
        showOneQuestionAtATime.hit()
        XCTAssertTrue(lockQuestions.waitUntil(.visible).isVisible)

        requireAccessCode.actionUntilElementCondition(action: .swipeUp(.onApp), condition: .hittable)
        requireAccessCode.hit()
        XCTAssertTrue(accessCode.waitUntil(.visible).isVisible)
    }
}
