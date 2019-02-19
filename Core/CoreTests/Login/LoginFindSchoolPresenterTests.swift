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

class LoginFindSchoolPresenterTests: XCTestCase {
    var helpURL: URL?
    var opened: URL?
    var shown: UIViewController?
    var results: [(domain: String, name: String)]?

    func testViewIsReady() {
        let presenter = LoginFindSchoolPresenter(loginDelegate: nil, method: .normalLogin, view: self)
        presenter.viewIsReady()
        XCTAssertEqual(presenter.queue.operationCount, 0)
    }

    func testSearch() {
        let presenter = LoginFindSchoolPresenter(loginDelegate: nil, method: .normalLogin, view: self)
        let mockAPI = MockAPI()
        mockAPI.mock(GetAccountsSearchRequest(searchTerm: "a"), value: [
            APIAccountResults.make([ "name": "A", "domain": "a.instructure.com" ]),
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
        let account = APIAccountResults.make([ "authentication_provider": "ldap" ])
        presenter.accounts = [account]
        presenter.showLoginForHost(account.domain)
        XCTAssert(shown is LoginWebViewController)
        XCTAssertEqual((shown as? LoginWebViewController)?.presenter?.authenticationProvider, account.authentication_provider)
    }
}

extension LoginFindSchoolPresenterTests: LoginFindSchoolViewProtocol, LoginDelegate {
    var loginLogo: UIImage { return .icon(.instructure, .solid) }

    func openExternalURL(_ url: URL) {
        opened = url
    }

    func userDidLogin(keychainEntry: KeychainEntry) {}
    func userDidLogout(keychainEntry: KeychainEntry) {}

    func show(_ vc: UIViewController, sender: Any?) {
        shown = vc
    }
    func update(results: [(domain: String, name: String)]) {
        self.results = results
    }
}
