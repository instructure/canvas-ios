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

    var login: LoginSession?
    func userDidLogin(session: LoginSession) {
        login = session
    }

    var logout: LoginSession?
    func userDidLogout(session: LoginSession) {
        logout = session
    }

    class MockTask: URLSessionDataTask {
        var cancelled = false
        override func cancel() { cancelled = true }
        override func resume() {}
    }
    class MockURLSession: URLSession {
        var request: URLRequest?
        var handler: ((Data?, URLResponse?, Error?) -> Void)?
        override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            self.request = request
            self.handler = completionHandler
            return MockTask()
        }
        override func invalidateAndCancel() {}
    }

    let mock = MockURLSession()
    lazy var presenter: ActAsUserPresenter = {
        let presenter = ActAsUserPresenter(loginDelegate: self)
        presenter.urlSession = mock
        return presenter
    }()

    func testDidSubmitBare() {
        presenter.didSubmit(domain: "cgnu", userID: "1") { _ in }
        XCTAssertEqual(mock.request?.url, URL(string: "https://cgnu.instructure.com/api/v1/users/self?as_user_id=1"))
    }

    func testDidSubmitFull() {
        presenter.didSubmit(domain: "http://cgnu.online/extra", userID: "1") { _ in }
        XCTAssertEqual(mock.request?.url, URL(string: "http://cgnu.online/api/v1/users/self?as_user_id=1"))
    }

    func testDidSubmitNoSession() {
        environment.currentSession = nil
        var error: Error?
        presenter.didSubmit(domain: "cgnu", userID: "1") { e in error = e }
        XCTAssertNotNil(error)
    }

    func testRequestNil() {
        let done = expectation(description: "called back")
        var error: Error?
        presenter.didSubmit(domain: "a", userID: "1") { err in
            error = err
            done.fulfill()
        }
        mock.handler?(nil, nil, nil)
        wait(for: [done], timeout: 1)
        XCTAssertNotNil(error)
    }

    func testRequestError() {
        let done = expectation(description: "called back")
        var error: Error?
        presenter.didSubmit(domain: "a", userID: "1") { err in
            error = err
            done.fulfill()
        }
        mock.handler?(nil, nil, NSError.internalError())
        wait(for: [done], timeout: 1)
        XCTAssertNotNil(error)
    }

    func testSuccess() {
        let done = expectation(description: "called back")
        var error: Error?
        presenter.didSubmit(domain: "a", userID: "1") { err in
            error = err
            done.fulfill()
        }
        let user = APIUser.make()
        mock.handler?(try? JSONEncoder().encode(user), nil, nil)
        wait(for: [done], timeout: 1)
        XCTAssertNil(error)
        XCTAssertEqual(login?.userID, "1")
        XCTAssertEqual(login?.baseURL, URL(string: "https://a.instructure.com"))
        XCTAssertEqual(login?.masquerader, URL(string: "https://canvas.instructure.com/users/1"))
    }
}
