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

class LoginManualOAuthViewControllerTests: CoreTestCase {
    lazy var controller = LoginManualOAuthViewController.create(authenticationProvider: "provider", host: "canvas.local", loginDelegate: self)

    func testSubmit() {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.view.backgroundColor, .backgroundLightest)

        controller.continueButton.sendActions(for: .primaryActionTriggered)
        XCTAssertTrue(router.viewControllerCalls.isEmpty)

        controller.clientIDField.text = " 13\n"
        controller.clientSecretField.text = "   secret\r"
        controller.continueButton.sendActions(for: .primaryActionTriggered)
        let shown = router.viewControllerCalls.first?.0 as? LoginWebViewController
        XCTAssertEqual(shown?.authenticationProvider, "provider")
        XCTAssertEqual(shown?.host, "canvas.local")
        XCTAssertEqual(shown?.method, .manualOAuthLogin)
        XCTAssertEqual(shown?.mobileVerifyModel?.base_url, URL(string: "https://canvas.local"))
        XCTAssertEqual(shown?.mobileVerifyModel?.client_id, "13")
        XCTAssertEqual(shown?.mobileVerifyModel?.client_secret, "secret")

        controller.host = "http://inst.co"
        controller.continueButton.sendActions(for: .primaryActionTriggered)
        let shown2 = router.viewControllerCalls.last?.0 as? LoginWebViewController
        XCTAssertEqual(shown2?.mobileVerifyModel?.base_url, URL(string: "http://inst.co"))
    }
}

extension LoginManualOAuthViewControllerTests: LoginDelegate {
    var helpURL: URL? { return nil }
    func openExternalURL(_ url: URL) {}
    func userDidLogin(session: LoginSession) {}
    func userDidLogout(session: LoginSession) {}
}
