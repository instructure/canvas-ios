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

class GradeListViewControllerTests: CoreTestCase {
    lazy var controller = GradeListViewController.create(courseID: "1")

    lazy var groups: [APIAssignmentGroup] = [
        .make(id: "1", name: "Worksheets", position: 2, assignments: [ .make(
            id: "1",
            course_id: "1",
            name: "Complex Numbers",
            points_possible: 25,
            due_at: DateComponents(calendar: .current, year: 2020, month: 1, day: 1).date,
            submission: APISubmission.make(
                id: "1",
                assignment_id: "1",
                user_id: ID(currentSession.userID),
                grade: "20",
                score: 20,
                submitted_at: DateComponents(calendar: .current, year: 2020, month: 1, day: 2).date,
                late: true,
                workflow_state: .submitted,
                attempt: 1,
                grade_matches_current_submission: true,
                late_policy_status: .late,
                points_deducted: 2
            ),
            grading_type: .points,
            assignment_group_id: "1"
        ), ]),
        .make(id: "2", name: "Essays", position: 1, assignments: [ .make(
            id: "2",
            course_id: "1",
            name: "Proof that proofs are useful",
            assignment_group_id: "2"
        ), ]),
    ]

    func mockGrades(gradingPeriodID: String?, score: Double?) {
        api.mock(GetEnrollments(
            context: .course("1"),
            userID: currentSession.userID,
            gradingPeriodID: gradingPeriodID,
            types: [ "StudentEnrollment" ],
            states: [ .active ]
        ), value: [ .make(
            id: "1",
            course_id: "1",
            enrollment_state: .active,
            type: "StudentEnrollment",
            user_id: self.currentSession.userID,
            grades: .make(
                current_grade: score.flatMap { String($0) },
                final_grade: score.flatMap { String($0) },
                current_score: score,
                final_score: score
            )
        ), ])
    }

    override func setUp() {
        super.setUp()
        api.mock(GetAssignmentsByGroup(courseID: "1"), value: groups)
        api.mock(GetAssignmentsByGroup(courseID: "1", gradingPeriodID: "1"), value: [ groups[0] ])
        api.mock(GetAssignmentsByGroup(courseID: "1", gradingPeriodID: "2"), value: [ groups[1] ])
        api.mock(controller.colors, value: .init(custom_colors: [ "course_1": "#008800" ]))
        api.mock(controller.courses, value: .make(enrollments: [ .make(
            id: nil,
            course_id: "1",
            enrollment_state: .active,
            user_id: currentSession.userID,
            multiple_grading_periods_enabled: true,
            current_grading_period_id: "1"
        ), ]))
        mockGrades(gradingPeriodID: nil, score: 20)
        mockGrades(gradingPeriodID: "1", score: 20)
        mockGrades(gradingPeriodID: "2", score: nil)
        api.mock(controller.gradingPeriods, value: [
            .make(id: "1", title: "One", start_date: Clock.now.addDays(-7)),
            .make(id: "2", title: "Two", start_date: Clock.now.addDays(7)),
        ])
    }

    func testLayout() {
        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(nav.navigationBar.barTintColor?.hexString, "#008800")
        XCTAssertEqual(controller.titleSubtitleView.title, "Grades")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Course One")

        XCTAssertEqual(controller.gradingPeriodLabel.text, "One")
        XCTAssertEqual(controller.filterButton.title(for: .normal), "Filter")
        XCTAssertEqual(controller.totalGradeLabel.text, "20%")

        let index00 = IndexPath(row: 0, section: 0)
        var cell00 = controller.tableView.cellForRow(at: index00) as? GradeListCell
        XCTAssertEqual(cell00?.nameLabel.text, "Complex Numbers")
        XCTAssertEqual(cell00?.gradeLabel.text, "20 / 25")
        XCTAssertEqual(cell00?.dueLabel.text, "Due Jan 1, 2020 at 12:00 AM")
        XCTAssertEqual(cell00?.statusLabel.text, "Late")

        controller.tableView.selectRow(at: index00, animated: false, scrollPosition: .none)
        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: index00)
        XCTAssert(router.lastRoutedTo("/courses/1/assignments/1", withOptions: .detail))

        XCTAssertEqual(controller.tableView.indexPathForSelectedRow, index00)
        controller.viewWillAppear(false)
        XCTAssertNil(controller.tableView.indexPathForSelectedRow)

        XCTAssertEqual(controller.tableView.numberOfSections, 1)
        controller.filterButton.sendActions(for: .primaryActionTriggered)
        let alert = router.presented as? UIAlertController
        XCTAssertEqual(alert?.message, "Filter by:")
        let two = alert?.actions[2] as? AlertAction
        XCTAssertEqual(two?.title, "Two")
        two?.handler?(AlertAction())
        XCTAssertEqual(controller.tableView.numberOfSections, 1)
        cell00 = controller.tableView.cellForRow(at: index00) as? GradeListCell
        XCTAssertEqual(cell00?.nameLabel.text, "Proof that proofs are useful")

        api.mock(GetAssignmentsByGroup(courseID: "1"), error: NSError.internalError())
        (alert?.actions[0] as? AlertAction)?.handler?(AlertAction())
        XCTAssertEqual(controller.errorView.isHidden, false)
        XCTAssertEqual(controller.errorView.messageLabel.text, "There was an error loading grades. Pull to refresh to try again.")

        api.mock(GetAssignmentsByGroup(courseID: "1"), value: [])
        controller.errorView.retryButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.refreshControl.isRefreshing, false)
        XCTAssertEqual(controller.errorView.isHidden, true)
        XCTAssertEqual(controller.emptyView.isHidden, false)
        XCTAssertEqual(controller.emptyTitleLabel.text, "No Assignments")
        XCTAssertEqual(controller.emptyMessageLabel.text, "It looks like assignments haven’t been created in this space yet.")

        api.mock(GetAssignmentsByGroup(courseID: "1"), error: NSError.internalError())
        controller.tableView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.errorView.isHidden, false)
        XCTAssertEqual(controller.emptyView.isHidden, true)

        XCTAssertNoThrow(controller.viewWillDisappear(false))
    }

    func testHideTotals() {
        api.mock(controller.courses, value: .make(enrollments: [ .make(
            id: nil,
            course_id: "1",
            enrollment_state: .active,
            user_id: currentSession.userID,
            multiple_grading_periods_enabled: true,
            current_grading_period_id: "1"
        ), ], hide_final_grades: true))
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.totalGradeLabel.text, "N/A")
    }

    func testPaginatedRefresh() {
        controller.view.layoutIfNeeded()
        api.mock(GetAssignmentsByGroup(courseID: "1", gradingPeriodID: "1"), value: [ groups[0] ], response: HTTPURLResponse(next: "/courses/1/assignment_groups?page=2"))
        api.mock(GetNextRequest(path: "/courses/1/assignment_groups?page=2"), value: [ groups[1] ])
        let tableView = controller.tableView!
        tableView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0), 2)
        let loading = tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as? LoadingCell
        XCTAssertNotNil(loading)
        XCTAssertEqual(tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0), 1)
        XCTAssertEqual(tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 1), 1)
        let cell = tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1)) as! GradeListCell
        XCTAssertEqual(cell.nameLabel.text, "Complex Numbers")
    }
}
