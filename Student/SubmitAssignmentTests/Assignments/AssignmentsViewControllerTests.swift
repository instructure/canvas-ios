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

import Foundation
@testable import Core
import TestsFoundation
import XCTest
@testable import SubmitAssignment

class AssignmentsViewControllerTests: SubmitAssignmentTestCase {
    var courseID = "1"
    var selectedAssignmentID: String?
    var selectedAssignment: Assignment?

    lazy var controller = AssignmentsViewController.create(
        courseID: courseID,
        selectedAssignmentID: selectedAssignmentID,
        callback: { [weak self] in self?.selectedAssignment = $0 }
    )

    func testLayout() {
        selectedAssignmentID = "1"
        api.mock(
            controller.assignments.useCase.request,
            value: [
                .make(
                    course_id: ID(courseID),
                    id: "1",
                    name: "Assignment 1",
                    submission_types: [.online_upload]
                ),
                .make(
                    course_id: ID(courseID),
                    id: "2",
                    name: "Assignment 2",
                    submission_types: [.online_upload]
                ),
            ]
        )
        controller.view.layoutIfNeeded()
        let tableView = controller.tableView
        XCTAssertEqual(controller.tableView.dataSource?.tableView(tableView!, numberOfRowsInSection: 0), 2)
        let firstCell = controller.tableView.dataSource?.tableView(tableView!, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(firstCell?.textLabel?.text, "Assignment 1")
        XCTAssertEqual(firstCell?.accessoryType, .checkmark)

        let secondCell = controller.tableView.dataSource?.tableView(tableView!, cellForRowAt: IndexPath(row: 1, section: 0))
        XCTAssertEqual(secondCell?.textLabel?.text, "Assignment 2")
        XCTAssertEqual(secondCell?.accessoryType, UITableViewCell.AccessoryType.none)

        controller.tableView.delegate?.tableView?(tableView!, didSelectRowAt: IndexPath(row: 1, section: 0))
        XCTAssertEqual(selectedAssignment?.name, "Assignment 2")
    }
}
