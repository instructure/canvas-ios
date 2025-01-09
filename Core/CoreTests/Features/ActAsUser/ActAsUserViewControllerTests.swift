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

class ActAsUserViewControllerTests: CoreTestCase, LoginDelegate {
    lazy var controller = ActAsUserViewController.create(loginDelegate: self)

    var session: LoginSession?
    func userDidLogin(session: LoginSession) {
        self.session = session
    }
    func userDidLogout(session: LoginSession) {}
    func openExternalURL(_ url: URL) {}

    func testLayout() {
        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        router.show(controller, from: nav, options: .modal())

        XCTAssertEqual(nav.navigationBar.barStyle, .default)
        XCTAssertEqual(controller.title, "Act as User")

        XCTAssertEqual(controller.actAsUserButton.isEnabled, false)
        controller.userIDTextField.text = "1"
        controller.userIDTextField.sendActions(for: .editingChanged)
        XCTAssertEqual(controller.actAsUserButton.isEnabled, true)

        controller.actAsUserButton.sendActions(for: .primaryActionTriggered)
        XCTAssertNil(session)

        NotificationCenter.default.post(name: UIResponder.keyboardWillChangeFrameNotification, object: nil, userInfo: [:])
        XCTAssertEqual(controller.scrollView.contentOffset.y, 0)

        NotificationCenter.default.post(name: UIResponder.keyboardWillChangeFrameNotification, object: nil, userInfo: [
            UIResponder.keyboardFrameEndUserInfoKey: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 100),
            UIResponder.keyboardAnimationCurveUserInfoKey: UIView.AnimationOptions.curveEaseOut.rawValue,
            UIResponder.keyboardAnimationDurationUserInfoKey: TimeInterval(2)
        ])
        XCTAssertGreaterThan(controller.scrollView.contentOffset.y, 0)

        API(baseURL: URL(string: "https://cgnu.online")).mock(GetUserRequest(userID: "1"), value: .make())
        controller.domainTextField.text = "cgnu.online/extra"
        controller.actAsUserButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(session?.userID, "1")
        XCTAssertEqual(session?.baseURL, URL(string: "https://cgnu.online"))
        XCTAssertEqual(session?.masquerader, URL(string: "https://canvas.instructure.com/users/1"))
        session = nil

        API(baseURL: URL(string: "https://cgnu.instructure.com")).mock(GetUserRequest(userID: "1"), value: .make())
        controller.domainTextField.text = "cgnu"
        controller.actAsUserButton.sendActions(for: .primaryActionTriggered)
        XCTAssertNotNil(session)
        session = nil

        environment.currentSession = nil
        controller.actAsUserButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual((router.presented as? UIAlertController)?.title, "Error")
        router.viewControllerCalls.removeAll()

        API(baseURL: URL(string: "https://cgnu.instructure.com")).mock(GetUserRequest(userID: "1"), error: NSError.internalError())
        controller.actAsUserButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual((router.presented as? UIAlertController)?.title, "Error")
    }
}
