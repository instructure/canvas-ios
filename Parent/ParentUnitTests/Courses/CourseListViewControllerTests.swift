//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import Parent
import TestsFoundation

class CourseListViewControllerTests: ParentTestCase {
    lazy var controller = Parent.CourseListViewController.create(studentID: "12")

    override func setUp() {
        super.setUp()
        api.mock(controller.courses, value: [
            .make(
                id: "1", name: "Course A", course_code: "CRS-1",
                enrollments: [
                    .make(
                        id: "1",
                        course_id: "1"
                    )
                ]
            ),
            .make(
                id: "2", name: "Course B", course_code: "CRS-2",
                enrollments: [
                    .make(
                        id: "2",
                        course_id: "2",
                        multiple_grading_periods_enabled: true,
                        current_grading_period_id: "2",
                        current_period_computed_current_score: 95,
                        current_period_computed_current_grade: "A"
                    )
                ]
            ),
            .make(
                id: "3", name: "Course C", course_code: "CRS-3",
                enrollments: [
                    .make(
                        id: "3",
                        course_id: "3",
                        computed_current_score: 85,
                        computed_current_grade: nil,
                        multiple_grading_periods_enabled: true,
                        totals_for_all_grading_periods_option: true,
                        current_grading_period_id: nil
                    )
                ]
            ),
            .make(
                id: "4", name: "Course D", course_code: "CRS-4",
                enrollments: [
                    .make(
                        id: "4",
                        course_id: "4",
                        computed_current_score: nil,
                        computed_current_grade: "C",
                        multiple_grading_periods_enabled: true,
                        totals_for_all_grading_periods_option: true,
                        current_grading_period_id: nil
                    )
                ]
            ),
            .make(
                id: "5", name: "Course E", course_code: "CRS-5",
                enrollments: [
                    .make(
                        id: "5",
                        course_id: "5",
                        computed_final_score: nil,
                        computed_final_grade: "C",
                        multiple_grading_periods_enabled: true,
                        totals_for_all_grading_periods_option: false,
                        current_grading_period_id: nil
                    )
                ]
            ),
            .make(
                id: "6", name: "Course F (graded but hidden)", course_code: "CRS-6",
                enrollments: [
                    .make(
                        id: "6",
                        course_id: "6",
                        computed_final_score: 85,
                        computed_final_grade: nil
                    )
                ], hide_final_grades: true
            )

        ])
    }

    func testLayout() {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 6)

        var index = IndexPath(row: 0, section: 0)
        var cell = controller.tableView.cellForRow(at: index) as? Parent.CourseListCell
        XCTAssertEqual(cell?.nameLabel.text, "Course A")
        XCTAssertEqual(cell?.codeLabel.text, "CRS-1")
        XCTAssertEqual(cell?.gradeLabel.text, "No Grade")

        index = IndexPath(row: 1, section: 0)
        cell = controller.tableView.cellForRow(at: index) as? Parent.CourseListCell
        XCTAssertEqual(cell?.nameLabel.text, "Course B")
        XCTAssertEqual(cell?.codeLabel.text, "CRS-2")
        XCTAssertEqual(cell?.gradeLabel.text, "A   95%")

        index = IndexPath(row: 2, section: 0)
        cell = controller.tableView.cellForRow(at: index) as? Parent.CourseListCell
        XCTAssertEqual(cell?.nameLabel.text, "Course C")
        XCTAssertEqual(cell?.codeLabel.text, "CRS-3")
        XCTAssertEqual(cell?.gradeLabel.text, "85%")

        index = IndexPath(row: 3, section: 0)
        cell = controller.tableView.cellForRow(at: index) as? Parent.CourseListCell
        XCTAssertEqual(cell?.nameLabel.text, "Course D")
        XCTAssertEqual(cell?.codeLabel.text, "CRS-4")
        XCTAssertEqual(cell?.gradeLabel.text, "C")

        index = IndexPath(row: 4, section: 0)
        cell = controller.tableView.cellForRow(at: index) as? Parent.CourseListCell
        XCTAssertEqual(cell?.nameLabel.text, "Course E")
        XCTAssertEqual(cell?.codeLabel.text, "CRS-5")
        XCTAssertEqual(cell?.gradeLabel.text, "N/A")

        index = IndexPath(row: 5, section: 0)
        cell = controller.tableView.cellForRow(at: index) as? Parent.CourseListCell
        XCTAssertEqual(cell?.nameLabel.text, "Course F (graded but hidden)")
        XCTAssertEqual(cell?.codeLabel.text, "CRS-6")
        XCTAssertEqual(cell?.gradeLabel.text, "")

        controller.tableView.selectRow(at: index, animated: false, scrollPosition: .none)
        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: index)
        XCTAssert(router.lastRoutedTo("/courses/6/grades"))
        controller.viewWillAppear(false)
        XCTAssertNil(controller.tableView.indexPathForSelectedRow)

        api.mock(controller.courses, error: NSError.internalError())
        controller.tableView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.errorView.isHidden, false)
        XCTAssertEqual(controller.errorView.messageLabel.text, "There was an error loading courses. Pull to refresh to try again.")

        api.mock(controller.courses, value: [])
        controller.errorView.retryButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.errorView.isHidden, true)
        XCTAssertEqual(controller.emptyView.isHidden, false)
        XCTAssertEqual(controller.emptyTitleLabel.text, "No Courses")
        XCTAssertEqual(controller.emptyMessageLabel.text, "Your child’s courses might not be published yet.")
    }
}
