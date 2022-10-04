//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import XCTest
@testable import Core

class QuizAttributesTests: CoreTestCase {
    func testMinimal() {
        let apiQuiz = APIQuiz.make()
        let quiz = Quiz.make(from: apiQuiz, courseID: "1", in: databaseClient)
        let testee = QuizAttributes(quiz: quiz, assignment: nil)
        XCTAssertEqual(testee.attributes.count, 8)

        var quizAttribute = testee.attributes.first(where: {$0.id == "Time Limit:"})
        XCTAssertEqual(quizAttribute?.value, "No time Limit")

        quizAttribute = testee.attributes.first(where: {$0.id == "View Responses:"})
        XCTAssertEqual(quizAttribute?.value, "Always")

        quizAttribute = testee.attributes.first(where: {$0.id == "Show Correct Answers:"})
        XCTAssertEqual(quizAttribute?.value, "No")
    }

    func testProperties() {
        let apiQuiz = APIQuiz.make(
            access_code: "TrustNo1",
            allowed_attempts: 66,
            cant_go_back: true,
            has_access_code: true,
            hide_correct_answers_at: Date(),
            hide_results: .always,
            one_question_at_a_time: true,
            published: true,
            quiz_type: .survey,
            scoring_policy: .keep_average,
            shuffle_answers: true,
            time_limit: 222
        )
        let quiz = Quiz.make(from: apiQuiz, courseID: "1", in: databaseClient)
        let assignment = Assignment.make()
        assignment.assignmentGroup = AssignmentGroup.make()
        let testee = QuizAttributes(quiz: quiz, assignment: assignment)

        var quizAttribute = testee.attributes.first(where: {$0.id == "Quiz Type:"})
        XCTAssertEqual(quizAttribute?.value, "Surveys")

        quizAttribute = testee.attributes.first(where: {$0.id == "Assignment Group:"})
        XCTAssertEqual(quizAttribute?.value, "Assignment Group A")

        quizAttribute = testee.attributes.first(where: {$0.id == "Shuffle Answers:"})
        XCTAssertEqual(quizAttribute?.value, "Yes")

        quizAttribute = testee.attributes.first(where: {$0.id == "Time Limit:"})
        XCTAssertEqual(quizAttribute?.value, "222 Minutes")

        quizAttribute = testee.attributes.first(where: {$0.id == "Allowed Attempts:"})
        XCTAssertEqual(quizAttribute?.value, "66")

        quizAttribute = testee.attributes.first(where: {$0.id == "View Responses:"})
        XCTAssertEqual(quizAttribute?.value, "No")

        quizAttribute = testee.attributes.first(where: {$0.id == "One Question at a Time:"})
        XCTAssertEqual(quizAttribute?.value, "Yes")

        quizAttribute = testee.attributes.first(where: {$0.id == "Lock Questions After Answering:"})
        XCTAssertEqual(quizAttribute?.value, "Yes")

        quizAttribute = testee.attributes.first(where: {$0.id == "Score to Keep:"})
        XCTAssertEqual(quizAttribute?.value, "Average")

        quizAttribute = testee.attributes.first(where: {$0.id == "Access Code:"})
        XCTAssertEqual(quizAttribute?.value, "TrustNo1")
    }

    func testQuizType() {
        let apiQuiz = APIQuiz.make(quiz_type: .assignment)
        let quiz = Quiz.make(from: apiQuiz, courseID: "1", in: databaseClient)

        let assignment = Assignment.make()
        assignment.assignmentGroup = AssignmentGroup.make()

        let testee = QuizAttributes(quiz: quiz, assignment: assignment)
        let quizAttribute = testee.attributes.first(where: {$0.id == "Quiz Type:"})
        XCTAssertEqual(quizAttribute?.value, "Graded Quiz")
    }

    func testShowCorrectAnswersShowAtOnly() {
        let apiQuiz = APIQuiz.make(
            show_correct_answers: true,
            show_correct_answers_at: Date(fromISOString: "2022-01-03T08:00:00Z")!
        )
        let quiz = Quiz.make(from: apiQuiz, courseID: "1", in: databaseClient)
        let testee = QuizAttributes(quiz: quiz, assignment: nil)

        let quizAttribute = testee.attributes.first(where: {$0.id == "Show Correct Answers:"})
        XCTAssertEqual(quizAttribute?.value, "After Jan 3, 2022 at 9:00 AM")
    }

    func testShowCorrectAnswersHidetOnly() {
        let apiQuiz = APIQuiz.make(
            hide_correct_answers_at: Date(fromISOString: "2022-01-03T08:00:00Z")!,
            show_correct_answers: true
        )
        let quiz = Quiz.make(from: apiQuiz, courseID: "1", in: databaseClient)
        let testee = QuizAttributes(quiz: quiz, assignment: nil)

        let quizAttribute = testee.attributes.first(where: {$0.id == "Show Correct Answers:"})
        XCTAssertEqual(quizAttribute?.value, "Until Jan 3, 2022 at 9:00 AM")
    }

    func testShowCorrectAnswersShowAndHide() {
        let apiQuiz = APIQuiz.make(
            hide_correct_answers_at: Date(fromISOString: "2022-02-03T08:00:00Z")!,
            show_correct_answers: true,
            show_correct_answers_at: Date(fromISOString: "2022-01-03T08:00:00Z")!
        )
        let quiz = Quiz.make(from: apiQuiz, courseID: "1", in: databaseClient)
        let testee = QuizAttributes(quiz: quiz, assignment: nil)

        let quizAttribute = testee.attributes.first(where: {$0.id == "Show Correct Answers:"})
        XCTAssertEqual(quizAttribute?.value, "Jan 3, 2022 at 9:00 AM to Feb 3, 2022 at 9:00 AM")
    }

    func testShowCorrectAnswersLastAttempt() {
        let apiQuiz = APIQuiz.make(
            allowed_attempts: 5,
            show_correct_answers: true,
            show_correct_answers_last_attempt: true
        )
        let quiz = Quiz.make(from: apiQuiz, courseID: "1", in: databaseClient)
        let testee = QuizAttributes(quiz: quiz, assignment: nil)

        let quizAttribute = testee.attributes.first(where: {$0.id == "Show Correct Answers:"})
        XCTAssertEqual(quizAttribute?.value, "After Last Attempt")
    }

    func testShowCorrectAnswersAlways() {
        let apiQuiz = APIQuiz.make(show_correct_answers: true)
        let quiz = Quiz.make(from: apiQuiz, courseID: "1", in: databaseClient)
        let testee = QuizAttributes(quiz: quiz, assignment: nil)

        let quizAttribute = testee.attributes.first(where: {$0.id == "Show Correct Answers:"})
        XCTAssertEqual(quizAttribute?.value, "Always")
    }

    func testShowCorrectAnswersHideResults() {
        let apiQuiz = APIQuiz.make(
            hide_results: .always,
            show_correct_answers: true
        )
        let quiz = Quiz.make(from: apiQuiz, courseID: "1", in: databaseClient)
        let testee = QuizAttributes(quiz: quiz, assignment: nil)

        let quizAttribute = testee.attributes.first(where: {$0.id == "Show Correct Answers:"})
        XCTAssertNil(quizAttribute)
    }

    func testHideResults() {
        let apiQuiz = APIQuiz.make(hide_results: .always)
        let quiz = Quiz.make(from: apiQuiz, courseID: "1", in: databaseClient)
        let testee = QuizAttributes(quiz: quiz, assignment: nil)

        let quizAttribute = testee.attributes.first(where: {$0.id == "Show Correct Answers:"})
        XCTAssertNil(quizAttribute)
    }
}
