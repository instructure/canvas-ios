//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
@testable import Core
import TestsFoundation

class LoginStartPresenterTests: XCTestCase {
    var logins: [Login]?
    var loggedIn: KeychainEntry?
    var loggedOut: KeychainEntry?
    var method: String?
    var opened: URL?
    var hasOpenedSupportTicket = false
    var shown: UIViewController?

    var helpURL: URL?
    var whatsNewURL: URL?

    override func setUp() {
        super.setUp()
        Keychain.config = KeychainConfig(service: "com.instructure.service", accessGroup: nil)
        Keychain.clearEntries()
        AppEnvironment.shared.currentSession = nil
    }

    func testViewIsReady() {
        let mockSession = URLSession.mockSession()
        let responseData = try? JSONEncoder().encode(APIUser.make([ "avatar_url": "avatar" ]))
        MockURLProtocolSupport.responses.append(MockURLProtocolSupport.responseWithStatusCode(200, responseData: responseData))
        MockURLProtocolSupport.responses.append(MockURLProtocolSupport.responseWithStatusCode(200, responseData: responseData))
        MockURLProtocolSupport.responses.append(MockURLProtocolSupport.responseWithStatusCode(200, responseData: responseData))
        MDMManager.mockDefaults()
        let bill = KeychainEntry.make(lastUsedAt: Date().addingTimeInterval(100), userID: "1", userName: "Bill")
        let bob = KeychainEntry.make(lastUsedAt: Date(), userID: "3", userName: "Bob")
        let apple = MDMManager.shared.logins[0]
        Keychain.addEntry(bill)
        Keychain.addEntry(bob)
        AppEnvironment.shared.currentSession = bill
        let presenter = LoginStartPresenter(loginDelegate: self, view: self)
        presenter.session = mockSession
        presenter.viewIsReady()
        XCTAssertEqual(logins, [ Login.keychain(bill), Login.keychain(bob), Login.mdm(apple) ])
        let poll = expectation(for: NSPredicate(value: true), evaluatedWith: presenter) {
            if case .keychain(let entry)? = self.logins?[0], entry.userAvatarURL != nil {
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
        let entry = KeychainEntry.make()
        presenter.selectKeychainEntry(entry)
        XCTAssertEqual(loggedIn, entry)
        XCTAssert(shown is LoadingViewController)
    }

    func testRemoveKeychainEntry() {
        let presenter = LoginStartPresenter(loginDelegate: self, view: self)
        let entry = KeychainEntry.make()
        presenter.removeKeychainEntry(entry)
        XCTAssertEqual(loggedOut, entry)
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
    var loginLogo: UIImage { return .icon(.instructure, .solid) }

    func openExternalURL(_ url: URL) {
        opened = url
    }

    func openSupportTicket() {
        hasOpenedSupportTicket = true
    }

    func userDidLogin(keychainEntry: KeychainEntry) {
        loggedIn = keychainEntry
    }

    func userDidLogout(keychainEntry: KeychainEntry) {
        loggedOut = keychainEntry
    }
}
