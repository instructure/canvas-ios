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

class AccountNotificationDetailsViewControllerTests: ParentTestCase {
    lazy var controller = AccountNotificationDetailsViewController.create(studentID: "1", notificationID: "1")

    override func setUp() {
        super.setUp()
        api.mock(controller.notifications, value: .make(
            message: "School is cancelled until further notice.",
            subject: "Pandemic"
        ))
    }

    func testLayout() {
        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(nav.navigationBar.barTintColor?.hexString, ColorScheme.observee("1").color.darkenToEnsureContrast(against: .white).hexString)
        XCTAssertEqual(controller.title, "Announcement")
        XCTAssertEqual(controller.titleLabel.text, "Pandemic")

        api.mock(controller.notifications, value: .make(
            subject: "changed"
        ))
        controller.scrollView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.titleLabel.text, "changed")
    }
}
