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
        environment.app = .teacher
        api.mock(controller.colors, value: APICustomColors(custom_colors: [
            "course_1": "#f00",
            "group_1": "#0f0",
        ]))
        api.mock(controller.courses, value: [.make()])
        api.mock(controller.groups, value: [.make()])
        api.mock(controller.todos, value: [
            .make(assignment: .make(due_at: Date(), id: "1"), course_id: "1", group_id: nil),
            .make(assignment: .make(due_at: Date().add(.day, number: 1), id: "2"), course_id: nil, group_id: "1"),
            .make(assignment: .make(due_at: Date().add(.day, number: 2), id: "3")),
            .make(assignment: .make(due_at: nil, id: "4"), needs_grading_count: 2, type: .grading),
        ])
    }

    func testLayout() {
        let navigation = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(navigation.navigationBar.barTintColor!.hexString, Brand.shared.navBackground.hexString)
        XCTAssertEqual(controller.view.backgroundColor, .backgroundLightest)
        XCTAssertEqual(controller.tableView.backgroundColor, .backgroundLightest)
        XCTAssertNoThrow(controller.viewWillDisappear(false))

        var cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TodoListCell
        XCTAssertEqual(cell?.contextLabel.textColor.hexString, UIColor(hexString: "#f00")!.ensureContrast(against: .backgroundLightest).hexString)
        XCTAssertEqual(cell?.contextLabel.text, "Course One")
        cell = controller.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TodoListCell
        XCTAssertEqual(cell?.contextLabel.textColor, UIColor(hexString: "#0f0"))
        XCTAssertEqual(cell?.contextLabel.text, "Group One")
    }

    func testSelect() {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(router.lastRoutedTo("/courses/1/assignments/1"))

        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: IndexPath(row: 3, section: 0))
        XCTAssert(router.lastRoutedTo("/courses/1/assignments/4/submissions/speedgrader"))

        _ = controller.profileButton.target?.perform(controller.profileButton.action)
        XCTAssert(router.lastRoutedTo("/profile"))
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
        XCTAssertEqual(controller.errorView.isHidden, false)
    }

    func testBadgeCount() {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(TabBarBadgeCounts.todoListCount, 5)
    }
}
