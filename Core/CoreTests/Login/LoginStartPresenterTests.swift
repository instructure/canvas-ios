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

class LoginStartPresenterTests: XCTestCase {
    var logins: [Login]?
    var loggedIn: LoginSession?
    var loggedOut: LoginSession?
    var method: String?
    var opened: URL?
    var hasOpenedSupportTicket = false
    var shown: UIViewController?

    var helpURL: URL?
    var whatsNewURL: URL?

    override func setUp() {
        super.setUp()
        LoginSession.clearAll()
        MDMManager.reset()
        AppEnvironment.shared.currentSession = nil
    }

    override func tearDown() {
        MDMManager.reset()
    }

    func testViewIsReady() {
        let mockSession = URLSession.mockSession()
        let responseData = try? JSONEncoder().encode(APIUser.make(avatar_url: URL(string: "avatar")))
        MockURLProtocolSupport.responses.append(MockURLProtocolSupport.responseWithStatusCode(200, responseData: responseData))
        MockURLProtocolSupport.responses.append(MockURLProtocolSupport.responseWithStatusCode(200, responseData: responseData))
        MockURLProtocolSupport.responses.append(MockURLProtocolSupport.responseWithStatusCode(200, responseData: responseData))
        MDMManager.mockDefaults()
        let bill = LoginSession.make(lastUsedAt: Date().addingTimeInterval(100), userID: "1", userName: "Bill")
        let bob = LoginSession.make(lastUsedAt: Date(), userID: "3", userName: "Bob")
        let apple = MDMManager.shared.logins[0]
        LoginSession.add(bill)
        LoginSession.add(bob)
        AppEnvironment.shared.currentSession = bill
        let presenter = LoginStartPresenter(loginDelegate: self, view: self)
        presenter.urlSession = mockSession
        presenter.viewIsReady()
        XCTAssertEqual(logins, [ Login.session(bill), Login.session(bob), Login.mdm(apple) ])
        let poll = expectation(for: NSPredicate(value: true), evaluatedWith: presenter) {
            if case .session(let entry)? = self.logins?[0], entry.userAvatarURL != nil {
                return true
            }
            return false
        }
        wait(for: [poll], timeout: 5)
        XCTAssertEqual(AppEnvironment.shared.currentSession?.userAvatarURL, URL(string: "avatar"))
    }

    func testCycleAuthMethod() {
        let presenter = LoginStartPresenter(loginDelegate: self, view: self)
        presenter.cycleAuthMethod()
        XCTAssertEqual(method, "Canvas Login")
        presenter.cycleAuthMethod()
        XCTAssertEqual(method, "Site Admin Login")
        presenter.cycleAuthMethod()
        XCTAssertEqual(method, "Manual OAuth Login")
        presenter.cycleAuthMethod()
        XCTAssertNil(method)
    }

    func testOpenCanvasNetwork() {
        let presenter = LoginStartPresenter(loginDelegate: self, view: self)
        presenter.openCanvasNetwork()
        XCTAssertEqual((shown as? LoginWebViewController)?.presenter?.host, "learn.canvas.net")
    }

    func testOpenFindSchool() {
        let presenter = LoginStartPresenter(loginDelegate: self, view: self)
        presenter.openFindSchool()
        XCTAssert(shown is LoginFindSchoolViewController)
    }

    func testOpenFindSchoolMDMHost() {
        MDMManager.mockHost()
        let presenter = LoginStartPresenter(loginDelegate: self, view: self)
        presenter.openFindSchool()
        XCTAssertEqual((shown as? LoginWebViewController)?.presenter?.authenticationProvider, MDMManager.shared.authenticationProvider)
        XCTAssertEqual((shown as? LoginWebViewController)?.presenter?.host, MDMManager.shared.host)

        presenter.method = .manualOAuthLogin
        presenter.openFindSchool()
        XCTAssert(shown is LoginManualOAuthViewController)
    }

    func testOpenHelp() {
        let presenter = LoginStartPresenter(loginDelegate: self, view: self)
        presenter.openHelp()
        XCTAssertTrue(hasOpenedSupportTicket)
    }

    func testOpenWhatsNew() {
        let presenter = LoginStartPresenter(loginDelegate: self, view: self)
        presenter.openWhatsNew()
        XCTAssertNil(opened)
        whatsNewURL = URL(string: "/")!
        presenter.openWhatsNew()
        XCTAssertEqual(opened, whatsNewURL)
    }

    func testSelectKeychainEntry() {
        let presenter = LoginStartPresenter(loginDelegate: self, view: self)
        let session = LoginSession.make()
        presenter.selectSession(session)
        XCTAssertEqual(loggedIn, session)
        XCTAssert(shown is LoadingViewController)
    }

    func testRemoveKeychainEntry() {
        let presenter = LoginStartPresenter(loginDelegate: self, view: self)
        let session = LoginSession.make()
        presenter.removeSession(session)
        XCTAssertEqual(loggedOut, session)
    }

    func testSelectMDMLogin() {
        let presenter = LoginStartPresenter(loginDelegate: self, view: self)
        presenter.viewIsReady()
        MDMManager.mockDefaults()
        presenter.selectMDMLogin(MDMManager.shared.logins[0])
        let shownPresenter = (shown as? LoginWebViewController)?.presenter
        XCTAssertEqual(shownPresenter?.host, MDMManager.shared.logins[0].host)
        XCTAssertEqual(shownPresenter?.mdmLogin, MDMManager.shared.logins[0])
        XCTAssertEqual(shownPresenter?.method, .canvasLogin)
    }
}

extension LoginStartPresenterTests: LoginStartViewProtocol {
    func show(_ vc: UIViewController, sender: Any?) {
        shown = vc
    }

    func update(logins: [Login]) {
        self.logins = logins
    }

    func update(method: String?) {
        self.method = method
    }
}

extension LoginStartPresenterTests: LoginDelegate {
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
