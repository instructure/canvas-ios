//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import XCTest

class NotSupportedInOfflineAlertTests: CoreTestCase {

    func testAlert() {
        let topViewController = UIViewController()
        AppEnvironment.shared.window?.rootViewController = topViewController

        UIAlertController.showItemNotAvailableInOfflineAlert()

        guard let alert = router.lastViewController as? UIAlertController else {
            return XCTFail("Alert not found")
        }

        XCTAssertEqual(router.viewControllerCalls.last?.1, topViewController)
        XCTAssertEqual(router.viewControllerCalls.last?.2, .modal())

        XCTAssertEqual(alert.title, "Offline mode")
        XCTAssertEqual(alert.message, "This item is not available offline.")
        XCTAssertEqual(alert.actions.count, 1)
        XCTAssertEqual(alert.actions.first?.title, "OK")
    }
}
