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

class BaseGradeFormatterTests: CoreTestCase {
    let formatter = GradeFormatter()
    let submission = Submission.make()

    override func setUp() {
        super.setUp()
        submission.score = 1
        submission.excused = false
    }
}

class GradeFormatterTests: BaseGradeFormatterTests {
    func testFromAssignment() {
        let assignment = Assignment.make(from: .make(
            points_possible: 10,
            submission: .make(grade: "complete", score: 1),
            grading_type: .pass_fail
        ))
        XCTAssertEqual(GradeFormatter.string(from: assignment), "Complete / 10")
        XCTAssertEqual(GradeFormatter.string(from: assignment, style: .short), "Complete")
    }

    func testFromAssignmentMultipleSubmissions() {
        let assignment = Assignment.make(from: .make(
            points_possible: 10,
            submissions: [.make(user_id: "1", grade: "complete", score: 1), .make(user_id: "2", grade: "incomplete", score: 0)],
            grading_type: .pass_fail
        ))
        XCTAssertEqual(GradeFormatter.string(from: assignment, userID: "2", style: .medium), "Incomplete / 10")
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
}

class ShortGradeFormatterTests: BaseGradeFormatterTests {
    override func setUp() {
        super.setUp()
        formatter.gradeStyle = .short
    }

    func testNilSubmission() {
        formatter.gradeStyle = .short
        XCTAssertNil(formatter.string(from: nil))
    }

    func testExcused() {
        submission.score = nil
        submission.excused = true
        XCTAssertEqual(formatter.string(from: submission), "Excused")
        submission.score = 1
        XCTAssertEqual(formatter.string(from: submission), "Excused")
    }

    func testPassFail() {
        formatter.gradingType = .pass_fail
        submission.score = 1
        submission.grade = "complete"
        XCTAssertEqual(formatter.string(from: submission), "Complete")
        submission.grade = "incomplete"
        XCTAssertEqual(formatter.string(from: submission), "Incomplete")
        submission.grade = "something else"
        XCTAssertNil(formatter.string(from: submission))
    }

    func testPoints() {
        formatter.gradingType = .points
        submission.score = 5
        formatter.pointsPossible = 10
        XCTAssertEqual(formatter.string(from: submission), "5")
        formatter.pointsPossible = 0
        XCTAssertEqual(formatter.string(from: submission), "5")
    }

    func testGPAScale() {
        formatter.gradingType = .gpa_scale
        submission.grade = "50%"
        XCTAssertEqual(formatter.string(from: submission), "50% GPA")
    }

    func testPercent() {
        formatter.gradingType = .percent
        submission.grade = "50%"
        XCTAssertEqual(formatter.string(from: submission), "50%")
    }

    func testLetterGrade() {
        formatter.gradingType = .letter_grade
        submission.grade = "A"
        XCTAssertEqual(formatter.string(from: submission), "A")
    }

    func testNotGraded() {
        formatter.gradingType = .not_graded
        XCTAssertNil(formatter.string(from: submission))
    }
}

class MediumGradeFormatterTests: BaseGradeFormatterTests {
    override func setUp() {
        super.setUp()
        formatter.gradeStyle = .medium
        formatter.pointsPossible = 10
        submission.score = 5
    }

    func testExcused() {
        submission.score = nil
        submission.excused = true
        XCTAssertEqual(formatter.string(from: submission), "Excused / 10")
        submission.score = 1
        XCTAssertEqual(formatter.string(from: submission), "Excused / 10")
    }

    func testPassFail() {
        formatter.gradingType = .pass_fail
        submission.score = 1
        submission.grade = "complete"
        XCTAssertEqual(formatter.string(from: submission), "Complete / 10")
        submission.grade = "incomplete"
        XCTAssertEqual(formatter.string(from: submission), "Incomplete / 10")
        submission.grade = "something else"
        XCTAssertEqual(formatter.string(from: submission), "- / 10")
    }

    func testPoints() {
        formatter.gradingType = .points
        formatter.pointsPossible = 10
        XCTAssertEqual(formatter.string(from: submission), "5 / 10")
    }

    func testGPAScale() {
        formatter.gradingType = .gpa_scale
        submission.grade = "50%"
        XCTAssertEqual(formatter.string(from: submission), "5 / 10 (50%)")
    }

    func testPercent() {
        formatter.gradingType = .percent
        submission.grade = "50%"
        XCTAssertEqual(formatter.string(from: submission), "5 / 10 (50%)")
    }

    func testLetterGrade() {
        formatter.gradingType = .letter_grade
        submission.grade = "A"
        XCTAssertEqual(formatter.string(from: submission), "5 / 10 (A)")
    }

    func testNotGraded() {
        formatter.gradingType = .not_graded
        XCTAssertNil(formatter.string(from: submission))
    }
}
