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
        XCTAssertVisible(courseCard)

        // MARK: Navigate to Quizzes, Check elements
        Helper.navigateToQuizzes(course: course)
        let navBar = Helper.navBar(course: course).waitUntil(.visible)
        let quizCell = Helper.cell(index: 0).waitUntil(.visible)
        let titleLabel = Helper.titleLabel(cell: quizCell).waitUntil(.visible)
        let dueDateLabel = Helper.dueDateLabel(cell: quizCell).waitUntil(.visible)
        let pointsLabel = Helper.pointsLabel(cell: quizCell).waitUntil(.visible)
        let questionsLabel = Helper.questionsLabel(cell: quizCell).waitUntil(.visible)
        XCTAssertVisible(navBar)
        XCTAssertVisible(quizCell)
        XCTAssertVisible(titleLabel)
        XCTAssertEqual(titleLabel.label, quiz.title)
        XCTAssertVisible(dueDateLabel)
        XCTAssertEqual(dueDateLabel.label, "No Due Date")
        XCTAssertVisible(pointsLabel)
        XCTAssertEqual(pointsLabel.label, "\(Int(quiz.points_possible!)) pts")
        XCTAssertVisible(questionsLabel)
        XCTAssertEqual(questionsLabel.label, "\(quiz.question_count) Questions")

        // MARK: Check details
        quizCell.hit()
        let detailsTitleLabel = DetailsHelper.title.waitUntil(.visible)
        let detailsPointsLabel = DetailsHelper.points.waitUntil(.visible)
        let detailsPublishedLabel = DetailsHelper.published.waitUntil(.visible)
        let detailsDateSectionLabel = DetailsHelper.dateSection.waitUntil(.visible)
        let detailsDescriptionLabel = DetailsHelper.description.waitUntil(.visible)
        let detailsEditButton = DetailsHelper.editButton.waitUntil(.visible)
        XCTAssertVisible(detailsTitleLabel)
        XCTAssertEqual(detailsTitleLabel.label, quiz.title)
        XCTAssertVisible(detailsPointsLabel)
        XCTAssertEqual(detailsPointsLabel.label, "\(Int(quiz.points_possible!)) pts")
        XCTAssertVisible(detailsPublishedLabel)
        XCTAssertEqual(detailsPublishedLabel.label, "Published")
        XCTAssertVisible(detailsDateSectionLabel)
        XCTAssertContains(detailsDateSectionLabel.label, "No due date")
        XCTAssertVisible(detailsDescriptionLabel)
        XCTAssertVisible(detailsEditButton)
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
        XCTAssertVisible(courseCard)

        Helper.navigateToQuizzes(course: course)
        let quizCell = Helper.cell(index: 0).waitUntil(.visible)
        XCTAssertVisible(quizCell)

        // MARK: Check elements of Quiz Editor
        quizCell.hit()
        DetailsHelper.editButton.hit()
        let cancelButton = EditorHelper.cancel.waitUntil(.visible)
        XCTAssertVisible(cancelButton)
        let doneButton = EditorHelper.done.waitUntil(.visible)
        XCTAssertVisible(doneButton)
        let title = EditorHelper.title.waitUntil(.visible)
        XCTAssertVisible(title)
        let description = EditorHelper.description.waitUntil(.visible)
        XCTAssertVisible(description)
        let quizType = EditorHelper.quizType.waitUntil(.visible)
        XCTAssertVisible(quizType)
        let publish = EditorHelper.publish.waitUntil(.visible)
        XCTAssertVisible(publish)
        let assignmentGroup = EditorHelper.assignmentGroup.waitUntil(.visible)
        XCTAssertVisible(assignmentGroup)
        let shuffleAnswers = EditorHelper.shuffle.waitUntil(.visible)
        XCTAssertVisible(shuffleAnswers)

        let timeLimit = EditorHelper.timeLimit.waitUntil(.visible)
        XCTAssertVisible(timeLimit)
        let length = EditorHelper.length.waitUntil(.vanish)
        XCTAssertTrue(length.isVanished)

        let allowMultipleAttempts = EditorHelper.attempts.waitUntil(.visible)
        XCTAssertVisible(allowMultipleAttempts)
        let allowedAttempts = EditorHelper.allowedAttempts.waitUntil(.vanish)
        XCTAssertTrue(allowedAttempts.isVanished)
        let scoreToKeep = EditorHelper.scoreToKeep.waitUntil(.vanish)
        XCTAssertTrue(scoreToKeep.isVanished)

        let showOneQuestionAtATime = EditorHelper.oneQuestion.waitUntil(.visible)
        XCTAssertVisible(showOneQuestionAtATime)
        let lockQuestions = EditorHelper.lockQuestions.waitUntil(.vanish)
        XCTAssertTrue(lockQuestions.isVanished)

        let requireAccessCode = EditorHelper.requireAccessCode.waitUntil(.visible)
        XCTAssertVisible(requireAccessCode)
        let accessCode = EditorHelper.accessCode.waitUntil(.vanish)
        XCTAssertTrue(accessCode.isVanished)

        let assignTo = EditorHelper.assignTo.waitUntil(.visible)
        XCTAssertVisible(assignTo)
        let due = EditorHelper.due.waitUntil(.visible)
        XCTAssertVisible(due)
        let availableFrom = EditorHelper.availableFrom.waitUntil(.visible)
        XCTAssertVisible(availableFrom)
        let availableUntil = EditorHelper.availableUntil.waitUntil(.visible)
        XCTAssertVisible(availableUntil)
        let addDueDate = EditorHelper.addDueDate.waitUntil(.visible)
        XCTAssertVisible(addDueDate)

        timeLimit.actionUntilElementCondition(action: .swipeUp(.onApp, velocity: .slow), condition: .hittable)
        let timeLimitToggleImage = timeLimit.firstImage?.waitUntil(.visible)
        XCTAssertNotNil(timeLimitToggleImage)
        timeLimitToggleImage!.hit()
        XCTAssertVisible(length.waitUntil(.visible))

        allowMultipleAttempts.actionUntilElementCondition(action: .swipeUp(.onApp, velocity: .slow), condition: .hittable)
        let allowMultipleAttemptsImage = allowMultipleAttempts.firstImage?.waitUntil(.visible)
        XCTAssertNotNil(allowMultipleAttemptsImage)
        allowMultipleAttemptsImage!.hit()
        XCTAssertVisible(allowedAttempts.waitUntil(.visible))
        XCTAssertVisible(scoreToKeep.waitUntil(.visible))

        showOneQuestionAtATime.actionUntilElementCondition(action: .swipeUp(.onApp, velocity: .slow), condition: .hittable)
        let showOneQuestionAtATimeImage = showOneQuestionAtATime.firstImage?.waitUntil(.visible)
        XCTAssertNotNil(showOneQuestionAtATimeImage)
        showOneQuestionAtATimeImage!.hit()
        XCTAssertVisible(lockQuestions.waitUntil(.visible))

        requireAccessCode.actionUntilElementCondition(action: .swipeUp(.onApp, velocity: .slow), condition: .hittable)
        let requireAccessCodeImage = requireAccessCode.firstImage?.waitUntil(.visible)
        XCTAssertNotNil(requireAccessCodeImage)
        requireAccessCodeImage!.hit()
        XCTAssertVisible(accessCode.waitUntil(.visible))
    }
}
