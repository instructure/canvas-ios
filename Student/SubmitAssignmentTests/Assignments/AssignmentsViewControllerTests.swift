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

class AssignmentsViewControllerTests: SubmitAssignmentTests {
    var courseID = "1"
    var selectedAssignmentID: String?
    var callback: (Assignment) -> Void = { _ in }

    lazy var controller = AssignmentsViewController.create(
        courseID: courseID,
        selectedAssignmentID: selectedAssignmentID,
        callback: callback
    )

    func testLayout() {
        selectedAssignmentID = "1"
        var selectedAssignment: Assignment?
        callback = { selectedAssignment = $0 }
        api.mock(
            GetSubmittableAssignments(courseID: courseID).request,
            value: [
                .make(
                    id: "1",
                    course_id: ID(courseID),
                    name: "Assignment 1",
                    submission_types: [.online_upload]
                ),
                .make(
                    id: "2",
                    course_id: ID(courseID),
                    name: "Assignment 2",
                    submission_types: [.online_upload]
                ),
            ]
        )
        controller.loadViewIfNeeded()
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
