//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
@testable import Student

final class SubmissionNodeIsValidNewGradeTests: XCTestCase {

    private let weekStart = Date(timeIntervalSince1970: 0)
    private var weekEnd: Date { weekStart.endOfWeek() }

    // MARK: - gradeHidden

    func test_returnsFalse_whenGradeIsHidden() {
        let node = makeNode(grade: "A", gradedAt: weekStart.addDays(1), gradeHidden: true)

        XCTAssertFalse(node.isValidNewGrade(weekStart: weekStart, weekEnd: weekEnd))
    }

    func test_returnsTrue_whenGradeIsNotHidden() {
        let node = makeNode(grade: "A", gradedAt: weekStart.addDays(1), gradeHidden: false)

        XCTAssertTrue(node.isValidNewGrade(weekStart: weekStart, weekEnd: weekEnd))
    }

    func test_returnsTrue_whenGradeHiddenIsNil() {
        let node = makeNode(grade: "A", gradedAt: weekStart.addDays(1), gradeHidden: nil)

        XCTAssertTrue(node.isValidNewGrade(weekStart: weekStart, weekEnd: weekEnd))
    }

    // MARK: - grade and score

    func test_returnsTrue_whenOnlyGradeIsPresent() {
        let node = makeNode(score: nil, grade: "B", gradedAt: weekStart.addDays(1))

        XCTAssertTrue(node.isValidNewGrade(weekStart: weekStart, weekEnd: weekEnd))
    }

    func test_returnsTrue_whenOnlyScoreIsPresent() {
        let node = makeNode(score: 85, grade: nil, gradedAt: weekStart.addDays(1))

        XCTAssertTrue(node.isValidNewGrade(weekStart: weekStart, weekEnd: weekEnd))
    }

    func test_returnsFalse_whenBothGradeAndScoreAreNil() {
        let node = makeNode(score: nil, grade: nil, gradedAt: weekStart.addDays(1))

        XCTAssertFalse(node.isValidNewGrade(weekStart: weekStart, weekEnd: weekEnd))
    }

    // MARK: - gradedAt

    func test_returnsFalse_whenGradedAtIsNil() {
        let node = makeNode(grade: "A", gradedAt: nil)

        XCTAssertFalse(node.isValidNewGrade(weekStart: weekStart, weekEnd: weekEnd))
    }

    func test_returnsTrue_whenGradedAtIsExactlyWeekStart() {
        let node = makeNode(grade: "A", gradedAt: weekStart)

        XCTAssertTrue(node.isValidNewGrade(weekStart: weekStart, weekEnd: weekEnd))
    }

    func test_returnsFalse_whenGradedAtIsBeforeWeekStart() {
        let node = makeNode(grade: "A", gradedAt: weekStart.addDays(-1))

        XCTAssertFalse(node.isValidNewGrade(weekStart: weekStart, weekEnd: weekEnd))
    }

    func test_returnsFalse_whenGradedAtIsExactlyWeekEnd() {
        let node = makeNode(grade: "A", gradedAt: weekEnd)

        XCTAssertFalse(node.isValidNewGrade(weekStart: weekStart, weekEnd: weekEnd))
    }

    func test_returnsFalse_whenGradedAtIsAfterWeekEnd() {
        let node = makeNode(grade: "A", gradedAt: weekEnd.addDays(1))

        XCTAssertFalse(node.isValidNewGrade(weekStart: weekStart, weekEnd: weekEnd))
    }

    // MARK: - Private helpers

    private func makeNode(
        score: Double? = 80,
        grade: String? = "B",
        gradedAt: Date?,
        gradeHidden: Bool? = false
    ) -> GetRecentGradedSubmissionsRequest.Response.SubmissionNode {
        let assignment = GetRecentGradedSubmissionsRequest.Response.AssignmentNode(
            _id: "a1", name: "Test", htmlUrl: nil, pointsPossible: 100, gradingType: "points"
        )
        return GetRecentGradedSubmissionsRequest.Response.SubmissionNode(
            _id: "s1",
            score: score,
            grade: grade,
            excused: false,
            gradeHidden: gradeHidden,
            gradedAt: gradedAt,
            assignment: assignment
        )
    }
}
