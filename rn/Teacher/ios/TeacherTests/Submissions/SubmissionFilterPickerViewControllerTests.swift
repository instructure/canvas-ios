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
@testable import Teacher

class SubmissionFilterPickerViewControllerTests: TeacherTestCase {
    lazy var controller = SubmissionFilterPickerViewController.create(context: .course("1"), outOfText: "Out of 10", filter: [
        .section([ "1" ]),
        .late
    ]) { [weak self] value in
        self?.filter = value
    }

    var filter: [GetSubmissions.Filter] = []

    override func setUp() {
        super.setUp()
        api.mock(controller.sections, value: [
            .make(id: "1", name: "One"),
            .make(id: "2", name: "Two")
        ])
    }

    struct Cell: Equatable {
        let text: String?
        let isSelected: Bool?
    }
    func cell(_ row: Int, _ section: Int) -> Cell {
        let cell = controller.tableView.cellForRow(at: IndexPath(row: row, section: section))
        return Cell(text: cell?.textLabel?.text, isSelected: cell?.accessibilityTraits.contains(.selected))
    }

    func testLayout() {
        window.rootViewController = controller
        window.makeKeyAndVisible()
        XCTAssertEqual(controller.title, "Filter by")

        XCTAssertEqual(cell(0, 0), Cell(text: "All submissions", isSelected: false))
        XCTAssertEqual(cell(1, 0), Cell(text: "Late", isSelected: true))
        XCTAssertEqual(cell(2, 0), Cell(text: "Not Submitted", isSelected: false))
        XCTAssertEqual(cell(3, 0), Cell(text: "Needs Grading", isSelected: false))
        XCTAssertEqual(cell(4, 0), Cell(text: "Graded", isSelected: false))
        XCTAssertEqual(cell(0, 1), Cell(text: "Scored below...", isSelected: false))
        XCTAssertEqual(cell(1, 1), Cell(text: "Scored above...", isSelected: false))
        XCTAssertEqual(cell(0, 2), Cell(text: "One", isSelected: true))
        XCTAssertEqual(cell(1, 2), Cell(text: "Two", isSelected: false))

        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(cell(0, 0).isSelected, true)
        XCTAssertEqual(cell(1, 0).isSelected, false)
        XCTAssertEqual(cell(0, 2).isSelected, true)

        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: IndexPath(row: 1, section: 2))
        XCTAssertEqual(cell(0, 0).isSelected, true)
        XCTAssertEqual(cell(0, 2).isSelected, true)
        XCTAssertEqual(cell(1, 2).isSelected, true)

        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 2))
        XCTAssertEqual(cell(0, 0).isSelected, true)
        XCTAssertEqual(cell(0, 2).isSelected, false)
        XCTAssertEqual(cell(1, 2).isSelected, true)

        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 1))
        var prompt = router.presented as? UIAlertController
        XCTAssertEqual(prompt?.title, "Scored below...")
        XCTAssertEqual(prompt?.message, "Out of 10")
        prompt?.textFields?[0].text = " 8\n"
        (prompt?.actions.last as? AlertAction)?.handler?(UIAlertAction())
        XCTAssertEqual(cell(0, 0).isSelected, false)
        XCTAssertEqual(cell(0, 1), Cell(text: "Scored below 8", isSelected: true))

        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: IndexPath(row: 1, section: 1))
        prompt = router.presented as? UIAlertController
        XCTAssertEqual(prompt?.title, "Scored above...")
        XCTAssertEqual(prompt?.message, "Out of 10")
        prompt?.textFields?[0].text = " 2\n"
        (prompt?.actions.last as? AlertAction)?.handler?(UIAlertAction())
        XCTAssertEqual(cell(0, 1), Cell(text: "Scored below...", isSelected: false))
        XCTAssertEqual(cell(1, 1), Cell(text: "Scored above 2", isSelected: true))

        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: IndexPath(row: 1, section: 1))
        prompt = router.presented as? UIAlertController
        prompt?.textFields?[0].text = ""
        (prompt?.actions.last as? AlertAction)?.handler?(UIAlertAction())
        XCTAssertEqual(cell(1, 1), Cell(text: "Scored above 2", isSelected: true))

        _ = controller.doneButton.target?.perform(controller.doneButton.action)
        XCTAssertEqual(filter, [ .scoreAbove(2), .section([ "2" ]) ])

        _ = controller.resetButton.target?.perform(controller.resetButton.action)
        XCTAssertEqual(cell(0, 0).isSelected, true)
        XCTAssertEqual(cell(1, 2).isSelected, false)
    }
}
