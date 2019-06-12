//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
