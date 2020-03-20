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
    var hasOpenedSupportTicket = false
    var supportsCanvasNetwork = true
    var supportsQRCodeLogin: Bool = true

    var helpURL: URL?
    var whatsNewURL = URL(string: "whats-new")

    lazy var controller = LoginStartViewController.create(loginDelegate: self, fromLaunch: false)

    override func setUp() {
        super.setUp()
        MDMManager.mockDefaults()
        api.mock(GetUserRequest(userID: "1"), value: .make())
    }

    func testAnimateIn() {
        controller = LoginStartViewController.create(loginDelegate: self, fromLaunch: true)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.findSchoolButton.alpha, 0)
        controller.viewDidAppear(false)
        drainMainQueue()
        XCTAssertEqual(controller.findSchoolButton.alpha, 1)
    }

    func testLayout() {
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.view.backgroundColor, .named(.backgroundLightest))
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
        controller.findSchoolButton.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.viewControllerCalls.last?.0 is LoginWebViewController)
        XCTAssertTrue(controller.authenticationMethodLabel.isHidden)

        // FIXME: trigger the 2 finger double tap recognizer
        controller.authMethodTapped(controller.view)
        XCTAssertEqual(controller.authenticationMethodLabel.text, "Canvas Login")
        controller.authMethodTapped(controller.view)
        XCTAssertEqual(controller.authenticationMethodLabel.text, "Site Admin Login")
        controller.authMethodTapped(controller.view)
        XCTAssertEqual(controller.authenticationMethodLabel.text, "Manual OAuth Login")
        controller.findSchoolButton.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.viewControllerCalls.last?.0 is LoginManualOAuthViewController)

        controller.authMethodTapped(controller.view)
        XCTAssertTrue(controller.authenticationMethodLabel.isHidden)
    }

    func testLinks() {
        MDMManager.mockHost()
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.findSchoolButton.title(for: .normal), "Log In")

        controller.canvasNetworkButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual((router.viewControllerCalls.last?.0 as? LoginWebViewController)?.host, "learn.canvas.net")

        controller.helpButton.sendActions(for: .primaryActionTriggered)
        XCTAssertTrue(hasOpenedSupportTicket)

        controller.whatsNewLink.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(opened, whatsNewURL)
    }

    func testQRCode() throws {
        controller.view.layoutIfNeeded()
        XCTAssertFalse(controller.useQRCodeButton.isHidden)
        XCTAssertFalse(controller.useQRCodeDivider.isHidden)
        controller.useQRCodeButton.sendActions(for: .primaryActionTriggered)
    }
}

extension LoginStartViewControllerTests: LoginDelegate {
    func openExternalURL(_ url: URL) {
        opened = url
    }

    func openSupportTicket() {
        hasOpenedSupportTicket = true
    }

    func userDidLogin(session: LoginSession) {
        loggedIn = session
    }

    func userDidLogout(session: LoginSession) {
        loggedOut = session
    }
}
