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

class StudentListViewControllerTests: ParentTestCase {
    lazy var controller = StudentListViewController.create()

    override func setUp() {
        super.setUp()
        api.mock(controller.students, value: [
            .make(observed_user: .make(id: "2", short_name: "Bob", pronouns: "He/Him")),
            .make(observed_user: .make(id: "3", short_name: "Ruth")),
        ])
    }

    func testLayout() {
        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        XCTAssertEqual(nav.navigationBar.barTintColor?.hexString, ColorScheme.observeeBlue.color.darkenToEnsureContrast(against: .white).hexString)
        XCTAssertEqual(controller.navigationItem.rightBarButtonItem?.action, #selector(controller.addStudentController.addStudent))

        let index0 = IndexPath(row: 0, section: 0)
        let cell0 = controller.tableView.cellForRow(at: index0) as? StudentListCell
        XCTAssertEqual(cell0?.nameLabel.text, "Bob (He/Him)")
        let cell1 = controller.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? StudentListCell
        XCTAssertEqual(cell1?.nameLabel.text, "Ruth")

        controller.tableView.selectRow(at: index0, animated: false, scrollPosition: .none)
        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: index0)
        XCTAssert(router.lastRoutedTo("/profile/observees/2/thresholds", withOptions: .detail))
        controller.viewWillAppear(false)
        XCTAssertNil(controller.tableView.indexPathForSelectedRow)

        api.mock(controller.students, error: NSError.internalError())
        controller.tableView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.errorView.isHidden, false)

        api.mock(controller.students, value: [])
        controller.errorView.retryButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.errorView.isHidden, true)
        XCTAssertEqual(controller.emptyView.isHidden, false)

        XCTAssertNoThrow(controller.viewWillDisappear(false))
    }
}
