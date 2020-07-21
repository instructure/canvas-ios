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

class AppEnvironmentTests: CoreTestCase {
    func testUserDidLogin() {
        let env = AppEnvironment()
        env.userDidLogin(session: LoginSession.make(accessToken: "token"))
        XCTAssertEqual(env.api.loginSession?.accessToken, "token")
    }

    func testUserDidLogout() {
        let env = AppEnvironment()
        let current = LoginSession.make(accessToken: "token")
        env.userDidLogin(session: current)
        env.userDidLogout(session: LoginSession.make(userID: "7"))
        XCTAssertEqual(env.api.loginSession?.accessToken, "token")
        env.userDidLogout(session: current)
        XCTAssertNil(env.api.loginSession?.accessToken)
        XCTAssertNil(env.currentSession)
    }

    func testStartup() {
        let env = AppEnvironment()
        var count = 0
        env.performAfterStartup { count += 1 }
        XCTAssertEqual(count, 0)
        env.startupDidComplete()
        XCTAssertEqual(count, 1)
        env.performAfterStartup { count += 1 }
        XCTAssertEqual(count, 2)
    }

    func testReportError() {
        let env = AppEnvironment()
        var error: Error?
        var view: UIViewController?
        env.errorHandler = { e, v in
            error = e
            view = v
        }
        env.reportError(nil)
        XCTAssertNil(error)
        env.reportError(NSError.internalError(), from: UIViewController())
        XCTAssertEqual(error?.localizedDescription, "Internal Error")
        XCTAssertNotNil(view)
    }
}
