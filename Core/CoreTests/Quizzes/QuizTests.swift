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
        XCTAssertEqual(quiz.quizType.sectionTitle, "Assignments")
        XCTAssertEqual(quiz.quizType.name, "Graded Quiz")
        quiz.quizType = .graded_survey
        XCTAssertEqual(quiz.quizTypeRaw, "graded_survey")
        XCTAssertEqual(quiz.quizType, .graded_survey)
        XCTAssertEqual(quiz.quizType.sectionTitle, "Graded Surveys")
        XCTAssertEqual(quiz.quizType.name, "Graded Survey")
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

    func testScoringPolicy() {
        XCTAssertEqual(Quiz.make(from: .make(scoring_policy: .keep_latest)).scoringPolicy?.text, "Latest")
        XCTAssertEqual(Quiz.make(from: .make(scoring_policy: .keep_highest)).scoringPolicy?.text, "Highest")
        XCTAssertEqual(Quiz.make(from: .make(scoring_policy: .keep_average)).scoringPolicy?.text, "Average")
    }

    func testHideResults() {
        XCTAssertEqual(Quiz.make(from: .make(hide_results: .always)).hideResults?.text, "No")
        XCTAssertEqual(Quiz.make(from: .make(hide_results: .until_after_last_attempt)).hideResults?.text, "After Last Attempt")
    }

    func testResultsPath() {
        XCTAssertNil(Quiz.make(from: .make(hide_results: .always)).resultsPath(for: 1))
        XCTAssertNil(Quiz.make(from: .make(allowed_attempts: 2, hide_results: .always)).resultsPath(for: 1))
        XCTAssertEqual(Quiz.make().resultsPath(for: 1), "/courses/1/quizzes/123/history?attempt=1")
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

    func testSaveAssignmentDates() {
        let id = ID("1234")
        let base = true
        let title = "test"
        let dueAt = Date()
        let unlockAt = Date(timeIntervalSinceNow: -100)
        let lockAt = Date(timeIntervalSinceNow: 100)
        let dates = [APIAssignmentDate.make(id: id, base: base, title: title, due_at: dueAt, unlock_at: unlockAt, lock_at: lockAt)]
        let quiz = Quiz.save(APIQuiz.make(all_dates: dates), in: databaseClient)

        XCTAssertNotNil(quiz.allDates)
        XCTAssertEqual(quiz.allDates.first?.id, "1234")
        XCTAssertEqual(quiz.allDates.first?.base, true)
        XCTAssertEqual(quiz.allDates.first?.title, title)
        XCTAssertEqual(quiz.allDates.first?.dueAt, dueAt)
        XCTAssertEqual(quiz.allDates.first?.unlockAt, unlockAt)
        XCTAssertEqual(quiz.allDates.first?.lockAt, lockAt)
    }
}
