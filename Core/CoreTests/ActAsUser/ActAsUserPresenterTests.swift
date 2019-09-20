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
import TestsFoundation

class ActAsUserPresenterTests: CoreTestCase, LoginDelegate {
    var opened: URL?
    func openExternalURL(_ url: URL) {
        opened = url
    }

    var session: LoginSession?
    let onLogin = XCTestExpectation(description: "userDidLogin")
    func userDidLogin(session: LoginSession) {
        self.session = session
        onLogin.fulfill()
    }

    var logout: LoginSession?
    func userDidLogout(session: LoginSession) {
        logout = session
    }

    lazy var presenter: ActAsUserPresenter = {
        let presenter = ActAsUserPresenter(loginDelegate: self)
        return presenter
    }()

    func testDidSubmit() {
        MockURLSession.mock(GetUserRequest(userID: "1"), value: APIUser.make(), baseURL: URL(string: "https://cgnu.instructure.com")!, accessToken: presenter.env.currentSession?.accessToken)
        presenter.didSubmit(domain: "cgnu", userID: "1") { _ in }
        wait(for: [onLogin], timeout: 1)
        XCTAssertNotNil(session)
    }

    func testDidSubmitExtra() {
        MockURLSession.mock(GetUserRequest(userID: "1"), value: APIUser.make(), baseURL: URL(string: "http://cgnu.online")!, accessToken: presenter.env.currentSession?.accessToken)
        presenter.didSubmit(domain: "http://cgnu.online/extra", userID: "1") { _ in }
        wait(for: [onLogin], timeout: 1)
        XCTAssertNotNil(session)
    }

    func testDidSubmitNoSession() {
        environment.currentSession = nil
        var error: Error?
        presenter.didSubmit(domain: "cgnu", userID: "1") { e in error = e }
        XCTAssertNotNil(error)
    }

    func testRequestNil() {
        MockURLSession.mock(GetUserRequest(userID: "1"), value: nil, baseURL: URL(string: "https://cgnu.online")!)
        let done = expectation(description: "called back")
        var error: Error?
        presenter.didSubmit(domain: "https://cgnu.online", userID: "1") { err in
            error = err
            done.fulfill()
        }
        wait(for: [done], timeout: 1)
        XCTAssertNotNil(error)
    }

    func testRequestError() {
        MockURLSession.mock(GetUserRequest(userID: "1"), value: nil, error: NSError.internalError(), baseURL: URL(string: "https://cgnu.online")!)
        let done = expectation(description: "called back")
        var error: Error?
        presenter.didSubmit(domain: "https://cgnu.online", userID: "1") { err in
            error = err
            done.fulfill()
        }
        wait(for: [done], timeout: 1)
        XCTAssertNotNil(error)
    }

    func testSuccess() {
        MockURLSession.mock(GetUserRequest(userID: "1"), value: APIUser.make(), baseURL: URL(string: "https://cgnu.instructure.com")!, accessToken: presenter.env.currentSession?.accessToken)
        let done = expectation(description: "called back")
        var error: Error?
        presenter.didSubmit(domain: "cgnu", userID: "1") { err in
            error = err
            done.fulfill()
        }
        wait(for: [done], timeout: 1)
        XCTAssertNil(error)
        XCTAssertEqual(session?.userID, "1")
        XCTAssertEqual(session?.baseURL, URL(string: "https://cgnu.instructure.com"))
        XCTAssertEqual(session?.masquerader, URL(string: "https://canvas.instructure.com/users/1"))
    }
}
