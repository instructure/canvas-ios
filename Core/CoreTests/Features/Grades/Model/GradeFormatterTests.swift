//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
@testable import Core
import TestsFoundation
import XCTest

class GradeFormatterTests: CoreTestCase {
    let formatter = GradeFormatter()
    let submission = Submission.make()

    override func setUp() {
        super.setUp()
        formatter.pointsPossible = 10
        submission.excused = false
        submission.score = 1
    }

    func testFromAssignment() {
        let assignment = Assignment.make(from: .make(
            grading_type: .pass_fail,
            points_possible: 11,
            submission: .make(grade: "complete", score: 1)
        ))
        XCTAssertEqual(GradeFormatter.string(from: assignment), "Complete / 11")
        XCTAssertEqual(GradeFormatter.a11yString(from: assignment), "Complete out of 11")
        XCTAssertEqual(GradeFormatter.string(from: assignment, style: .short), "Complete")
    }

    func testFromAssignmentScoresHidden() {
        let assignment = Assignment.make(from: .make(
            grading_type: .pass_fail,
            points_possible: 11,
            submission: .make(grade: "complete", score: 1)
        ))
        Course.make(from: .make(settings: .make(restrict_quantitative_data: true)))
        XCTAssertEqual(GradeFormatter.string(from: assignment), "Complete")
        XCTAssertEqual(GradeFormatter.a11yString(from: assignment), "Complete")
        XCTAssertEqual(GradeFormatter.string(from: assignment, style: .short), "Complete")
    }

    func testFromAssignmentMultipleSubmissions() {
        let assignment = Assignment.make(from: .make(
            grading_type: .pass_fail,
            points_possible: 10,
            submissions: [.make(grade: "complete", score: 1, user_id: "1"), .make(grade: "incomplete", score: 0, user_id: "2")]
        ))
        XCTAssertEqual(GradeFormatter.string(from: assignment, userID: "2", style: .medium), "Incomplete / 10")
        XCTAssertEqual(GradeFormatter.a11yString(from: assignment, userID: "2", style: .medium), "Incomplete out of 10")
        XCTAssertEqual(GradeFormatter.string(from: assignment, userID: "2", style: .short), "Incomplete")
    }

    func testFromAssignmentMultipleSubmissionsScoresHidden() {
        let assignment = Assignment.make(from: .make(
            grading_type: .pass_fail,
            points_possible: 10,
            submissions: [.make(grade: "complete", score: 1, user_id: "1"), .make(grade: "incomplete", score: 0, user_id: "2")]
        ))
        Course.make(from: .make(settings: .make(restrict_quantitative_data: true)))
        XCTAssertEqual(GradeFormatter.string(from: assignment, userID: "2", style: .medium), "Incomplete")
        XCTAssertEqual(GradeFormatter.a11yString(from: assignment, userID: "2", style: .medium), "Incomplete")
        XCTAssertEqual(GradeFormatter.string(from: assignment, userID: "2", style: .short), "Incomplete")
    }

    func testDecimals() {
        formatter.gradeStyle = .short
        formatter.gradingType = .points
        submission.score = 1.05
        XCTAssertEqual(formatter.string(from: submission), "1.05")
        submission.score = 1.0005
        XCTAssertEqual(formatter.string(from: submission), "1")
    }

    func testDecimalsScoresHidden() {
        _ = Course.save(.make(grading_scheme: [
            [
                .init(value1: "A", value2: nil),
                .init(value1: nil, value2: 0.0)
            ]
        ]), in: databaseClient)
        let assignment = Assignment.save(.make(), in: databaseClient, updateSubmission: false, updateScoreStatistics: false)
        let submission = Submission.save(.make(), in: databaseClient)
        submission.assignment = assignment
        formatter.hideScores = true
        formatter.gradeStyle = .short
        formatter.gradingType = .points
        submission.score = 1.05
        XCTAssertEqual(formatter.string(from: submission), "A")
        submission.score = 1.0005
        XCTAssertEqual(formatter.string(from: submission), "A")
    }

    func testNilSubmission() {
        formatter.gradeStyle = .short
        XCTAssertNil(formatter.string(from: nil))
    }

    func testNilSubmissionScoresHidden() {
        formatter.hideScores = true
        formatter.gradeStyle = .short
        XCTAssertNil(formatter.string(from: nil))
    }

    func testExcused() {
        formatter.gradeStyle = .short
        submission.score = nil
        submission.excused = true
        XCTAssertEqual(formatter.string(from: submission), "Excused")
        submission.score = 1
        XCTAssertEqual(formatter.string(from: submission), "Excused")

        formatter.gradeStyle = .medium
        XCTAssertEqual(formatter.string(from: submission), "Excused / 10")
        XCTAssertEqual(formatter.a11yString(from: submission), "Excused out of 10")
        submission.score = nil
        XCTAssertEqual(formatter.string(from: submission), "Excused / 10")
        XCTAssertEqual(formatter.a11yString(from: submission), "Excused out of 10")
    }

    func testExcusedScoresHidden() {
        formatter.hideScores = true
        formatter.gradeStyle = .short
        submission.score = nil
        submission.excused = true
        XCTAssertEqual(formatter.string(from: submission), "Excused")
        submission.score = 1
        XCTAssertEqual(formatter.string(from: submission), "Excused")

        formatter.gradeStyle = .medium
        XCTAssertEqual(formatter.string(from: submission), "Excused")
        XCTAssertEqual(formatter.a11yString(from: submission), "Excused")
        submission.score = nil
        XCTAssertEqual(formatter.string(from: submission), "Excused")
        XCTAssertEqual(formatter.a11yString(from: submission), "Excused")
    }

    func testPassFail() {
        formatter.gradeStyle = .short
        formatter.gradingType = .pass_fail
        submission.score = 1
        submission.grade = "complete"
        XCTAssertEqual(formatter.string(from: submission), "Complete")
        submission.grade = "incomplete"
        XCTAssertEqual(formatter.string(from: submission), "Incomplete")
        submission.grade = "something else"
        XCTAssertNil(formatter.string(from: submission))

        formatter.gradeStyle = .medium
        submission.grade = "complete"
        XCTAssertEqual(formatter.string(from: submission), "Complete / 10")
        XCTAssertEqual(formatter.a11yString(from: submission), "Complete out of 10")
        submission.grade = "incomplete"
        XCTAssertEqual(formatter.string(from: submission), "Incomplete / 10")
        XCTAssertEqual(formatter.a11yString(from: submission), "Incomplete out of 10")
        submission.grade = "something else"
        XCTAssertEqual(formatter.string(from: submission), "- / 10")
        XCTAssertEqual(formatter.a11yString(from: submission), "- out of 10")
    }

    func testPassFailScoresHidden() {
        formatter.hideScores = true
        formatter.gradeStyle = .short
        formatter.gradingType = .pass_fail
        submission.score = 1
        submission.grade = "complete"
        XCTAssertEqual(formatter.string(from: submission), "Complete")
        submission.grade = "incomplete"
        XCTAssertEqual(formatter.string(from: submission), "Incomplete")
        submission.grade = "something else"
        XCTAssertNil(formatter.string(from: submission))

        formatter.gradeStyle = .medium
        submission.grade = "complete"
        XCTAssertEqual(formatter.string(from: submission), "Complete")
        XCTAssertEqual(formatter.a11yString(from: submission), "Complete")
        submission.grade = "incomplete"
        XCTAssertEqual(formatter.string(from: submission), "Incomplete")
        XCTAssertEqual(formatter.a11yString(from: submission), "Incomplete")
        submission.grade = "something else"
        XCTAssertEqual(formatter.string(from: submission), "-")
        XCTAssertEqual(formatter.a11yString(from: submission), "-")
    }

    func testPoints() {
        formatter.gradeStyle = .short
        formatter.gradingType = .points
        submission.score = 5
        XCTAssertEqual(formatter.string(from: submission), "5")
        formatter.pointsPossible = 0
        XCTAssertEqual(formatter.string(from: submission), "5")

        formatter.gradeStyle = .medium
        formatter.pointsPossible = 10
        XCTAssertEqual(formatter.string(from: submission), "5 / 10")
        XCTAssertEqual(formatter.a11yString(from: submission), "5 out of 10")
    }

    func testPointsScoresHidden() {
        _ = Course.save(.make(grading_scheme: [
            [
                .init(value1: "A", value2: nil),
                .init(value1: nil, value2: 0.0)
            ]
        ]), in: databaseClient)
        let assignment = Assignment.save(.make(), in: databaseClient, updateSubmission: false, updateScoreStatistics: false)
        let submission = Submission.save(.make(), in: databaseClient)
        submission.assignment = assignment

        submission.score = 5
        formatter.pointsPossible = 5
        formatter.hideScores = true
        formatter.gradingType = .points

        formatter.gradeStyle = .short
        XCTAssertEqual(formatter.string(from: submission), "A")
        XCTAssertEqual(formatter.a11yString(from: submission), "A")

        formatter.gradeStyle = .medium
        XCTAssertEqual(formatter.string(from: submission), "A")
        XCTAssertEqual(formatter.a11yString(from: submission), "A")
    }

    func testGPAScale() {
        formatter.gradeStyle = .short
        formatter.gradingType = .gpa_scale
        submission.grade = "50%"
        XCTAssertEqual(formatter.string(from: submission), "50% GPA")

        formatter.gradeStyle = .medium
        submission.score = 5
        XCTAssertEqual(formatter.string(from: submission), "5 / 10 (50%)")
        XCTAssertEqual(formatter.a11yString(from: submission), "5 out of 10 (50%)")
    }

    func testGPAScaleScoresHidden() {
        formatter.hideScores = true
        formatter.gradeStyle = .short
        formatter.gradingType = .gpa_scale
        submission.grade = "50%"
        XCTAssertEqual(formatter.string(from: submission), nil)
        submission.grade = "F"
        XCTAssertEqual(formatter.string(from: submission), "F GPA")

        formatter.gradeStyle = .medium
        submission.score = 5
        submission.grade = "50%"
        XCTAssertEqual(formatter.string(from: submission), nil)
        XCTAssertEqual(formatter.a11yString(from: submission), nil)
        submission.grade = "F"
        XCTAssertEqual(formatter.string(from: submission), "F GPA")
        XCTAssertEqual(formatter.a11yString(from: submission), "F GPA")
    }

    func testPercent() {
        formatter.gradeStyle = .short
        formatter.gradingType = .percent
        submission.grade = "50%"
        XCTAssertEqual(formatter.string(from: submission), "50%")

        formatter.gradeStyle = .medium
        submission.score = 5
        XCTAssertEqual(formatter.string(from: submission), "5 / 10 (50%)")
        XCTAssertEqual(formatter.a11yString(from: submission), "5 out of 10 (50%)")
    }

    func testPercentScoresHidden() {
        _ = Course.save(.make(grading_scheme: [
            [
                .init(value1: "A", value2: nil),
                .init(value1: nil, value2: 0.0)
            ]
        ]), in: databaseClient)
        let assignment = Assignment.save(.make(), in: databaseClient, updateSubmission: false, updateScoreStatistics: false)
        let submission = Submission.save(.make(), in: databaseClient)
        submission.assignment = assignment

        formatter.hideScores = true
        formatter.gradeStyle = .short
        formatter.gradingType = .percent
        submission.grade = "50%"
        XCTAssertEqual(formatter.string(from: submission), nil)

        formatter.gradeStyle = .medium
        submission.score = 5
        XCTAssertEqual(formatter.string(from: submission), "A")
        XCTAssertEqual(formatter.a11yString(from: submission), "A")
    }

    func testLetterGrade() {
        formatter.gradeStyle = .short
        formatter.gradingType = .letter_grade
        submission.grade = "A"
        XCTAssertEqual(formatter.string(from: submission), "A")

        formatter.gradeStyle = .medium
        submission.score = 5
        XCTAssertEqual(formatter.string(from: submission), "5 / 10 (A)")
        XCTAssertEqual(formatter.a11yString(from: submission), "5 out of 10 (A)")
    }

    func testLetterGradeScoresHidden() {
        formatter.hideScores = true
        formatter.gradeStyle = .short
        formatter.gradingType = .letter_grade
        submission.grade = "A"
        XCTAssertEqual(formatter.string(from: submission), "A")

        formatter.gradeStyle = .medium
        submission.score = 5
        XCTAssertEqual(formatter.string(from: submission), "A")
        XCTAssertEqual(formatter.a11yString(from: submission), "A")
    }

    func testNotGraded() {
        formatter.gradeStyle = .short
        formatter.gradingType = .not_graded
        XCTAssertNil(formatter.string(from: submission))

        formatter.gradeStyle = .medium
        XCTAssertNil(formatter.string(from: submission))
    }

    func testNotGradedScoresHidden() {
        formatter.hideScores = true
        formatter.gradeStyle = .short
        formatter.gradingType = .not_graded
        XCTAssertNil(formatter.string(from: submission))

        formatter.gradeStyle = .medium
        XCTAssertNil(formatter.string(from: submission))
    }

    func testGraderStrings() {
        let a = Assignment.make()
        let s = Submission.make()
        a.pointsPossible = 100

        a.gradingType = .not_graded
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "")
        a.gradingType = .percent

        s.workflowState = .unsubmitted
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "--")
        s.workflowState = .submitted

        s.excused = true
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "Excused")
        s.excused = false

        s.grade = "2.1189%"
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "2.12%")
        s.grade = "99.999%"
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "100%")
        s.grade = "bogus"
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "--")

        a.gradingType = .points
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "--")
        s.score = 2.1189
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "2.12")
        s.score = 99.999
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "100")

        a.gradingType = .pass_fail
        s.score = 0
        s.grade = "pass"
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "Pass")
        s.grade = "fail"
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "Fail")
        s.grade = "complete"
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "Complete")
        s.grade = "incomplete"
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "Incomplete")
        s.grade = "10.1234"
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "10.12")
        s.grade = "Something Else"
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "Something Else")
        s.grade = nil
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "--")
    }

    func testGraderStringsScoresHidden() {
        let a = Assignment.make()
        let s = Submission.make()
        Course.make(from: .make(settings: .make(restrict_quantitative_data: true)))

        a.pointsPossible = 100

        a.gradingType = .not_graded
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "")
        a.gradingType = .percent

        s.workflowState = .unsubmitted
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "--")
        s.workflowState = .submitted

        s.excused = true
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "Excused")
        s.excused = false

        s.grade = "2.1189%"
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "")
        s.grade = "99.999%"
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "")
        s.grade = "bogus"
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "")

        a.gradingType = .points
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "")
        s.score = 2.1189
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "")
        s.score = 99.999
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "")

        a.gradingType = .pass_fail
        s.score = 0
        s.grade = "pass"
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "Pass")
        s.grade = "fail"
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "Fail")
        s.grade = "complete"
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "Complete")
        s.grade = "incomplete"
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "Incomplete")
        s.grade = "10.1234"
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "")
        s.grade = "Something Else"
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "Something Else")
        s.grade = nil
        XCTAssertEqual(GradeFormatter.shortString(for: a, submission: s), "--")
    }

    // MARK: - originalScoreWithoutMetric Tests

    func test_originalScoreWithoutMetric_handlesVariousInputs() {
        let submission = Submission.make()

        // Test with valid entered score
        submission.enteredScore = 87.5
        XCTAssertEqual(GradeFormatter.originalScoreWithoutMetric(for: submission), "87.5")

        // Test with nil entered score
        submission.enteredScore = nil
        XCTAssertEqual(GradeFormatter.originalScoreWithoutMetric(for: submission), nil)

        // Test decimal truncation
        submission.enteredScore = 87.666666
        XCTAssertEqual(GradeFormatter.originalScoreWithoutMetric(for: submission), "87.67")

        // Test zero score
        submission.enteredScore = 0
        XCTAssertEqual(GradeFormatter.originalScoreWithoutMetric(for: submission), "0")

        // Test whole number (should not show decimal)
        submission.enteredScore = 100
        XCTAssertEqual(GradeFormatter.originalScoreWithoutMetric(for: submission), "100")
    }

    // MARK: - finalGradeWithoutMetric Tests

    func test_finalGradeWithoutMetric_handlesExcusedSubmissions() {
        let submission = Submission.make()
        submission.excused = true

        // Should return "Excused" regardless of grading type
        XCTAssertEqual(GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: .points), "Excused")

        XCTAssertEqual(GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: .percent), "Excused")

        XCTAssertEqual(GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: .letter_grade), "Excused")
    }

    func test_finalGradeWithoutMetric_handlesPointsGrading() {
        let submission = Submission.make()
        let gradingType: GradingType = .points

        // Test with valid score
        submission.score = 85.5
        XCTAssertEqual(GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: gradingType), "85.5")

        // Test with nil score
        submission.score = nil
        XCTAssertEqual(GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: gradingType), nil)

        // Test with zero score
        submission.score = 0
        XCTAssertEqual(GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: gradingType), "0")

        // Test decimal truncation
        submission.score = 87.666666
        XCTAssertEqual(GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: gradingType), "87.67")
    }

    func test_finalGradeWithoutMetric_handlesPercentGrading() {
        let submission = Submission.make()
        let gradingType: GradingType = .percent

        // Test with valid grade (removes % sign)
        submission.grade = "85%"
        XCTAssertEqual(GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: gradingType), "85")

        // Test with nil grade
        submission.grade = nil
        XCTAssertEqual(GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: gradingType), nil)

        // Test with decimal percentage
        submission.grade = "87.5%"
        XCTAssertEqual(GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: gradingType), "87.5")

        // Test with percentage without % sign
        submission.grade = "92"
        XCTAssertEqual(GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: gradingType), "92")
    }

    func test_finalGradeWithoutMetric_handlesLetterAndGpaGrading() {
        let submission = Submission.make()

        // Test letter grade
        submission.grade = "A-"
        XCTAssertEqual(GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: .letter_grade), "A-")

        // Test GPA grade
        submission.grade = "3.7"
        XCTAssertEqual(GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: .gpa_scale), "3.7")

        // Test with nil grades
        submission.grade = nil
        XCTAssertEqual(GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: .gpa_scale), nil)

        XCTAssertEqual(GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: .letter_grade), nil)
    }

    func test_finalGradeWithoutMetric_handlesPassFailGrading() {
        let submission = Submission.make()
        let gradingType: GradingType = .pass_fail

        // Test standard pass/fail grades (localized)
        submission.grade = "complete"
        XCTAssertEqual(GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: gradingType), "Complete")

        submission.grade = "incomplete"
        XCTAssertEqual(GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: gradingType), "Incomplete")

        submission.grade = "pass"
        XCTAssertEqual(GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: gradingType), "Pass")

        submission.grade = "fail"
        XCTAssertEqual(GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: gradingType), "Fail")

        // Test custom grade (returns as-is)
        submission.grade = "Custom Grade"
        XCTAssertEqual(GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: gradingType), "Custom Grade")

        // Test nil grade
        submission.grade = nil
        XCTAssertEqual(GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: gradingType), nil)
    }

    func test_finalGradeWithoutMetric_handlesNotGradedType() {
        let submission = Submission.make()
        let gradingType: GradingType = .not_graded
        submission.grade = "some grade"

        // Should always return nil for not graded type
        XCTAssertEqual(GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: gradingType), nil)
    }
}
