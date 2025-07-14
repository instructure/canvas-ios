//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Core
import XCTest
@testable import Teacher
import TestsFoundation

class GradeStateInteractorTests: TeacherTestCase {

    private var testee = GradeStateInteractorLive()

    // MARK: - hasLateDeduction Tests

    func test_hasLateDeduction_trueWhenLateGradedWithDeduction() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(
            grade: "85",
            late: true,
            points_deducted: 10
        ), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        XCTAssertTrue(gradeState.hasLateDeduction)
    }

    func test_hasLateDeduction_falseWhenNotLate() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(
            grade: "85",
            late: false,
            points_deducted: 10
        ), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        XCTAssertFalse(gradeState.hasLateDeduction)
    }

    func test_hasLateDeduction_falseWhenNotGraded() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(
            grade: nil,
            late: true,
            points_deducted: 10
        ), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        XCTAssertFalse(gradeState.hasLateDeduction)
    }

    func test_hasLateDeduction_falseWhenNoPointsDeducted() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(
            grade: "85",
            late: true,
            points_deducted: 0
        ), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        XCTAssertFalse(gradeState.hasLateDeduction)
    }

    // MARK: - isGraded Tests

    func test_isGraded_trueWhenGradeIsPresent() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(grade: "85"), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        XCTAssertTrue(gradeState.isGraded)
    }

    func test_isGraded_falseWhenGradeIsNil() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(grade: nil), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        XCTAssertFalse(gradeState.isGraded)
    }

    func test_isGraded_falseWhenGradeIsEmpty() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(grade: ""), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        XCTAssertFalse(gradeState.isGraded)
    }

    // MARK: - isExcused Tests

    func test_isExcused_trueWhenExcusedIsTrue() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(excused: true), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        XCTAssertTrue(gradeState.isExcused)
    }

    func test_isExcused_falseWhenExcusedIsFalse() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(excused: false), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        XCTAssertFalse(gradeState.isExcused)
    }

    func test_isExcused_falseWhenExcusedIsNil() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(excused: nil), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        XCTAssertFalse(gradeState.isExcused)
    }

    // MARK: - isGradedButNotPosted Tests

    func test_isGradedButNotPosted_trueWhenGradedAndNotPosted() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(
            grade: "85",
            posted_at: nil
        ), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        XCTAssertTrue(gradeState.isGradedButNotPosted)
    }

    func test_isGradedButNotPosted_falseWhenGradedAndPosted() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(
            grade: "85",
            posted_at: Date()
        ), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        XCTAssertFalse(gradeState.isGradedButNotPosted)
    }

    func test_isGradedButNotPosted_falseWhenNotGraded() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(
            grade: nil,
            posted_at: nil
        ), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        XCTAssertFalse(gradeState.isGradedButNotPosted)
    }

    // MARK: - finalGradeText Tests

    func test_finalGradeText_usesGradeFormatter() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(grade: "85"), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        let expectedText = GradeFormatter.longString(for: assignment, submission: submission, final: true)
        XCTAssertEqual(gradeState.finalGradeText, expectedText)
    }

    // MARK: - gradeText Tests

    func test_gradeText_usesGradeFormatterWithoutRubricScore() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(grade: "85"), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 95
        )

        let expectedText = GradeFormatter.longString(
            for: assignment,
            submission: submission,
            rubricScore: nil,
            final: false
        )
        XCTAssertEqual(gradeState.gradeText, expectedText)
    }

    func test_gradeText_usesGradeFormatterWithRubricScore() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(grade: "85"), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: true,
            totalRubricScore: 95
        )

        let expectedText = GradeFormatter.longString(
            for: assignment,
            submission: submission,
            rubricScore: 95,
            final: false
        )
        XCTAssertEqual(gradeState.gradeText, expectedText)
    }

    // MARK: - pointsDeductedText Tests

    func test_pointsDeductedText_formatsCorrectly() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(points_deducted: 10.5), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        let expectedText = String(localized: "\(-10.5, specifier: "%g") pts", bundle: .core)
        XCTAssertEqual(gradeState.pointsDeductedText, expectedText)
    }

    func test_pointsDeductedText_handlesNilPointsDeducted() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(points_deducted: nil), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        let expectedText = String(localized: "-\(0, specifier: "%g") pts", bundle: .core)
        XCTAssertEqual(gradeState.pointsDeductedText, expectedText)
    }

    // MARK: - gradeAlertText Tests

    func test_gradeAlertText_returnsExcusedWhenExcused() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(excused: true), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        let expectedText = String(localized: "Excused", bundle: .teacher)
        XCTAssertEqual(gradeState.gradeAlertText, expectedText)
    }

    func test_gradeAlertText_returnsEnteredGradeWhenLateGradedWithDeduction() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(
            entered_grade: "95",
            grade: "85",
            late: true,
            points_deducted: 10
        ), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        XCTAssertEqual(gradeState.gradeAlertText, "95")
    }

    func test_gradeAlertText_returnsGradeWhenNotExcusedAndNotLateWithDeduction() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(grade: "85"), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        XCTAssertEqual(gradeState.gradeAlertText, "85")
    }

    func test_gradeAlertText_returnsEmptyStringWhenGradeIsNil() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(grade: nil), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        XCTAssertEqual(gradeState.gradeAlertText, "")
    }

    // MARK: - score Tests

    func test_score_usesEnteredScoreWhenAvailable() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(
            entered_score: 95,
            score: 85
        ), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        XCTAssertEqual(gradeState.score, 95)
    }

    func test_score_usesScoreWhenEnteredScoreIsNil() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(
            entered_score: nil,
            score: 85
        ), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        XCTAssertEqual(gradeState.score, 85)
    }

    func test_score_usesZeroWhenBothScoresAreNil() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(
            entered_score: nil,
            score: nil
        ), in: databaseClient)

        let gradeState = testee.gradeState(
            submission: submission,
            assignment: assignment,
            isRubricScoreAvailable: false,
            totalRubricScore: 0
        )

        XCTAssertEqual(gradeState.score, 0)
    }
}
