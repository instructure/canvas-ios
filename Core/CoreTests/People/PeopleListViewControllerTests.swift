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
@testable import TestsFoundation

class PeopleListViewControllerTests: CoreTestCase {
    lazy var controller = PeopleListViewController.create(context: ContextModel(.course, id: "1"))

    override func setUp() {
        super.setUp()
        environment.mockStore = false
        api.mock(controller.colors, value: APICustomColors(custom_colors: [ "course_1": "#f00" ]))
        api.mock(controller.course, value: .make())
        api.mock(controller.users, value: [
            .make(),
            .make(
                id: "2",
                name: "Jane",
                sortable_name: "jane doe",
                short_name: "jane",
                enrollments: [ .make(id: "2", role: "StudentEnrollment"), .make(id: "3", role: "Custom") ]
            ),
        ])
    }

    func testLayout() {
        let navigation = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        navigation.navigationBar.barStyle = .default
        XCTAssertEqual(controller.preferredStatusBarStyle, .default)
        navigation.navigationBar.barStyle = .black
        XCTAssertEqual(controller.preferredStatusBarStyle, .lightContent)

        XCTAssertEqual(controller.titleSubtitleView.title, "People")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Course One")

        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 2)

        var cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PeopleListCell
        XCTAssertEqual(cell?.nameLabel.text, "Bob")
        XCTAssertEqual(cell?.rolesLabel.text, "")

        cell = controller.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? PeopleListCell
        XCTAssertEqual(cell?.nameLabel.text, "Jane")
        XCTAssertEqual(cell?.rolesLabel.text, "Custom and Student")

        api.mock(controller.users, value: [ .make(name: "George") ])
        controller.tableView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.tableView.refreshControl?.isRefreshing, false) // stops refreshing
        controller.tableView.delegate?.scrollViewDidScroll?(controller.tableView)

        cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PeopleListCell
        XCTAssertEqual(cell?.nameLabel.text, "George")

        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(router.lastRoutedTo(.parse("/courses/1/users/1")))
    }
}
