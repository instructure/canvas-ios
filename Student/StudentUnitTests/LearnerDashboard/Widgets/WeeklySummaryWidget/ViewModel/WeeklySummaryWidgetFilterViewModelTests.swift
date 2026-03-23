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

import SwiftUI
import XCTest
@testable import Core
@testable import Student

final class WeeklySummaryWidgetFilterViewModelTests: StudentTestCase {

    // MARK: - count

    func test_count() {
        var testee = WeeklySummaryWidgetFilterViewModel.missing(assignments: [])
        XCTAssertEqual(testee.count, 0)

        testee = WeeklySummaryWidgetFilterViewModel.missing(assignments: makeAssignments(count: 3))
        XCTAssertEqual(testee.count, 3)
    }

    // MARK: - withExpandedState

    func test_withExpandedState_shouldUpdateA11yValueAndHint() {
        let testee = WeeklySummaryWidgetFilterViewModel.missing(assignments: [])
        let expandedState = InstUI.CollapseButtonExpandedState(isExpanded: true)
        let collapsedState = InstUI.CollapseButtonExpandedState(isExpanded: false)

        // WHEN expanded
        let expanded = testee.withExpandedState(true)
        // THEN
        XCTAssertEqual(expanded.accessibilityValue, expandedState.a11yValue)
        XCTAssertEqual(expanded.accessibilityHint, expandedState.a11yHint)

        // WHEN collapsed
        let collapsed = testee.withExpandedState(false)
        // THEN
        XCTAssertEqual(collapsed.accessibilityValue, collapsedState.a11yValue)
        XCTAssertEqual(collapsed.accessibilityHint, collapsedState.a11yHint)
    }

    func test_withExpandedState_shouldNotChangeOtherProperties() {
        let original = WeeklySummaryWidgetFilterViewModel.due(assignments: makeAssignments(count: 2))
        let modified = original.withExpandedState(true)

        XCTAssertEqual(modified.id, original.id)
        XCTAssertEqual(modified.label, original.label)
        XCTAssertEqual(modified.emptyStateText, original.emptyStateText)
        XCTAssertEqual(modified.emptyStateIconName, original.emptyStateIconName)
        XCTAssertEqual(modified.accessibilityLabel, original.accessibilityLabel)
        XCTAssertEqual(modified.count, original.count)
    }

    // MARK: - Equatable

    func test_equality_withSameId_shouldBeEqual() {
        let first = WeeklySummaryWidgetFilterViewModel.missing(assignments: [])
        let second = WeeklySummaryWidgetFilterViewModel.missing(assignments: makeAssignments(count: 3))
        XCTAssertEqual(first, second)
    }

    func test_equality_withDifferentId_shouldNotBeEqual() {
        let missing = WeeklySummaryWidgetFilterViewModel.missing(assignments: [])
        let due = WeeklySummaryWidgetFilterViewModel.due(assignments: [])
        XCTAssertNotEqual(missing, due)
    }

    // MARK: - Static factories

    func test_missingFactory() {
        let collapsedState = InstUI.CollapseButtonExpandedState(isExpanded: false)

        // WHEN zero assignments
        var testee = WeeklySummaryWidgetFilterViewModel.missing(assignments: [])
        // THEN
        XCTAssertEqual(testee.id, "missing")
        XCTAssertEqual(testee.label, "Missing")
        XCTAssertEqual(testee.emptyStateIconName, "PandaSuper")
        XCTAssertEqual(testee.accessibilityLabel, "No missing submissions")
        XCTAssertEqual(testee.accessibilityValue, collapsedState.a11yValue)
        XCTAssertEqual(testee.accessibilityHint, collapsedState.a11yHint)

        // WHEN non-zero assignments
        testee = WeeklySummaryWidgetFilterViewModel.missing(assignments: makeAssignments(count: 3))
        // THEN
        XCTAssertEqual(testee.accessibilityLabel, "3 missing submissions")
    }

    func test_dueFactory() {
        // WHEN zero assignments
        var testee = WeeklySummaryWidgetFilterViewModel.due(assignments: [])
        // THEN
        XCTAssertEqual(testee.id, "due")
        XCTAssertEqual(testee.label, "Due")
        XCTAssertEqual(testee.emptyStateIconName, "PandaNoEvents")
        XCTAssertEqual(testee.accessibilityLabel, "No due submissions")

        // WHEN non-zero assignments
        testee = WeeklySummaryWidgetFilterViewModel.due(assignments: makeAssignments(count: 3))
        // THEN
        XCTAssertEqual(testee.accessibilityLabel, "3 due submissions")
    }

    func test_newGradesFactory() {
        // WHEN zero assignments
        var testee = WeeklySummaryWidgetFilterViewModel.newGrades(assignments: [])
        // THEN
        XCTAssertEqual(testee.id, "newGrades")
        XCTAssertEqual(testee.label, "New Grades")
        XCTAssertEqual(testee.emptyStateIconName, "PandaBook")
        XCTAssertEqual(testee.accessibilityLabel, "No new grades")

        // WHEN non-zero assignments
        testee = WeeklySummaryWidgetFilterViewModel.newGrades(assignments: makeAssignments(count: 3))
        // THEN
        XCTAssertEqual(testee.accessibilityLabel, "3 new grades")
    }

    // MARK: - Private helpers

    private func makeAssignments(count: Int) -> [WeeklySummaryWidgetAssignment] {
        (0..<count).map { index in
            WeeklySummaryWidgetAssignment(
                id: "id \(index)",
                courseId: "courseId \(index)",
                courseCode: "code \(index)",
                courseColor: .course1,
                icon: .assignmentLine,
                title: "title \(index)",
                dueDateText: nil,
                pointsText: nil,
                gradeWeightText: nil
            )
        }
    }
}
