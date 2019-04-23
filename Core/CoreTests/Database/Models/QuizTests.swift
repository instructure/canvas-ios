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
}
