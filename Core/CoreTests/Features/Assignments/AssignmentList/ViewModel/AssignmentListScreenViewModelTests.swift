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
import XCTest

class AssignmentListScreenViewModelTests: CoreTestCase {

    func testInitialState() {
        api.mock(
            GetGradingPeriods(courseID: "1"),
            value: [
                .make(id: "1", title: "GP1", start_date: .now.addMonths(-9), end_date: .now.addMonths(-3)),
                .make(id: "2", title: "GP2", start_date: .now.addMonths(-3), end_date: .now.addMonths(3))
            ]
        )

        let testee = AssignmentListScreenViewModel(env: environment, context: .course("1"))

        XCTAssertEqual(testee.defaultSortingOption, .dueDate)
        XCTAssertNil(testee.courseName)
        XCTAssertNil(testee.courseColor)
        XCTAssertEqual(testee.defaultGradingPeriodId, "2")

        testee.viewDidAppear()
        XCTAssertEqual(testee.selectedGradingPeriodTitle, "GP2")
    }

    func testCoursePropertiesUpdate() {
        ContextColor.make(
            canvasContextID: "course_1",
            color: .red,
            in: databaseClient
        )
        api.mock(GetCourse(courseID: "1"), value: .make(name: "Test Course"))
        let testee = AssignmentListScreenViewModel(env: environment, context: .course("1"))

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

        let testee = AssignmentListScreenViewModel(env: environment, context: .course("1"))

        testee.viewDidAppear()

        XCTAssertTrue(testee.wasCurrentPeriodPreselected)
        XCTAssertEqual(testee.defaultGradingPeriodId, "2")
    }

    func testGroupAssignmentsByAssignmentGroups() {
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

        let testee = AssignmentListScreenViewModel(env: environment, context: .course("1"))
        testee.filterOptionsDidUpdate(sortingOption: .groupName, gradingPeriodId: nil)
        testee.viewDidAppear()

        XCTAssertEqual(testee.state, .data)

        let sections = testee.sections

        guard let firstSection = sections.filter({ $0.title == "AGroup1" }).first else {
            XCTFail("AssignmentGroup1 View Model is not available.")
            return
        }

        guard let secondSection = sections.filter({ $0.title == "AGroup2" }).first else {
            XCTFail("AssignmentGroup2 View Model is not available.")
            return
        }

        guard let thirdSection = sections.filter({ $0.title == "AGroup3" }).first else {
            XCTFail("AssignmentGroup3 View Model is not available.")
            return
        }

        XCTAssertEqual(sections.count, 3)
        XCTAssertEqual(firstSection.title, "AGroup1")
        XCTAssertEqual(firstSection.rows.count, 1)
        XCTAssertEqual(firstSection.rows[0].title, "Upcoming Assignment")
        XCTAssertEqual(secondSection.title, "AGroup2")
        XCTAssertEqual(secondSection.rows.count, 1)
        XCTAssertEqual(secondSection.rows[0].title, "Overdue Assignment")
        XCTAssertEqual(thirdSection.title, "AGroup3")
        XCTAssertEqual(thirdSection.rows.count, 2)
        XCTAssertEqual(thirdSection.rows[0].title, "Another Undated Assignment")
        XCTAssertEqual(thirdSection.rows[1].title, "Undated Assignment")
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

        let testee = AssignmentListScreenViewModel(env: environment, context: .course("1"))
        testee.selectedSortingOption = .dueDate
        testee.viewDidAppear()

        XCTAssertEqual(testee.state, .data)

        let sections = testee.sections

        guard let overdueSection = sections.filter({ $0.title == "Overdue Assignments" }).first else {
            XCTFail("Overdue Assignments View Model is not available.")
            return
        }

        guard let upcomingSection = sections.filter({ $0.title == "Upcoming Assignments" }).first else {
            XCTFail("Upcoming Assignments View Model is not available.")
            return
        }

        guard let undatedSection = sections.filter({ $0.title == "Undated Assignments" }).first else {
            XCTFail("Undated Assignments View Model is not available.")
            return
        }

        XCTAssertEqual(sections.count, 3)
        XCTAssertEqual(overdueSection.id, "overdue")
        XCTAssertEqual(overdueSection.title, "Overdue Assignments")
        XCTAssertEqual(overdueSection.rows.count, 1)
        XCTAssertEqual(overdueSection.rows[0].title, "Overdue Assignment")
        XCTAssertEqual(upcomingSection.id, "upcoming")
        XCTAssertEqual(upcomingSection.title, "Upcoming Assignments")
        XCTAssertEqual(upcomingSection.rows.count, 1)
        XCTAssertEqual(upcomingSection.rows[0].title, "Upcoming Assignment")
        XCTAssertEqual(undatedSection.id, "undated")
        XCTAssertEqual(undatedSection.title, "Undated Assignments")
        XCTAssertEqual(undatedSection.rows.count, 2)
        XCTAssertEqual(undatedSection.rows[0].title, "Another Undated Assignment")
        XCTAssertEqual(undatedSection.rows[1].title, "Undated Assignment")
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

        let testee = AssignmentListScreenViewModel(env: environment, context: .course("1"))
        testee.filterOptionsDidUpdate(sortingOption: .assignmentType, gradingPeriodId: nil)
        testee.viewDidAppear()

        XCTAssertEqual(testee.state, .data)

        let sections = testee.sections

        guard let normalSection = sections.filter({ $0.title == "Assignments" }).first else {
            XCTFail("Normal Assignments View Model is not available.")
            return
        }

        guard let discussionSection = sections.filter({ $0.title == "Discussions" }).first else {
            XCTFail("Discussion Assignments View Model is not available.")
            return
        }

        guard let quizSection = sections.filter({ $0.title == "Quizzes" }).first else {
            XCTFail("Quiz Assignments View Model is not available.")
            return
        }

        guard let ltiSection = sections.filter({ $0.title == "LTI" }).first else {
            XCTFail("LTI Assignments View Model is not available.")
            return
        }

        XCTAssertEqual(sections.count, 4)
        XCTAssertEqual(normalSection.id, "normal")
        XCTAssertEqual(normalSection.title, "Assignments")
        XCTAssertEqual(normalSection.rows.count, 1)
        XCTAssertEqual(normalSection.rows[0].title, "Another Undated Assignment")
        XCTAssertEqual(discussionSection.id, "discussions")
        XCTAssertEqual(discussionSection.title, "Discussions")
        XCTAssertEqual(discussionSection.rows.count, 1)
        XCTAssertEqual(discussionSection.rows[0].title, "Upcoming Assignment")
        XCTAssertEqual(quizSection.id, "quizzes")
        XCTAssertEqual(quizSection.title, "Quizzes")
        XCTAssertEqual(quizSection.rows.count, 1)
        XCTAssertEqual(quizSection.rows[0].title, "Overdue Assignment")
        XCTAssertEqual(ltiSection.id, "lti")
        XCTAssertEqual(ltiSection.title, "LTI")
        XCTAssertEqual(ltiSection.rows.count, 1)
        XCTAssertEqual(ltiSection.rows[0].title, "Undated Assignment")
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
        let testee = AssignmentListScreenViewModel(env: environment, context: .course("1"))

        testee.viewDidAppear()

        XCTAssertEqual(testee.state, .empty)
        XCTAssertEqual(testee.sections, [])
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
        let testee = AssignmentListScreenViewModel(env: environment, context: .course("1"))
        testee.viewDidAppear()
        XCTAssertEqual(testee.selectedGradingPeriodId, gradingPeriods[1]?.id)

        testee.filterOptionsDidUpdate(gradingPeriodId: gradingPeriods[0]?.id)
        XCTAssertEqual(testee.selectedGradingPeriodId, gradingPeriods[0]?.id)
    }

    func testFilterOptionsDidUpdate() {
        api.mock(
            GetGradingPeriods(courseID: "1"),
            value: [
                .make(id: "1", title: "GP1", start_date: .now.addMonths(-9), end_date: .now.addMonths(-3)),
                .make(id: "2", title: "GP2", start_date: .now.addMonths(-3), end_date: .now.addMonths(3))
            ]
        )
        let testee = AssignmentListScreenViewModel(env: environment, context: .course("1"))
        testee.viewDidAppear()
        XCTAssertEqual(testee.selectedSortingOption, .dueDate)
        XCTAssertEqual(testee.selectedGradingPeriodId, "2")
        XCTAssertEqual(testee.selectedGradingPeriodTitle, "GP2")
        XCTAssertFalse(testee.isFilterIconSolid)

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

private extension AssignmentListSection.Row {
    var title: String {
        switch self {
        case .student(let model):
            model.title
        case .teacher(let model):
            model.title
        case .gradeListRow(let model):
            model.title
        }
    }
}
