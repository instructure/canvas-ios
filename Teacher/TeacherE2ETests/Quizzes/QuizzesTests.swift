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
import XCTest

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
        XCTAssertEqual(titleLabel.label, quiz.title)
        XCTAssertTrue(dueDateLabel.isVisible)
        XCTAssertEqual(dueDateLabel.label, "No Due Date")
        XCTAssertTrue(pointsLabel.isVisible)
        XCTAssertEqual(pointsLabel.label, "\(Int(quiz.points_possible!)) pts")
        XCTAssertTrue(questionsLabel.isVisible)
        XCTAssertEqual(questionsLabel.label, "\(quiz.question_count) Questions")

        // MARK: Check details
        quizCell.hit()
        let detailsTitleLabel = DetailsHelper.title.waitUntil(.visible)
        let detailsPointsLabel = DetailsHelper.points.waitUntil(.visible)
        let detailsPublishedLabel = DetailsHelper.published.waitUntil(.visible)
        let detailsDateSectionLabel = DetailsHelper.dateSection.waitUntil(.visible)
        let detailsDescriptionLabel = DetailsHelper.description.waitUntil(.visible)
        let detailsEditButton = DetailsHelper.editButton.waitUntil(.visible)
        XCTAssertTrue(detailsTitleLabel.isVisible)
        XCTAssertEqual(detailsTitleLabel.label, quiz.title)
        XCTAssertTrue(detailsPointsLabel.isVisible)
        XCTAssertEqual(detailsPointsLabel.label, "\(Int(quiz.points_possible!)) pts")
        XCTAssertTrue(detailsPublishedLabel.isVisible)
        XCTAssertEqual(detailsPublishedLabel.label, "Published")
        XCTAssertTrue(detailsDateSectionLabel.isVisible)
        XCTAssertContains(detailsDateSectionLabel.label, "No due date")
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
        XCTAssertTrue(cancelButton.isVisible)
        let doneButton = EditorHelper.done.waitUntil(.visible)
        XCTAssertTrue(doneButton.isVisible)
        let title = EditorHelper.title.waitUntil(.visible)
        XCTAssertTrue(title.isVisible)
        let description = EditorHelper.description.waitUntil(.visible)
        XCTAssertTrue(description.isVisible)
        let quizType = EditorHelper.quizType.waitUntil(.visible)
        XCTAssertTrue(quizType.isVisible)
        let publish = EditorHelper.publish.waitUntil(.visible)
        XCTAssertTrue(publish.isVisible)
        let assignmentGroup = EditorHelper.assignmentGroup.waitUntil(.visible)
        XCTAssertTrue(assignmentGroup.isVisible)
        let shuffleAnswers = EditorHelper.shuffle.waitUntil(.visible)
        XCTAssertTrue(shuffleAnswers.isVisible)

        let timeLimit = EditorHelper.timeLimit.waitUntil(.visible)
        XCTAssertTrue(timeLimit.isVisible)
        let length = EditorHelper.length.waitUntil(.vanish)
        XCTAssertTrue(length.isVanished)

        let allowMultipleAttempts = EditorHelper.attempts.waitUntil(.visible)
        XCTAssertTrue(allowMultipleAttempts.isVisible)
        let allowedAttempts = EditorHelper.allowedAttempts.waitUntil(.vanish)
        XCTAssertTrue(allowedAttempts.isVanished)
        let scoreToKeep = EditorHelper.scoreToKeep.waitUntil(.vanish)
        XCTAssertTrue(scoreToKeep.isVanished)

        let showOneQuestionAtATime = EditorHelper.oneQuestion.waitUntil(.visible)
        XCTAssertTrue(showOneQuestionAtATime.isVisible)
        let lockQuestions = EditorHelper.lockQuestions.waitUntil(.vanish)
        XCTAssertTrue(lockQuestions.isVanished)

        let requireAccessCode = EditorHelper.requireAccessCode.waitUntil(.visible)
        XCTAssertTrue(requireAccessCode.isVisible)
        let accessCode = EditorHelper.accessCode.waitUntil(.vanish)
        XCTAssertTrue(accessCode.isVanished)

        let assignTo = EditorHelper.assignTo.waitUntil(.visible)
        XCTAssertTrue(assignTo.isVisible)
        let due = EditorHelper.due.waitUntil(.visible)
        XCTAssertTrue(due.isVisible)
        let availableFrom = EditorHelper.availableFrom.waitUntil(.visible)
        XCTAssertTrue(availableFrom.isVisible)
        let availableUntil = EditorHelper.availableUntil.waitUntil(.visible)
        XCTAssertTrue(availableUntil.isVisible)
        let addDueDate = EditorHelper.addDueDate.waitUntil(.visible)
        XCTAssertTrue(addDueDate.isVisible)

        timeLimit.actionUntilElementCondition(action: .swipeUp(.onApp, velocity: .slow), condition: .hittable)
        let timeLimitToggleImage = timeLimit.firstImage?.waitUntil(.visible)
        XCTAssertNotNil(timeLimitToggleImage)
        timeLimitToggleImage!.hit()
        XCTAssertTrue(length.waitUntil(.visible).isVisible)

        allowMultipleAttempts.actionUntilElementCondition(action: .swipeUp(.onApp, velocity: .slow), condition: .hittable)
        let allowMultipleAttemptsImage = allowMultipleAttempts.firstImage?.waitUntil(.visible)
        XCTAssertNotNil(allowMultipleAttemptsImage)
        allowMultipleAttemptsImage!.hit()
        XCTAssertTrue(allowedAttempts.waitUntil(.visible).isVisible)
        XCTAssertTrue(scoreToKeep.waitUntil(.visible).isVisible)

        showOneQuestionAtATime.actionUntilElementCondition(action: .swipeUp(.onApp, velocity: .slow), condition: .hittable)
        let showOneQuestionAtATimeImage = showOneQuestionAtATime.firstImage?.waitUntil(.visible)
        XCTAssertNotNil(showOneQuestionAtATimeImage)
        showOneQuestionAtATimeImage!.hit()
        XCTAssertTrue(lockQuestions.waitUntil(.visible).isVisible)

        requireAccessCode.actionUntilElementCondition(action: .swipeUp(.onApp, velocity: .slow), condition: .hittable)
        let requireAccessCodeImage = requireAccessCode.firstImage?.waitUntil(.visible)
        XCTAssertNotNil(requireAccessCodeImage)
        requireAccessCodeImage!.hit()
        XCTAssertTrue(accessCode.waitUntil(.visible).isVisible)
    }
}
