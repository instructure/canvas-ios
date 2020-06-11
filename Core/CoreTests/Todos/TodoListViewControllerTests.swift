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
@testable import Core
import TestsFoundation

class TodoListViewControllerTests: CoreTestCase {
    lazy var controller = TodoListViewController.create()

    override func setUp() {
        super.setUp()
        api.mock(controller.colors, value: APICustomColors(custom_colors: [
            "course_1": "#f00",
            "group_1": "#0f0",
        ]))
        api.mock(controller.courses, value: [.make(course_code: "Code")])
        api.mock(controller.groups, value: [.make(name: "Group")])
        api.mock(controller.todos, value: [
            .make(assignment: .make(id: "1", due_at: Date()), course_id: "1", group_id: nil),
            .make(assignment: .make(id: "2", due_at: Date().add(.day, number: 1)), course_id: nil, group_id: "1"),
            .make(assignment: .make(id: "3", due_at: nil)),
        ])
    }

    func testLayout() {
        let navigation = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(navigation.navigationBar.barTintColor, Brand.shared.navBackground)
        XCTAssertEqual(controller.view.backgroundColor, .named(.backgroundLightest))
        XCTAssertEqual(controller.tableView.backgroundColor, .named(.backgroundLightest))
        XCTAssertNoThrow(controller.viewWillDisappear(false))

        var cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TodoListCell
        XCTAssertEqual(cell?.contextLabel.textColor, UIColor(hexString: "#f00"))
        XCTAssertEqual(cell?.contextLabel.text, "Code")
        cell = controller.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TodoListCell
        XCTAssertEqual(cell?.contextLabel.textColor, UIColor(hexString: "#0f0"))
        XCTAssertEqual(cell?.contextLabel.text, "Group")
    }

    func testSelect() {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(router.lastRoutedTo(.parse("https://canvas.instructure.com/courses/1/assignments/1")))
    }

    func testIgnore() {
        api.mock(DeleteTodoRequest(ignoreURL: APITodo.make().ignore))
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        var actions = controller.tableView.delegate?.tableView?(
            controller.tableView,
            trailingSwipeActionsConfigurationForRowAt: IndexPath(row: 0, section: 0)
        )?.actions
        actions?[0].handler(actions![0], UIView()) { complete in
            XCTAssertTrue(complete)
        }

        api.mock(DeleteTodoRequest(ignoreURL: APITodo.make().ignore), error: NSError.instructureError("Doh!"))
        actions = controller.tableView.delegate?.tableView?(
            controller.tableView,
            trailingSwipeActionsConfigurationForRowAt: IndexPath(row: 0, section: 0)
        )?.actions
        actions?[0].handler(actions![0], UIView()) { complete in
            XCTAssertTrue(complete)
        }
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Doh!")
    }

    func testTodoLoadError() {
        api.mock(controller.todos, error: NSError.instructureError("Break it"))
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Break it")
    }
}
