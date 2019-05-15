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
import TestsFoundation

class ActAsUserPresenterTests: CoreTestCase, LoginDelegate {
    let loginLogo = UIImage.icon(.instructure)

    var opened: URL?
    func openExternalURL(_ url: URL) {
        opened = url
    }

    var login: KeychainEntry?
    func userDidLogin(keychainEntry: KeychainEntry) {
        login = keychainEntry
    }

    var logout: KeychainEntry?
    func userDidLogout(keychainEntry: KeychainEntry) {
        logout = keychainEntry
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
