//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
@testable import Student
import TestsFoundation

class GroupNavigationViewControllerTests: StudentTestCase {
    let context = Context(.group, id: "1")
    lazy var controller = GroupNavigationViewController.create(context: context)

    override func setUp() {
        super.setUp()
        api.mock(controller.colors, value: APICustomColors(custom_colors: [ context.canvasContextID: "#f00" ]))
        api.mock(controller.groups, value: .make(name: "Tests"))
        api.mock(controller.tabs, value: [
            .make(id: "home", html_url: URL(string: "/home")!, position: 1),
            .make(id: "pages", html_url: URL(string: "/wiki")!, position: 2),
            .make(id: "3", html_url: URL(string: "/tab")!, position: 3),
        ])
    }

    func testLayout() {
        let navigation = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(navigation.navigationBar.barTintColor?.hexString, UIColor(hexString: "#f00")?.darkenToEnsureContrast(against: .white).hexString)
        XCTAssertEqual(controller.tableView.backgroundColor, .backgroundLightest)
        XCTAssertEqual(controller.titleSubtitleView.title, "Tests")
    }

    func testSelect() {
        controller.view.layoutIfNeeded()
        print(controller.tabs.map { $0.position })
        var index = IndexPath(row: 0, section: 0)
        controller.tableView.selectRow(at: index, animated: false, scrollPosition: .top)
        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: index)
        XCTAssertEqual(controller.tableView.indexPathForSelectedRow, index)
        XCTAssert(router.lastRoutedTo(.parse("\(context.pathComponent)/activity_stream")))

        controller.viewWillAppear(false) // coming back to screen
        XCTAssertNil(controller.tableView.indexPathForSelectedRow)

        index = IndexPath(row: 1, section: 0)
        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: index)
        XCTAssert(router.lastRoutedTo(.parse("\(context.pathComponent)/pages")))

        index = IndexPath(row: 2, section: 0)
        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: index)
        XCTAssert(router.lastRoutedTo(.parse("/tab")))
    }

    func testError() {
        api.mock(controller.tabs, error: NSError.instructureError("Oops"))
        controller.view.layoutIfNeeded()
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Oops")
    }
}
