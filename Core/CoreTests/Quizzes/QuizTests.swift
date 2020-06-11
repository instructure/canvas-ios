//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

class QuizTests: CoreTestCase {
    func testPointsPossible() {
        let quiz = Quiz.make(from: .make(points_possible: nil))
        XCTAssertNil(quiz.pointsPossible)
        quiz.pointsPossible = 15.7
        XCTAssertEqual(quiz.pointsPossibleRaw, NSNumber(value: 15.7))
    }

    func testQuizType() {
        let quiz = Quiz.make()
        quiz.quizTypeRaw = "invalid"
        XCTAssertEqual(quiz.quizType, .assignment)
        quiz.quizType = .graded_survey
        XCTAssertEqual(quiz.quizTypeRaw, "graded_survey")
        XCTAssertEqual(quiz.quizType, .graded_survey)
    }

    func testGradeViewable() {
        let quiz = Quiz.make()
        XCTAssertEqual(quiz.gradingType, .points)
        XCTAssertNil(quiz.viewableGrade)
        XCTAssertNil(quiz.viewableScore)
    }

    func testAllowedAttemptsText() {
        XCTAssertEqual(Quiz.make(from: .make(allowed_attempts: -1)).allowedAttemptsText, "Unlimited")
        XCTAssertEqual(Quiz.make(from: .make(allowed_attempts: 1)).allowedAttemptsText, "1")
        XCTAssertEqual(Quiz.make(from: .make(allowed_attempts: 10)).allowedAttemptsText, "10")
    }

    func testQuestionCountText() {
        XCTAssertEqual(Quiz.make(from: .make(question_count: 1)).questionCountText, "1")
        XCTAssertEqual(Quiz.make(from: .make(question_count: 10)).questionCountText, "10")
    }

    func testNQuestionsText() {
        XCTAssertEqual(Quiz.make(from: .make(question_count: 1)).nQuestionsText, "1 Question")
        XCTAssertEqual(Quiz.make(from: .make(question_count: 10)).nQuestionsText, "10 Questions")
    }

    func testTimeLimitText() {
        XCTAssertEqual(Quiz.make(from: .make(time_limit: nil)).timeLimitText, "None")
        XCTAssertEqual(Quiz.make(from: .make(time_limit: 10)).timeLimitText, "10min")
    }

    func testTakeInWebOnly() {
        XCTAssertFalse(Quiz.make(from: .make(question_types: [.text_only_question])).takeInWebOnly)
        XCTAssertTrue(Quiz.make(from: .make(question_types: [.calculated_question])).takeInWebOnly)
        XCTAssertTrue(Quiz.make(from: .make(question_types: [.fill_in_multiple_blanks_question])).takeInWebOnly)
        XCTAssertTrue(Quiz.make(from: .make(has_access_code: true, question_types: [.text_only_question])).takeInWebOnly)
        XCTAssertTrue(Quiz.make(from: .make(ip_filter: "a", question_types: [.text_only_question])).takeInWebOnly)
        XCTAssertTrue(Quiz.make(from: .make(one_question_at_a_time: true, question_types: [.text_only_question])).takeInWebOnly)
        XCTAssertTrue(Quiz.make(from: .make(question_types: [.text_only_question], require_lockdown_browser: true)).takeInWebOnly)
    }

    func testSave() {
        var quiz = Quiz.save(APIQuiz.make(), in: databaseClient)
        XCTAssertEqual(quiz.order, Date.distantFuture.isoString())
        let date = Date()
        quiz = Quiz.save(APIQuiz.make(due_at: date, quiz_type: .assignment), in: databaseClient)
        XCTAssertEqual(quiz.order, date.isoString())
        quiz = Quiz.save(APIQuiz.make(lock_at: date, quiz_type: .survey), in: databaseClient)
        XCTAssertEqual(quiz.order, date.isoString())
    }
}
