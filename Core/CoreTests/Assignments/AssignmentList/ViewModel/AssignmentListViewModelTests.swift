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
        api.mock(
            GetGradingPeriods(courseID: "1"),
            value: [
                .make(id: "1", title: "GP1", start_date: .now.addMonths(-9), end_date: .now.addMonths(-3)),
                .make(id: "2", title: "GP2", start_date: .now.addMonths(-3), end_date: .now.addMonths(3))
            ]
        )

        let testee = AssignmentListViewModel(env: environment, context: .course("1"))

        XCTAssertEqual(testee.state, .loading)
        XCTAssertEqual(testee.defaultSortingOption, .dueDate)
        XCTAssertNil(testee.courseName)
        XCTAssertNil(testee.courseColor)
        XCTAssertNil(testee.defaultGradingPeriodId)

        testee.viewDidAppear()
        XCTAssertTrue(testee.isShowingGradingPeriods)
        XCTAssertEqual(testee.selectedGradingPeriodTitle, "GP2")
    }

    func testCoursePropertiesUpdate() {
        ContextColor.make(
            canvasContextID: "course_1",
            color: .red,
            in: databaseClient
        )
        api.mock(GetCourse(courseID: "1"), value: .make(name: "Test Course"))
        let testee = AssignmentListViewModel(env: environment, context: .course("1"))

        testee.viewDidAppear()

        XCTAssertEqual(testee.courseName, "Test Course")
        XCTAssertEqual(testee.courseColor!.hexString, UIColor.red.ensureContrast(against: .backgroundLightest).hexString)
    }

    func testDefaultGradingPeriod() {
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

        let testee = AssignmentListViewModel(env: environment, context: .course("1"))

        testee.viewDidAppear()

        XCTAssertTrue(testee.wasCurrentPeriodPreselected)
        XCTAssertEqual(testee.defaultGradingPeriodId, "2")
    }

    func testGroupeAssignmentsByAssignmentGroups() {
        api.mock(GetGradingPeriods(courseID: "1"), value: [])

        let assignmentGroups = [
            APIAssignmentGroup.make(id: "AG1", name: "AGroup1", position: 1, assignments: [
                .make(assignment_group_id: "AG1", due_at: Clock.now.addDays(1), id: "1", name: "Upcoming Assignment", submission_types: [.discussion_topic])
            ]),
            APIAssignmentGroup.make(id: "AG2", name: "AGroup2", position: 2, assignments: [
                .make(assignment_group_id: "AG2", due_at: Clock.now.addDays(-1), id: "2", name: "Overdue Assignment", quiz_id: "1")
            ]),
            APIAssignmentGroup.make(id: "AG3", name: "AGroup3", position: 3, assignments: [
                .make(assignment_group_id: "AG3", id: "3", name: "Undated Assignment", submission_types: [.external_tool]),
                .make(assignment_group_id: "AG3", id: "4", name: "Another Undated Assignment")
            ])
        ]
        let assignmentGroupRequest = GetAssignmentGroupsRequest(
            courseID: "1",
            gradingPeriodID: nil,
            perPage: 100
        )

        api.mock(assignmentGroupRequest, value: assignmentGroups)

        let testee = AssignmentListViewModel(env: environment, context: .course("1"))
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

        guard let thirdGroupViewModel = groupViewModels.filter({ $0.name == "AGroup3" }).first else {
            XCTFail("AssignmentGroup3 View Model is not available.")
            return
        }

        XCTAssertEqual(groupViewModels.count, 3)
        XCTAssertEqual(firstGroupViewModel.name, "AGroup1")
        XCTAssertEqual(firstGroupViewModel.assignments.count, 1)
        XCTAssertEqual(firstGroupViewModel.assignments[0].name, "Upcoming Assignment")
        XCTAssertEqual(secondGroupViewModel.name, "AGroup2")
        XCTAssertEqual(secondGroupViewModel.assignments.count, 1)
        XCTAssertEqual(secondGroupViewModel.assignments[0].name, "Overdue Assignment")
        XCTAssertEqual(thirdGroupViewModel.name, "AGroup3")
        XCTAssertEqual(thirdGroupViewModel.assignments.count, 2)
        XCTAssertEqual(thirdGroupViewModel.assignments[0].name, "Another Undated Assignment")
        XCTAssertEqual(thirdGroupViewModel.assignments[1].name, "Undated Assignment")
    }

    func testGroupAssignmentsByDueDate() {
        api.mock(GetGradingPeriods(courseID: "1"), value: [])

        let assignmentGroups = [
            APIAssignmentGroup.make(id: "AG1", name: "AGroup1", position: 1, assignments: [
                .make(assignment_group_id: "AG1", due_at: Clock.now.addDays(1), id: "1", name: "Upcoming Assignment", submission_types: [.discussion_topic])
            ]),
            APIAssignmentGroup.make(id: "AG2", name: "AGroup2", position: 2, assignments: [
                .make(assignment_group_id: "AG2", due_at: Clock.now.addDays(-1), id: "2", name: "Overdue Assignment", quiz_id: "1")
            ]),
            APIAssignmentGroup.make(id: "AG3", name: "AGroup3", position: 3, assignments: [
                .make(assignment_group_id: "AG3", id: "3", name: "Undated Assignment", submission_types: [.external_tool]),
                .make(assignment_group_id: "AG3", id: "4", name: "Another Undated Assignment")
            ])
        ]
        let assignmentGroupRequest = GetAssignmentGroupsRequest(
            courseID: "1",
            gradingPeriodID: nil,
            perPage: 100
        )

        api.mock(assignmentGroupRequest, value: assignmentGroups)

        let testee = AssignmentListViewModel(context: .course("1"))
        testee.selectedSortingOption = .dueDate
        testee.viewDidAppear()

        guard case .data(let groupViewModels) = testee.state else {
            XCTFail("State doesn't contain any view models.")
            return
        }

        guard let overdueGroupViewModel = groupViewModels.filter({ $0.name == "Overdue Assignments" }).first else {
            XCTFail("Overdue Assignments View Model is not available.")
            return
        }

        guard let upcomingGroupViewModel = groupViewModels.filter({ $0.name == "Upcoming Assignments" }).first else {
            XCTFail("Upcoming Assignments View Model is not available.")
            return
        }

        guard let undatedGroupViewModel = groupViewModels.filter({ $0.name == "Undated Assignments" }).first else {
            XCTFail("Undated Assignments View Model is not available.")
            return
        }

        XCTAssertEqual(groupViewModels.count, 3)
        XCTAssertEqual(overdueGroupViewModel.id, "overdue")
        XCTAssertEqual(overdueGroupViewModel.name, "Overdue Assignments")
        XCTAssertEqual(overdueGroupViewModel.assignments.count, 1)
        XCTAssertEqual(overdueGroupViewModel.assignments[0].name, "Overdue Assignment")
        XCTAssertEqual(upcomingGroupViewModel.id, "upcoming")
        XCTAssertEqual(upcomingGroupViewModel.name, "Upcoming Assignments")
        XCTAssertEqual(upcomingGroupViewModel.assignments.count, 1)
        XCTAssertEqual(upcomingGroupViewModel.assignments[0].name, "Upcoming Assignment")
        XCTAssertEqual(undatedGroupViewModel.id, "undated")
        XCTAssertEqual(undatedGroupViewModel.name, "Undated Assignments")
        XCTAssertEqual(undatedGroupViewModel.assignments.count, 2)
        XCTAssertEqual(undatedGroupViewModel.assignments[0].name, "Another Undated Assignment")
        XCTAssertEqual(undatedGroupViewModel.assignments[1].name, "Undated Assignment")
    }

    func testGroupAssignmentsByAssignmentType() {
        api.mock(GetGradingPeriods(courseID: "1"), value: [])

        let assignmentGroups = [
            APIAssignmentGroup.make(id: "AG1", name: "AGroup1", position: 1, assignments: [
                .make(assignment_group_id: "AG1", due_at: Clock.now.addDays(1), id: "1", name: "Upcoming Assignment", submission_types: [.discussion_topic])
            ]),
            APIAssignmentGroup.make(id: "AG2", name: "AGroup2", position: 2, assignments: [
                .make(assignment_group_id: "AG2", due_at: Clock.now.addDays(-1), id: "2", name: "Overdue Assignment", quiz_id: "1")
            ]),
            APIAssignmentGroup.make(id: "AG3", name: "AGroup3", position: 3, assignments: [
                .make(assignment_group_id: "AG3", id: "3", name: "Undated Assignment", submission_types: [.external_tool]),
                .make(assignment_group_id: "AG3", id: "4", name: "Another Undated Assignment")
            ])
        ]
        let assignmentGroupRequest = GetAssignmentGroupsRequest(
            courseID: "1",
            gradingPeriodID: nil,
            perPage: 100
        )

        api.mock(assignmentGroupRequest, value: assignmentGroups)

        let testee = AssignmentListViewModel(context: .course("1"))
        testee.selectedSortingOption = .assignmentType
        testee.viewDidAppear()

        guard case .data(let groupViewModels) = testee.state else {
            XCTFail("State doesn't contain any view models.")
            return
        }

        guard let normalGroupViewModel = groupViewModels.filter({ $0.name == "Assignments" }).first else {
            XCTFail("Normal Assignments View Model is not available.")
            return
        }

        guard let discussionGroupViewModel = groupViewModels.filter({ $0.name == "Discussions" }).first else {
            XCTFail("Discussion Assignments View Model is not available.")
            return
        }

        guard let quizGroupViewModel = groupViewModels.filter({ $0.name == "Quiz" }).first else {
            XCTFail("Quiz Assignments View Model is not available.")
            return
        }

        guard let ltiGroupViewModel = groupViewModels.filter({ $0.name == "LTI" }).first else {
            XCTFail("LTI Assignments View Model is not available.")
            return
        }

        XCTAssertEqual(groupViewModels.count, 4)
        XCTAssertEqual(normalGroupViewModel.id, "normal")
        XCTAssertEqual(normalGroupViewModel.name, "Assignments")
        XCTAssertEqual(normalGroupViewModel.assignments.count, 1)
        XCTAssertEqual(normalGroupViewModel.assignments[0].name, "Another Undated Assignment")
        XCTAssertEqual(discussionGroupViewModel.id, "discussions")
        XCTAssertEqual(discussionGroupViewModel.name, "Discussions")
        XCTAssertEqual(discussionGroupViewModel.assignments.count, 1)
        XCTAssertEqual(discussionGroupViewModel.assignments[0].name, "Upcoming Assignment")
        XCTAssertEqual(quizGroupViewModel.id, "quizzes")
        XCTAssertEqual(quizGroupViewModel.name, "Quiz")
        XCTAssertEqual(quizGroupViewModel.assignments.count, 1)
        XCTAssertEqual(quizGroupViewModel.assignments[0].name, "Overdue Assignment")
        XCTAssertEqual(ltiGroupViewModel.id, "lti")
        XCTAssertEqual(ltiGroupViewModel.name, "LTI")
        XCTAssertEqual(ltiGroupViewModel.assignments.count, 1)
        XCTAssertEqual(ltiGroupViewModel.assignments[0].name, "Undated Assignment")
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
        let testee = AssignmentListViewModel(env: environment, context: .course("1"))

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
        let gradingPeriods = environment.subscribe(GetGradingPeriods(courseID: "1"))
        let testee = AssignmentListViewModel(env: environment, context: .course("1"))
        testee.viewDidAppear()
        XCTAssertEqual(testee.selectedGradingPeriodId, gradingPeriods[1]?.id)

        testee.filterOptionsDidUpdate(gradingPeriodId: gradingPeriods[0]?.id)
        XCTAssertEqual(testee.selectedGradingPeriodId, gradingPeriods[0]?.id)
    }

    func testAssignmentArrangementOptions() {
        XCTAssertEqual(AssignmentListViewModel.AssignmentArrangementOptions.dueDate.title, "Due Date")
        XCTAssertEqual(AssignmentListViewModel.AssignmentArrangementOptions.groupName.title, "Group")
        XCTAssertEqual(AssignmentListViewModel.AssignmentArrangementOptions.assignmentGroup.title, "Assignment Group")
        XCTAssertEqual(AssignmentListViewModel.AssignmentArrangementOptions.assignmentType.title, "Assignment Type")
    }

    func testFilterOptionsDidUpdate() {
        let testee = AssignmentListViewModel(context: .course("1"))
        api.mock(
            GetGradingPeriods(courseID: "1"),
            value: [
                .make(id: "1", title: "GP1", start_date: .now.addMonths(-9), end_date: .now.addMonths(-3)),
                .make(id: "2", title: "GP2", start_date: .now.addMonths(-3), end_date: .now.addMonths(3))
            ]
        )
        testee.viewDidAppear()
        testee.filterOptionsDidUpdate(
            filterOptionsStudent: [.notYetSubmitted],
            filterOptionTeacher: .notSubmitted,
            statusFilterOptionTeacher: .published,
            sortingOption: .assignmentType,
            gradingPeriodId: "1"
        )

        XCTAssertEqual(testee.selectedSortingOption, .assignmentType)
        XCTAssertEqual(testee.selectedGradingPeriodId, "1")
        XCTAssertEqual(testee.selectedGradingPeriodTitle, "GP1")
        XCTAssertTrue(testee.isFilterIconSolid)
    }
}
