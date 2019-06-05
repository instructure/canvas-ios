//
// Copyright (C) 2019-present Instructure, Inc.
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

class LoginDelegateTests: XCTestCase {
    class MockLogin: LoginDelegate {
        var login: KeychainEntry?
        var logout: KeychainEntry?

        func openExternalURL(_ url: URL) {}
        func userDidLogin(keychainEntry: KeychainEntry) { login = keychainEntry }
        func userDidLogout(keychainEntry: KeychainEntry) { logout = keychainEntry }
    }

    func testDefaults() {
        let login = MockLogin()
        XCTAssertTrue(login.supportsCanvasNetwork)
        XCTAssertNotNil(login.helpURL)
        XCTAssertNil(login.whatsNewURL)
        XCTAssertNoThrow(login.openSupportTicket())
        XCTAssertNoThrow(login.changeUser())
    }

    func testUserDidStartActing() {
        let login = MockLogin()
        login.userDidStartActing(as: KeychainEntry.make())
        XCTAssertNotNil(login.login)
    }

    func testUserDidStopActing() {
        let login = MockLogin()
        login.userDidStopActing(as: KeychainEntry.make())
        XCTAssertNotNil(login.logout)
    }

    func testStartActing() {
        let login = MockLogin()
        login.startActing(as: KeychainEntry.make())
        XCTAssertNotNil(login.login)
    }

    func testStopActing() {
        let original = KeychainEntry.make()
        let acting = KeychainEntry.make(
            baseURL: URL(string: "https://cgnu2.online")!,
            masquerader: original.baseURL.appendingPathComponent("users").appendingPathComponent(original.userID),
            userID: "7"
        )
        let login = MockLogin()
        login.stopActing(as: acting, findOriginalFrom: [ original ])
        XCTAssertNotNil(login.logout)
        XCTAssertNotNil(login.login)
    }

    func testStopActingNoOriginal() {
        let acting = KeychainEntry.make(masquerader: URL(string: "https://cgnu2.online/users/7"))
        let login = MockLogin()
        login.stopActing(as: acting, findOriginalFrom: [])
        XCTAssertNotNil(login.logout)
        XCTAssertNil(login.login)
    }

    func testStopActingNotActing() {
        let acting = KeychainEntry.make()
        let login = MockLogin()
        login.stopActing(as: acting, findOriginalFrom: [acting])
        XCTAssertNil(login.logout)
        XCTAssertNil(login.login)
    }
}
