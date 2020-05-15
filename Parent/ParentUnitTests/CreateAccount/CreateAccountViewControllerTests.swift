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
@testable import Parent
@testable import Core

class CreateAccountViewControllerTests: ParentTestCase {

    var vc: CreateAccountViewController!
    let baseURL: URL = URL(string: "https://localhost")!
    let accountID = "1"
    let code = "code"
    var changeUserCalled = false

    override func setUp() {
        super.setUp()
        changeUserCalled = false
        vc = CreateAccountViewController.create(baseURL: baseURL, accountID: accountID, pairingCode: code)
    }

    func loadView() {
        vc.view.layoutIfNeeded()
        vc.viewDidLoad()
        vc.viewWillAppear(false)
    }

    func testLayout() throws {
        loadView()

        XCTAssertEqual(vc.name.labelName.text, "Full name")
        XCTAssertEqual(vc.name.textField.placeholder, "Full name...")
        XCTAssertNil(vc.name.errorLabel.text)

        XCTAssertEqual(vc.email.labelName.text, "Email address")
        XCTAssertEqual(vc.email.textField.placeholder, "Email...")
        XCTAssertNil(vc.email.errorLabel.text)

        XCTAssertEqual(vc.password.labelName.text, "Password")
        XCTAssertEqual(vc.password.textField.placeholder, "Password...")
        XCTAssertNil(vc.password.errorLabel.text)
        XCTAssertTrue(vc.password.textField.isSecureTextEntry)

        XCTAssertEqual(vc.createAccountButton.title(for: .normal), "Create Account")

        vc.createAccountButton.sendActions(for: .primaryActionTriggered)

        XCTAssertEqual(vc.name.errorLabel.text, "Please enter full name")
        vc.name.textField.text = "john doe"

        vc.createAccountButton.sendActions(for: .primaryActionTriggered)
        XCTAssertNil(vc.name.errorLabel.text)
        XCTAssertEqual(vc.email.errorLabel.text, "Please enter an email address")
        vc.email.textField.text = "johndoe@instructure.com"

        vc.createAccountButton.sendActions(for: .primaryActionTriggered)
        XCTAssertNil(vc.name.errorLabel.text)
        XCTAssertNil(vc.email.errorLabel.text)
        XCTAssertEqual(vc.password.errorLabel.text, "Password is required")
        vc.password.textField.text = "password"

        let r = PostAccountUserRequest(
            baseURL: baseURL,
            accountID: accountID,
            pairingCode: code,
            name: vc.name.textField.text!,
            email: vc.email.textField.text!,
            password: vc.password.textField.text!
        )
        let user = APIUser(
            id: "1",
            name: vc.name.textField.text!,
            sortable_name: vc.name.textField.text!,
            short_name: "",
            login_id: nil,
            avatar_url: nil,
            enrollments: nil,
            email: vc.email.textField.text,
            locale: nil,
            effective_locale: nil,
            bio: nil,
            pronouns: nil,
            permissions: nil
        )
        api.mock(r, value: user)

        AppEnvironment.shared.loginDelegate = self
        vc.createAccountButton.sendActions(for: .primaryActionTriggered)
        XCTAssertNil(vc.name.errorLabel.text)
        XCTAssertNil(vc.email.errorLabel.text)
        XCTAssertNil(vc.password.errorLabel.text)
        XCTAssertNil(vc.email.errorLabel.text)

        XCTAssertTrue(changeUserCalled)
    }

    func testSignInNavigatesToLoginForHost() {
        let loginNav = LoginNavigationController.create(loginDelegate: self, app: .parent)
        let nav = UINavigationController(rootViewController: vc)

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 300, height: 600))
        window.rootViewController = loginNav
        window.makeKeyAndVisible()
        loginNav.viewDidAppear(false)
        loginNav.viewControllers.first?.present(nav, animated: false, completion: nil)
        XCTAssertNotNil(loginNav.viewControllers.first?.presentedViewController)

        loadView()
        vc.actionSignIn(UIButton())
        guard let login = loginNav.viewControllers.last as? LoginWebViewController else {
            XCTFail("Expected LoginWebViewController")
            return
        }
        XCTAssertEqual(login.host, baseURL.host)
    }
}

extension CreateAccountViewControllerTests: LoginDelegate {
    func openExternalURL(_ url: URL) {
    }

    func userDidLogin(session: LoginSession) {
    }

    func userDidLogout(session: LoginSession) {
    }

    func changeUser() {
        changeUserCalled = true
    }
}
