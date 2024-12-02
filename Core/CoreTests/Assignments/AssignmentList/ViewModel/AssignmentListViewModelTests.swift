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

import TestsFoundation
@testable import Core

class AssignmentListViewModelTests: CoreTestCase {

    func testInitialState() {
        let testee = AssignmentListViewModel(context: .course("1"))
        XCTAssertEqual(testee.state, .loading)
        XCTAssertNil(testee.courseName)
        XCTAssertNil(testee.courseColor)
        XCTAssertNil(testee.defaultGradingPeriodId)
    }

    func testCoursePropertiesUpdate() {
        ContextColor.make(
            canvasContextID: "course_1",
            color: .red,
            in: databaseClient
        )
        api.mock(GetCourse(courseID: "1"), value: .make(name: "Test Course"))
        let testee = AssignmentListViewModel(context: .course("1"))

        testee.viewDidAppear()

        XCTAssertEqual(testee.courseName, "Test Course")
        XCTAssertEqual(testee.courseColor!.hexString, UIColor.red.ensureContrast(against: .backgroundLightest).hexString)
    }

    func testFilterButtonVisibleWhenTwoGradingPeriodsAvailable() {
        api.mock(
            GetGradingPeriods(courseID: "1"),
            value: [
                .make(id: "1", title: "GP1", start_date: .now.addMonths(-9), end_date: .now.addMonths(-3)),
                .make(id: "2", title: "GP2", start_date: .now.addMonths(-3), end_date: .now.addMonths(3))
            ]
        )

        // GetAssignmentsByGroup iterates through all grading periods so we have to mock it not to make the whole fetch fail
        var assignmentGroupRequest = GetAssignmentGroupsRequest(
            courseID: "1",
            gradingPeriodID: "1",
            perPage: 100
        )
        api.mock(assignmentGroupRequest, value: [])
        // GetAssignmentsByGroup iterates through all grading periods so we have to mock it not to make the whole fetch fail
        assignmentGroupRequest = GetAssignmentGroupsRequest(
            courseID: "1",
            gradingPeriodID: "2",
            perPage: 100
        )
        api.mock(assignmentGroupRequest, value: [])

        let testee = AssignmentListViewModel(context: .course("1"))

        testee.viewDidAppear()

        XCTAssertEqual(testee.defaultGradingPeriodId, "2")
    }

    func testAssignmentsPopulate() {
        api.mock(GetGradingPeriods(courseID: "1"), value: [])

        let assignmentGroups = [
            APIAssignmentGroup.make(id: "AG1", name: "AGroup1", position: 1, assignments: [.make(assignment_group_id: "AG1", id: "1", name: "Assignment1")]),
            APIAssignmentGroup.make(id: "AG2", name: "AGroup2", position: 2, assignments: [.make(assignment_group_id: "AG2", id: "2", name: "Assignment2")])
        ]
        let assignmentGroupRequest = GetAssignmentGroupsRequest(
            courseID: "1",
            gradingPeriodID: nil,
            perPage: 100
        )

        api.mock(assignmentGroupRequest, value: assignmentGroups)
        let testee = AssignmentListViewModel(context: .course("1"))

        testee.selectedSortingOption = .groupName
        testee.viewDidAppear()

        guard case .data(let groupViewModels) = testee.state else {
            XCTFail("State doesn't contain any view models.")
            return
        }

        guard let firstGroupViewModel = groupViewModels.filter({ $0.name == "AGroup1" }).first else {
            XCTFail("AssignmentGroup1 View Model is not available.")
            return
        }

        guard let secondGroupViewModel = groupViewModels.filter({ $0.name == "AGroup2" }).first else {
            XCTFail("AssignmentGroup2 View Model is not available.")
            return
        }

        XCTAssertEqual(groupViewModels.count, 2)
        XCTAssertEqual(firstGroupViewModel.name, "AGroup1")
        XCTAssertEqual(firstGroupViewModel.assignments.count, 1)
        XCTAssertEqual(firstGroupViewModel.assignments[0].name, "Assignment1")
        XCTAssertEqual(secondGroupViewModel.name, "AGroup2")
        XCTAssertEqual(secondGroupViewModel.assignments.count, 1)
        XCTAssertEqual(secondGroupViewModel.assignments[0].name, "Assignment2")
    }

    func testEmptyStateIfNoAssignments() {
        let assignmentGroups = [
            APIAssignmentGroup.make(id: "AG1", name: "AGroup1", position: 1, assignments: []),
            APIAssignmentGroup.make(id: "AG2", name: "AGroup2", position: 2, assignments: [])
        ]
        let assignmentGroupRequest = GetAssignmentGroupsRequest(
            courseID: "1",
            gradingPeriodID: nil,
            perPage: 100
        )
        api.mock(assignmentGroupRequest, value: assignmentGroups)
        let testee = AssignmentListViewModel(context: .course("1"))

        testee.viewDidAppear()

        XCTAssertEqual(testee.state, .empty)
    }

    func testGradingPeriodFilterChange() {
        api.mock(
            GetGradingPeriods(courseID: "1"),
            value: [
                .make(id: "1", title: "Past GP", start_date: Clock.now.addMonths(-2), end_date: Clock.now.addMonths(-1)),
                .make(id: "2", title: "Current GP", start_date: Clock.now.addMonths(-1), end_date: Clock.now.addMonths(1))
            ]
        )
        let gradingPeriods = AppEnvironment.shared.subscribe(GetGradingPeriods(courseID: "1"))
        let testee = AssignmentListViewModel(context: .course("1"))
        testee.selectedSortingOption = .groupName
        testee.viewDidAppear()
        XCTAssertEqual(testee.selectedGradingPeriodId, gradingPeriods[1]?.id)

        testee.filterOptionsDidUpdate(gradingPeriodId: gradingPeriods[0]?.id)
        XCTAssertEqual(testee.selectedGradingPeriodId, gradingPeriods[0]?.id)
    }
}
