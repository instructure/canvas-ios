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

import XCTest
@testable import Student
@testable import Core
@testable import TestsFoundation

class ActivityStreamViewControllerTests: StudentTestCase {
    lazy var controller = ActivityStreamViewController.create()
    let mockNow = Date(fromISOString: "2019-11-20T06:00:00Z")!

    override func setUp() {
        super.setUp()
        api.mock(controller.colors, value: APICustomColors(custom_colors: [
            "course_1": "#f00",
            "course_2": "#0f0",
        ]))
        api.mock(controller.courses, value: [.make(course_code: "Code"), .make(id: "2", course_code: "Code2")])

        api.mock(controller.activities, value: [
            APIActivity.make(id: "1", updated_at: mockNow.addDays(-2)),
            APIActivity.make(id: "2", title: "grouptitle", message: "groupMessage", updated_at: mockNow.addDays(-3), context_type: ContextType.group.rawValue, course_id: nil, group_id: "2"),
            APIActivity.make(id: "3", title: "title2", updated_at: mockNow.addDays(-4), course_id: "2"),
        ])
        Clock.mockNow( mockNow )
    }

    override func tearDown() {
        Clock.reset()
        super.tearDown()
    }

    func testLayout() {
        _ = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewDidLoad()
        XCTAssertEqual(controller.view.backgroundColor, .backgroundLightest)
        XCTAssertEqual(controller.tableView.backgroundColor, .backgroundLightest)
        XCTAssertNoThrow(controller.viewWillDisappear(false))

        let expectedDateCell0 = ActivityStreamViewController.dateFormatter.string(from: mockNow.addDays(-2))
        let expectedDateCell1 = ActivityStreamViewController.dateFormatter.string(from: mockNow.addDays(-3))
        let expectedDateCell2 = ActivityStreamViewController.dateFormatter.string(from: mockNow.addDays(-4))

        var cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ActivityCell
        XCTAssertEqual(cell?.courseCode.textColor.hexString, UIColor(hexString: "#f00")!.ensureContrast(against: .backgroundLightest).hexString)
        XCTAssertEqual(cell?.courseCode.text, "Code")
        XCTAssertEqual(cell?.titleLabel.text, "title")
        XCTAssertEqual(cell?.subTitleLabel.text, expectedDateCell0)
        XCTAssertEqual(cell?.icon.image, UIImage.assignmentLine)

        cell = controller.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ActivityCell
        XCTAssertNil(cell?.courseCode.text)
        XCTAssertEqual(cell?.titleLabel.text, "grouptitle")
        XCTAssertEqual(cell?.subTitleLabel.text, expectedDateCell1)

        cell = controller.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? ActivityCell
        XCTAssertEqual(cell?.courseCode.textColor.hexString, UIColor(hexString: "#0f0")!.ensureContrast(against: .backgroundLightest).hexString)
        XCTAssertEqual(cell?.courseCode.text, "Code2")
        XCTAssertEqual(cell?.titleLabel.text, "title2")
        XCTAssertEqual(cell?.subTitleLabel.text, expectedDateCell2)
        XCTAssertEqual(cell?.icon.image, UIImage.assignmentLine)
    }

    func testEmptyState() {
        api.mock(controller.activities, value: [])
        controller.view.layoutIfNeeded()
        controller.viewDidLoad()
        XCTAssertFalse(controller.emptyStateContainer.isHidden)
    }

    func testSelect() {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(router.lastRoutedTo(.parse("/courses/1/assignments/1")))
    }
}
