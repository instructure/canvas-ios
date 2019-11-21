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

class GradesViewControllerTests: CoreTestCase {
    func testViewDidLoadNoGradingPeriods() {
        api.mock(
            GetCourseRequest(courseID: "1"),
            value: .make(id: "1", enrollments: [
                .make(
                    enrollment_state: .active,
                    type: "student",
                    user_id: "1",
                    computed_current_score: 100,
                    multiple_grading_periods_enabled: false,
                    current_grading_period_id: nil,
                    current_period_computed_current_score: nil
                ),
            ])
        )
        api.mock(
            GetEnrollmentsRequest(context: ContextModel(.course, id: "1"), userID: "1", gradingPeriodID: nil),
            value: [
                .make(
                    id: "1",
                    enrollment_state: .active,
                    type: "StudentEnrollment",
                    user_id: "1",
                    grades: APIEnrollment.Grades(
                        html_url: "/grades",
                        current_grade: nil,
                        final_grade: nil,
                        current_score: 100,
                        final_score: nil
                    )
                ),
            ]
        )
        api.mock(
            GetAssignmentGroupsRequest(courseID: "1", gradingPeriodID: nil, include: [.assignments]),
            value: [
                .make(id: "1", name: "One", position: 1, assignments: [.make(id: "1")]),
                .make(id: "2", name: "Two", position: 2, assignments: [.make(id: "2")]),
            ]
        )
        api.mock(
            GetAssignmentsRequest(courseID: "1", orderBy: .position, include: [.observed_users, .submission], perPage: 99),
            value: [
                .make(id: "1", course_id: "1", assignment_group_id: "1"),
                .make(id: "2", course_id: "1", assignment_group_id: "2"),
            ]
        )
        let viewController = GradesViewController.create(courseID: "1", userID: "1")
        viewController.view.layoutIfNeeded()
        XCTAssertEqual(viewController.tableView.numberOfSections, 2)
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 1)
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 1), 1)
        XCTAssertTrue(viewController.loadingView.isHidden)
        XCTAssertTrue(viewController.gradingPeriodView.isHidden)
        XCTAssertEqual(viewController.totalGradeLabel.text, "100%")
    }

    func testViewDidLoadMultipleGradingPeriods() {
        api.mock(
            GetCourseRequest(courseID: "1"),
            value: .make(id: "1", enrollments: [
                .make(
                    enrollment_state: .active,
                    type: "student",
                    user_id: "1",
                    computed_current_score: 100,
                    multiple_grading_periods_enabled: true,
                    current_grading_period_id: "1",
                    current_period_computed_current_score: 50
                ),
            ])
        )
        api.mock(
            GetEnrollmentsRequest(context: ContextModel(.course, id: "1"), userID: "1", gradingPeriodID: "1"),
            value: [
                .make(
                    id: "1",
                    enrollment_state: .active,
                    type: "StudentEnrollment",
                    user_id: "1",
                    grades: APIEnrollment.Grades(
                        html_url: "/grades",
                        current_grade: nil,
                        final_grade: nil,
                        current_score: 50,
                        final_score: nil
                    )
                ),
            ]
        )
        api.mock(
            GetAssignmentGroupsRequest(courseID: "1", gradingPeriodID: "1", include: [.assignments]),
            value: [
                .make(id: "1", name: "One", position: 1, assignments: [.make(id: "1")]),
                .make(id: "2", name: "Two", position: 2, assignments: [.make(id: "2")]),
            ]
        )
        api.mock(
            GetAssignmentsRequest(courseID: "1", orderBy: .position, include: [.observed_users, .submission], perPage: 99),
            value: [
                .make(id: "1", course_id: "1", assignment_group_id: "1"),
                .make(id: "2", course_id: "1", assignment_group_id: "2"),
            ]
        )
        api.mock(GetGradingPeriodsRequest(courseID: "1"), value: [.make(id: "1", title: "The One")])

        let viewController = GradesViewController.create(courseID: "1", userID: "1")
        viewController.view.layoutIfNeeded()
        XCTAssertEqual(viewController.tableView.numberOfSections, 2)
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 1)
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 1), 1)
        XCTAssertTrue(viewController.loadingView.isHidden)
        XCTAssertFalse(viewController.gradingPeriodView.isHidden)
        XCTAssertEqual(viewController.totalGradeLabel.text, "50%")
        XCTAssertEqual(viewController.gradingPeriodLabel.text, "The One")
        XCTAssertEqual(viewController.filterButton.title(for: .normal), "Clear filter")
        viewController.filterButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(viewController.filterButton.title(for: .normal), "Filter")
        XCTAssertEqual(viewController.gradingPeriodLabel.text, "All Grading Periods")
        XCTAssertEqual(viewController.totalGradeLabel.text, "100%")
    }
}
