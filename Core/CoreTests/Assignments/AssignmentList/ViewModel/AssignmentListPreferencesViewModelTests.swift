//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

@testable import Core
import TestsFoundation

final class AssignmentListPreferencesViewModelTests: CoreTestCase {
    private var testee: AssignmentListPreferencesViewModel!
    private var gradingPeriods: [GradingPeriod]!
    private var listPreferences: AssignmentListPreferencesViewModel.AssignmentListPreferences?

    override func setUp() {
        super.setUp()

        gradingPeriods = [
            .save(.make(id: "1", title: "Spring"), courseID: "1", in: database.viewContext),
            .save(.make(id: "2", title: "Summer"), courseID: "2", in: database.viewContext),
            .save(.make(id: "3", title: "Autumn"), courseID: "3", in: database.viewContext),
            .save(.make(id: "4", title: "Winter"), courseID: "4", in: database.viewContext)
        ]

        testee = AssignmentListPreferencesViewModel(
            sortingOptions: AssignmentListViewModel.AssignmentArrangementOptions.allCases,
            initialSortingOption: .dueDate,
            gradingPeriods: gradingPeriods,
            initialGradingPeriod: nil,
            courseName: "Test Course",
            env: PreviewEnvironment.shared,
            completion: { [weak self] assignmentListPreferences in
                self?.listPreferences = assignmentListPreferences
            }
        )
    }

    func testInitialState() {
        XCTAssertEqual(testee.courseName, "Test Course")
        XCTAssertEqual(testee.gradingPeriods, gradingPeriods)
        XCTAssertEqual(testee.sortingOptions, AssignmentListViewModel.AssignmentArrangementOptions.allCases)
        XCTAssertTrue(testee.isFilterSectionVisible)
        XCTAssertTrue(testee.isGradingPeriodsSectionVisible)
        XCTAssertEqual(testee.selectedSortingOption, AssignmentListViewModel.AssignmentArrangementOptions.dueDate)
        XCTAssertEqual(testee.selectedGradingPeriod, nil)
        XCTAssertEqual(testee.selectedAssignmentFilterOptions, AssignmentFilterOption.allCases)
    }

    func testDidSelectAssignmentFilterOption() {
        testee.didSelectAssignmentFilterOption(AssignmentFilterOption.notYetSubmitted, isSelected: false)
        XCTAssertFalse(testee.selectedAssignmentFilterOptions.contains(AssignmentFilterOption.notYetSubmitted))

        testee.didSelectAssignmentFilterOption(AssignmentFilterOption.notYetSubmitted, isSelected: true)
        XCTAssertTrue(testee.selectedAssignmentFilterOptions.contains(AssignmentFilterOption.notYetSubmitted))

        testee.didSelectAssignmentFilterOption(AssignmentFilterOption.toBeGraded, isSelected: false)
        XCTAssertFalse(testee.selectedAssignmentFilterOptions.contains(AssignmentFilterOption.toBeGraded))

        testee.didSelectAssignmentFilterOption(AssignmentFilterOption.toBeGraded, isSelected: true)
        XCTAssertTrue(testee.selectedAssignmentFilterOptions.contains(AssignmentFilterOption.toBeGraded))

        testee.didSelectAssignmentFilterOption(AssignmentFilterOption.graded, isSelected: false)
        XCTAssertFalse(testee.selectedAssignmentFilterOptions.contains(AssignmentFilterOption.graded))

        testee.didSelectAssignmentFilterOption(AssignmentFilterOption.graded, isSelected: true)
        XCTAssertTrue(testee.selectedAssignmentFilterOptions.contains(AssignmentFilterOption.graded))
    }

    func testCompletion() {
        testee.selectedSortingOption = nil
        testee.didDismiss()
        XCTAssertNotNil(listPreferences)
        XCTAssertNotNil(listPreferences!.sortingOption)
        XCTAssertEqual(listPreferences!.sortingOption, AssignmentListViewModel.AssignmentArrangementOptions.dueDate)
    }
}
