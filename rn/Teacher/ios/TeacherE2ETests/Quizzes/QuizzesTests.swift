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

    func testQuizListAndQuizDetails() {
        // MARK: Seed the usual stuff with a Quiz containing 2 questions
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)
        let quiz = Helper.createTestQuizWith2Questions(course: course)

        // MARK: Get the user logged in, navigate to Quizzes
        logInDSUser(teacher)
        Helper.navigateToQuizzes(course: course)

        // MARK: Check Quiz labels
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

        quizCell.hit()

        // MARK: Check Quiz details
        let detailsTitleLabel = DetailsHelper.title.waitUntil(.visible)
        XCTAssertTrue(detailsTitleLabel.isVisible)
        XCTAssertTrue(detailsTitleLabel.hasLabel(label: quiz.title))

        let detailsPointsLabel = DetailsHelper.points.waitUntil(.visible)
        XCTAssertTrue(detailsPointsLabel.isVisible)
        XCTAssertTrue(detailsPointsLabel.hasLabel(label: "\(Int(quiz.points_possible!)) pts"))

        let detailsPublishedLabel = DetailsHelper.published.waitUntil(.visible)
        XCTAssertTrue(detailsPublishedLabel.isVisible)
        XCTAssertTrue(detailsPublishedLabel.hasLabel(label: "Published"))

        let detailsDateSectionLabel = DetailsHelper.dateSection.waitUntil(.visible)
        XCTAssertTrue(detailsDateSectionLabel.isVisible)
        XCTAssertTrue(detailsDateSectionLabel.hasLabel(label: "No due date", strict: false))

        let detailsDescriptionLabel = DetailsHelper.description.waitUntil(.visible)
        XCTAssertTrue(detailsDescriptionLabel.isVisible)

        let detailsEditButton = DetailsHelper.editButton.waitUntil(.visible)
        XCTAssertTrue(detailsEditButton.isVisible)
    }
}
