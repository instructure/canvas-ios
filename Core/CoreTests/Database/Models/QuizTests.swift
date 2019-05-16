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
        let quiz = Quiz.make([ "pointsPossibleRaw": nil ])
        XCTAssertNil(quiz.pointsPossible)
        quiz.pointsPossible = 15.7
        XCTAssertEqual(quiz.pointsPossibleRaw, NSNumber(value: 15.7))
    }

    func testQuizType() {
        let quiz = Quiz.make([ "quizTypeRaw": "invalid" ])
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
        XCTAssertEqual(Quiz.make([ "allowedAttempts": -1 ]).allowedAttemptsText, "Unlimited")
        XCTAssertEqual(Quiz.make([ "allowedAttempts": 1 ]).allowedAttemptsText, "1")
        XCTAssertEqual(Quiz.make([ "allowedAttempts": 10 ]).allowedAttemptsText, "10")
    }

    func testQuestionCountText() {
        XCTAssertEqual(Quiz.make([ "questionCount": 1 ]).questionCountText, "1")
        XCTAssertEqual(Quiz.make([ "questionCount": 10 ]).questionCountText, "10")
    }

    func testNQuestionsText() {
        XCTAssertEqual(Quiz.make([ "questionCount": 1 ]).nQuestionsText, "1 Question")
        XCTAssertEqual(Quiz.make([ "questionCount": 10 ]).nQuestionsText, "10 Questions")
    }

    func testTimeLimitText() {
        XCTAssertEqual(Quiz.make([ "timeLimitRaw": nil ]).timeLimitText, "None")
        XCTAssertEqual(Quiz.make([ "timeLimitRaw": 10 ]).timeLimitText, "10min")
    }

    func testSave() {
        var quiz = Quiz.save(APIQuiz.make(), in: databaseClient)
        XCTAssertEqual(quiz.order, Date.distantFuture.isoString())
        let date = Date()
        quiz = Quiz.save(APIQuiz.make([ "quiz_type": "assignment", "due_at": date ]), in: databaseClient)
        XCTAssertEqual(quiz.order, date.isoString())
        quiz = Quiz.save(APIQuiz.make([ "quiz_type": "survey", "lock_at": date ]), in: databaseClient)
        XCTAssertEqual(quiz.order, date.isoString())
    }
}
