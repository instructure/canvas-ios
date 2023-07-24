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
import TestsFoundation

class LoginStartViewControllerTests: CoreTestCase {
    var loggedIn: LoginSession?
    var loggedOut: LoginSession?
    var opened: URL?
    var supportsCanvasNetwork = true
    var helpURL: URL?
    var whatsNewURL = URL(string: "whats-new")

    lazy var controller = LoginStartViewController.create(loginDelegate: self, fromLaunch: false, app: .student)

    override func setUp() {
        super.setUp()
        supportsCanvasNetwork = true
        MDMManager.mockDefaults()
        api.mock(GetUserRequest(userID: "1"), value: .make())
    }

    func testAnimateIn() {
        let isUIHiddenButAnimatedLogo = { [self] in
            controller.view.subviews.allSatisfy { view in
                if view == controller.animatableLogo {
                    return true
                }
                return view.alpha == 0
            }
        }

        controller = LoginStartViewController.create(loginDelegate: self, fromLaunch: true, app: .student)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.animatableLogo.alpha, 1)
        XCTAssertTrue(isUIHiddenButAnimatedLogo())
        controller.viewDidAppear(false)
        drainMainQueue()
        XCTAssertEqual(controller.animatableLogo.alpha, 0)
        XCTAssertFalse(isUIHiddenButAnimatedLogo())
    }

    func testLayout() {
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.view.backgroundColor, .backgroundLightest)
        XCTAssertEqual(environment.currentSession?.userName, "Bob") // set from refresh

        let first = controller.previousLoginsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? LoginStartSessionCell
        XCTAssertEqual(first?.nameLabel?.text, "Bob")
        XCTAssertEqual(first?.domainLabel?.text, "canvas.instructure.com")

        let second = controller.previousLoginsTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? LoginStartMDMLoginCell
        XCTAssertEqual(second?.nameLabel?.text, "apple")
        XCTAssertEqual(second?.domainLabel?.text, "canvas.instructure.com")

        controller.previousLoginsTableView.delegate?.tableView?(
            controller.previousLoginsTableView,
            didSelectRowAt: IndexPath(row: 1, section: 0)
        )
        XCTAssert(router.viewControllerCalls.last?.0 is LoginWebViewController)
        XCTAssertNil(loggedIn)

        controller.previousLoginsTableView.delegate?.tableView?(
            controller.previousLoginsTableView,
            didSelectRowAt: IndexPath(row: 0, section: 0)
        )
        XCTAssert(router.viewControllerCalls.last?.0 is LoadingViewController)
        XCTAssertEqual(loggedIn, first?.entry)
    }

    func testRemove() {
        MDMManager.reset()
        controller.view.layoutIfNeeded()
        let first = controller.previousLoginsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? LoginStartSessionCell

        let entry = first!.entry!
        first?.forgetButton?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(loggedOut, entry)
        XCTAssertEqual(controller.previousLoginsTableView.numberOfRows(inSection: 0), 0)
    }

    func testEmpty() {
        MDMManager.reset()
        LoginSession.clearAll()
        controller.view.layoutIfNeeded()
        XCTAssertTrue(controller.previousLoginsView.isHidden)
    }

    func testFindSchool() {
        controller.view.layoutIfNeeded()
        controller.findSchoolButton.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.viewControllerCalls.last?.0 is LoginFindSchoolViewController)

        MDMManager.mockHost()
        controller.lastLoginButton.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.viewControllerCalls.last?.0 is LoginWebViewController)
        XCTAssertTrue(controller.authenticationMethodLabel.isHidden)

        // FIXME: trigger the 2 finger double tap recognizer
        controller.authMethodTapped(controller.view)
        XCTAssertEqual(controller.authenticationMethodLabel.text, "Canvas Login")
        controller.authMethodTapped(controller.view)
        XCTAssertEqual(controller.authenticationMethodLabel.text, "Site Admin Login")
        controller.authMethodTapped(controller.view)
        XCTAssertEqual(controller.authenticationMethodLabel.text, "Manual OAuth Login")
        controller.lastLoginButton.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.viewControllerCalls.last?.0 is LoginManualOAuthViewController)

        controller.authMethodTapped(controller.view)
        XCTAssertTrue(controller.authenticationMethodLabel.isHidden)
    }

    func testLinks() {
        MDMManager.mockHost()
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.lastLoginButton.title(for: .normal), "Log In")

        controller.canvasNetworkButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual((router.viewControllerCalls.last?.0 as? LoginWebViewController)?.host, "learn.canvas.net")

        controller.whatsNewLink.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(opened, whatsNewURL)
    }

    func testQRCode() throws {
        let domain = "mobiledev"
        let code = "abc123"
        let qrCode = "https://sso.canvaslms.com/canvas/login?domain=\(domain)&code=\(code)"
        let client = APIVerifyClient.make()
        api.mock(GetMobileVerifyRequest(domain: domain), value: client)
        let task = api.mock(PostLoginOAuthRequest(client: client, code: code), value: .make())
        task.suspend()
        controller.view.layoutIfNeeded()
        XCTAssertFalse(controller.useQRCodeButton.isHidden)
        XCTAssertFalse(controller.useQRCodeDivider.isHidden)
        controller.useQRCodeButton.sendActions(for: .primaryActionTriggered)
        let tutorial = try XCTUnwrap(router.presented as? LoginQRCodeTutorialViewController)
        tutorial.delegate?.loginQRCodeTutorialDidFinish(tutorial)
        let scanner = router.presented as! ScannerViewController
        controller.scanner(scanner, didScanCode: qrCode)
        let loading = try XCTUnwrap(router.presented as? UIAlertController)
        XCTAssertEqual(loading.title, "Logging you in")
        task.resume()
        XCTAssertNotNil(loggedIn)
    }

    func testQRCodeError() throws {
        let qrCode = "invalid"
        controller.view.layoutIfNeeded()
        controller.useQRCodeButton.sendActions(for: .primaryActionTriggered)
        let tutorial = try XCTUnwrap(router.presented as? LoginQRCodeTutorialViewController)
        tutorial.delegate?.loginQRCodeTutorialDidFinish(tutorial)
        controller.scanner(ScannerViewController(), didScanCode: qrCode)
        let alert = try XCTUnwrap(router.presented as? UIAlertController)
        XCTAssertEqual(alert.title, "Login Error")
        XCTAssertEqual(alert.message, "Please generate another QR Code and try again.")
    }

    func testParentCreateAccountQRCode() throws {
        let code = "parent-app://canvas.instructure.com/pair?code=foo"
        controller.app = .parent
        controller.view.layoutIfNeeded()
        XCTAssertFalse(controller.useQRCodeButton.isHidden)
        controller.useQRCodeButton.sendActions(for: .primaryActionTriggered)
        let picker = try XCTUnwrap(router.presented as? BottomSheetPickerViewController)
        XCTAssertEqual(picker.actions.count, 2)
        XCTAssertEqual(picker.actions[0].title, "I have a Canvas account")
        XCTAssertEqual(picker.actions[1].title, "I don't have a Canvas account")
        picker.actions[1].action()
        let tutorial = try XCTUnwrap(router.presented as? PairWithStudentQRCodeTutorialViewController)
        tutorial.delegate?.pairWithStudentQRCodeTutorialDidFinish(tutorial)
        let scanner = router.presented as! ScannerViewController
        controller.scanner(scanner, didScanCode: code)
        let login = try XCTUnwrap(router.last as? LoginWebViewController)
        XCTAssertEqual(login.host, "canvas.instructure.com")
        XCTAssertEqual(login.pairingCode, "foo")
    }

    func testButtonsBelowLoginButtonWithBothEnabled() {
        controller.viewDidLoad()
        controller.view.layoutIfNeeded()
        XCTAssertFalse(controller.canvasNetworkButton.isHidden)
        XCTAssertFalse(controller.useQRCodeButton.isHidden)
        XCTAssertFalse(controller.useQRCodeDivider.isHidden)
    }

    func testButtonsBelowLoginButtonWithQRCodeButtonEnabledOnly() {
        supportsCanvasNetwork = false
        controller.viewDidLoad()
        controller.view.layoutIfNeeded()
        XCTAssertTrue(controller.canvasNetworkButton.isHidden)
        XCTAssertFalse(controller.useQRCodeButton.isHidden)
        XCTAssertTrue(controller.useQRCodeDivider.isHidden)
    }
}

extension LoginStartViewControllerTests: LoginDelegate {
    func openExternalURL(_ url: URL) {
        opened = url
    }

    func userDidLogin(session: LoginSession) {
        loggedIn = session
    }

    func userDidLogout(session: LoginSession) {
        loggedOut = session
    }
}
