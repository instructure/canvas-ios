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

class LoginFindSchoolPresenterTests: XCTestCase {
    var helpURL: URL?
    var opened: URL?
    var shown: UIViewController?
    var results: [APIAccountResult]?

    func testViewIsReady() {
        let presenter = LoginFindSchoolPresenter(loginDelegate: nil, method: .normalLogin, view: self)
        presenter.viewIsReady()
        XCTAssertNil(presenter.searchTask)
    }

    func testSearch() {
        let presenter = LoginFindSchoolPresenter(loginDelegate: nil, method: .normalLogin, view: self)
        let mockAPI = MockAPI()
        mockAPI.mock(GetAccountsSearchRequest(searchTerm: "a"), value: [
            APIAccountResult.make(name: "A", domain: "a.instructure.com"),
        ])
        presenter.api = mockAPI
        presenter.search(query: "a")
        presenter.search(query: "a") // test preempting old operations
        let expectation = self.expectation(for: NSPredicate(value: true), evaluatedWith: presenter) { self.results != nil }
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(results?.count, 1)

        presenter.search(query: "")
        XCTAssertEqual(results?.count, 0)
    }

    func testSearchNoResults() {
        let presenter = LoginFindSchoolPresenter(loginDelegate: nil, method: .normalLogin, view: self)
        let mockAPI = MockAPI()
        mockAPI.mock(GetAccountsSearchRequest(searchTerm: "bogus"))
        presenter.api = mockAPI
        presenter.search(query: "bogus")
        let expectation = self.expectation(for: NSPredicate(value: true), evaluatedWith: presenter) { self.results != nil }
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(results?.count, 0)
    }

    func testShowHelp() {
        let presenter = LoginFindSchoolPresenter(loginDelegate: self, method: .normalLogin, view: self)
        presenter.showHelp()
        XCTAssertNil(opened)

        helpURL = URL(string: "help")
        presenter.showHelp()
        XCTAssertEqual(opened, helpURL)
    }

    func testShowLoginForHostManualOAuth() {
        let presenter = LoginFindSchoolPresenter(loginDelegate: nil, method: .manualOAuthLogin, view: self)
        presenter.showLoginForHost("mobiledev.instructure.com")
        XCTAssert(shown is LoginManualOAuthViewController)
    }

    func testShowLoginForHost() {
        let presenter = LoginFindSchoolPresenter(loginDelegate: nil, method: .normalLogin, view: self)
        presenter.showLoginForHost("mobiledev.instructure.com")
        XCTAssert(shown is LoginWebViewController)
    }

    func testShowLoginForAccount() {
        let presenter = LoginFindSchoolPresenter(loginDelegate: nil, method: .normalLogin, view: self)
        let account = APIAccountResult.make(authentication_provider: "ldap")
        presenter.accounts = [account]
        presenter.showLoginForHost(account.domain)
        XCTAssert(shown is LoginWebViewController)
        XCTAssertEqual((shown as? LoginWebViewController)?.presenter?.authenticationProvider, account.authentication_provider)
    }
}

extension LoginFindSchoolPresenterTests: LoginFindSchoolViewProtocol, LoginDelegate {
    func openExternalURL(_ url: URL) {
        opened = url
    }

    func userDidLogin(keychainEntry: KeychainEntry) {}
    func userDidLogout(keychainEntry: KeychainEntry) {}

    func show(_ vc: UIViewController, sender: Any?) {
        shown = vc
    }
    func update(results: [APIAccountResult]) {
        self.results = results
    }
}
