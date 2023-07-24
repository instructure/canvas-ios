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

class LoginDelegateTests: XCTestCase {
    class MockLogin: LoginDelegate {
        var login: LoginSession?
        var logout: LoginSession?

        func openExternalURL(_ url: URL) {}
        func userDidLogin(session: LoginSession) { login = session }
        func userDidLogout(session: LoginSession) { logout = session }
    }

    func testDefaults() {
        let login = MockLogin()
        XCTAssertTrue(login.supportsCanvasNetwork)
        XCTAssertNotNil(login.helpURL)
        XCTAssertNil(login.whatsNewURL)
        XCTAssertNoThrow(login.changeUser())
    }

    func testUserDidStartActing() {
        let login = MockLogin()
        login.userDidStartActing(as: LoginSession.make())
        XCTAssertNotNil(login.login)
    }

    func testUserDidStopActing() {
        let login = MockLogin()
        login.userDidStopActing(as: LoginSession.make())
        XCTAssertNotNil(login.logout)
    }

    func testStartActing() {
        let login = MockLogin()
        login.startActing(as: LoginSession.make())
        XCTAssertNotNil(login.login)
    }

    func testStopActing() {
        let original = LoginSession.make()
        let acting = LoginSession.make(
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
        let acting = LoginSession.make(masquerader: URL(string: "https://cgnu2.online/users/7"))
        let login = MockLogin()
        login.stopActing(as: acting, findOriginalFrom: [])
        XCTAssertNotNil(login.logout)
        XCTAssertNil(login.login)
    }

    func testStopActingNotActing() {
        let acting = LoginSession.make()
        let login = MockLogin()
        login.stopActing(as: acting, findOriginalFrom: [acting])
        XCTAssertNil(login.logout)
        XCTAssertNil(login.login)
    }
}
