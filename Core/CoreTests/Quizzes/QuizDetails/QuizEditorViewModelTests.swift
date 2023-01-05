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

import Foundation

import XCTest
@testable import Core

class QuizEditorViewModelTests: CoreTestCase {
    let courseID = "1"
    let quizID = "2"
    let assignmentID = "3"
    let assignmentGroupID = "15"

    override func setUp() {
        super.setUp()
        let apiQuiz = APIQuiz.make(
            access_code: "TrustNo1",
            allowed_attempts: 10,
            assignment_id: ID(assignmentID),
            cant_go_back: true,
            description: "test description",
            has_access_code: true,
            id: ID(quizID),
            one_question_at_a_time: true,
            points_possible: 5,
            published: true,
            quiz_type: .graded_survey,
            scoring_policy: .keep_highest,
            shuffle_answers: true,
            time_limit: 10,
            title: "test quiz"
        )
        api.mock(GetQuizRequest(courseID: courseID, quizID: quizID), value: apiQuiz)
        api.mock(GetAssignment(courseID: self.courseID, assignmentID: assignmentID, include: GetAssignmentRequest.GetAssignmentInclude.allCases), value: .make())
        api.mock(GetAssignmentGroups(courseID: courseID), value: [.make()])
    }

    func testAttributes() {
        let testee = QuizEditorViewModel(courseID: courseID, quizID: quizID)

        XCTAssertEqual(testee.title, "test quiz")
        XCTAssertEqual(testee.description, "test description")
        XCTAssertEqual(testee.quizType, .graded_survey)
        XCTAssertTrue(testee.published)
        XCTAssertTrue(testee.shuffleAnswers)
        XCTAssertTrue(testee.timeLimit)
        XCTAssertEqual(testee.lengthInMinutes, 10)
        XCTAssertTrue(testee.allowMultipleAttempts)
        XCTAssertEqual(testee.scoreToKeep, .keep_highest)
        XCTAssertEqual(testee.allowedAttempts, 10)
        XCTAssertTrue(testee.oneQuestionAtaTime)
        XCTAssertTrue(testee.lockQuestionAfterViewing)
        XCTAssertTrue(testee.requireAccessCode)
        XCTAssertEqual(testee.accessCode, "TrustNo1")
    }

    func testDoneTapped() {
        let testee = QuizEditorViewModel(courseID: courseID, quizID: quizID)
        testee.doneTapped(router: router, viewController: WeakViewController(UIViewController()))
        // TODO expectations

    }
}
