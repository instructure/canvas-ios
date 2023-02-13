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

class AssignmentListViewModelTests: CoreTestCase {

    func testInitialState() {
        let testee = AssignmentListViewModel(context: .course("1"))
        XCTAssertEqual(testee.state, .loading)
        XCTAssertNil(testee.courseName)
        XCTAssertNil(testee.courseColor)
        XCTAssertFalse(testee.shouldShowFilterButton)
    }

    func testCoursePropertiesUpdate() {
        let contextColor = ContextColor(context: databaseClient)
        contextColor.canvasContextID = "course_1"
        contextColor.color = .red
        api.mock(GetCourse(courseID: "1"), value: .make(name: "Test Course"))
        let testee = AssignmentListViewModel(context: .course("1"))

        testee.viewDidAppear()

        XCTAssertEqual(testee.courseName, "Test Course")
        XCTAssertEqual(testee.courseColor!.hexString, UIColor.red.ensureContrast(against: .backgroundLightest).hexString)
    }

    func testFilterButtonVisibleWhenTwoGradingPeriodsAvailable() {
        api.mock(GetGradingPeriods(courseID: "1"), value: [.make(id: "1", title: "GP1"), .make(id: "2", title: "GP2")])
        let testee = AssignmentListViewModel(context: .course("1"))

        testee.viewDidAppear()

        XCTAssertTrue(testee.shouldShowFilterButton)
    }

    func testAssignmentsPopulate() {
        let assignmentGroups = [
            APIAssignmentGroup.make(id: "AG1", name: "AGroup1", position: 1, assignments: [.make(assignment_group_id: "AG1", id: "1", name: "Assignment1")]),
            APIAssignmentGroup.make(id: "AG2", name: "AGroup2", position: 2, assignments: [.make(assignment_group_id: "AG2", id: "2", name: "Assignment2")]),
        ]
        api.mock(GetAssignmentsByGroup(courseID: "1"), value: assignmentGroups)
        let testee = AssignmentListViewModel(context: .course("1"))

        testee.viewDidAppear()

        guard case .data(let groupViewModels) = testee.state else {
            XCTFail("State doesn't contain any view models.")
            return
        }
        XCTAssertEqual(groupViewModels.count, 2)
        XCTAssertEqual(groupViewModels[0].name, "AGroup1")
        XCTAssertEqual(groupViewModels[0].assignments.count, 1)
        XCTAssertEqual(groupViewModels[0].assignments[0].name, "Assignment1")
        XCTAssertEqual(groupViewModels[1].name, "AGroup2")
        XCTAssertEqual(groupViewModels[1].assignments.count, 1)
        XCTAssertEqual(groupViewModels[1].assignments[0].name, "Assignment2")
    }

    func testEmptyStateIfNoAssignments() {
        let assignmentGroups = [
            APIAssignmentGroup.make(id: "AG1", name: "AGroup1", position: 1, assignments: []),
            APIAssignmentGroup.make(id: "AG2", name: "AGroup2", position: 2, assignments: []),
        ]
        api.mock(GetAssignmentsByGroup(courseID: "1"), value: assignmentGroups)
        let testee = AssignmentListViewModel(context: .course("1"))

        testee.viewDidAppear()

        XCTAssertEqual(testee.state, .empty)
    }

    func testGradingPeriodFilterChange() {
        // we modify the first grading period's start_date to make sure it is the first in the picker
        api.mock(GetGradingPeriods(courseID: "1"), value: [.make(id: "1", title: "GP1", start_date: Clock.now.addMonths(-1)), .make(id: "2", title: "GP2")])
        let testee = AssignmentListViewModel(context: .course("1"))
        testee.viewDidAppear()
        XCTAssertEqual(testee.state, .empty)
        api.mock(GetAssignmentsByGroup(courseID: "1", gradingPeriodID: "2"), value: [
            .make(id: "AG1", name: "AGroup1", position: 1, assignments: [.make(assignment_group_id: "AG1", id: "1", name: "Assignment1")]),
        ])

        testee.gradingPeriodSelected(testee.gradingPeriods[1])

        guard case .data(let groupViewModels) = testee.state else {
            XCTFail("State doesn't contain any view models.")
            return
        }
        XCTAssertEqual(groupViewModels.count, 1)
        XCTAssertEqual(groupViewModels[0].name, "AGroup1")
        XCTAssertEqual(groupViewModels[0].assignments.count, 1)
        XCTAssertEqual(groupViewModels[0].assignments[0].name, "Assignment1")
    }
}
