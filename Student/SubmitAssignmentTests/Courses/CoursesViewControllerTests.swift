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

import Core
import TestsFoundation
import XCTest

class CoursesViewControllerTests: SubmitAssignmentTestCase {
    var courseID = "1"
    var selectedCourseID: String?
    var selectedCourse: Course?

    lazy var controller = CoursesViewController.create(
        selectedCourseID: selectedCourseID,
        callback: { [weak self] in self?.selectedCourse = $0 }
    )

    func testLayout() {
        selectedCourseID = "1"
        api.mock(
            controller.courses,
            value: [
                .make(
                    id: "1",
                    name: "Course 1"
                ),
                .make(
                    id: "2",
                    name: "Course 2"
                ),
            ]
        )
        controller.view.layoutIfNeeded()
        let tableView = controller.tableView
        XCTAssertEqual(controller.tableView.dataSource?.tableView(tableView!, numberOfRowsInSection: 0), 2)
        let firstCell = controller.tableView.dataSource?.tableView(tableView!, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(firstCell?.textLabel?.text, "Course 1")
        XCTAssertEqual(firstCell?.accessoryType, .checkmark)

        let secondCell = controller.tableView.dataSource?.tableView(tableView!, cellForRowAt: IndexPath(row: 1, section: 0))
        XCTAssertEqual(secondCell?.textLabel?.text, "Course 2")
        XCTAssertEqual(secondCell?.accessoryType, UITableViewCell.AccessoryType.none)

        controller.tableView.delegate?.tableView?(tableView!, didSelectRowAt: IndexPath(row: 1, section: 0))
        XCTAssertEqual(selectedCourse?.name, "Course 2")
    }
}
