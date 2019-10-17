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

import Foundation
@testable import Core
import TestsFoundation

class LoginWebViewControllerTests: CoreTestCase {
    var viewController: LoginWebViewController!

    override func setUp() {
        super.setUp()
        viewController = LoginWebViewController.create(host: "mhowe", loginDelegate: nil, method: .normalLogin)
    }

    func load() {
        XCTAssertNotNil(viewController.view)
    }

    func testWebViewDidReceiveChallengeNTLM() throws {
        load()
        try handleUsernameAndPasswordChallenge(NSURLAuthenticationMethodNTLM)
    }

    func testWebViewDidReceiveChallengeHTTPBasic() throws {
        load()
        try handleUsernameAndPasswordChallenge(NSURLAuthenticationMethodHTTPBasic)
    }

    func testWebViewDidReceiveUsernameAndPasswordChallengeCancel() throws {
        load()
        let challenge = URLAuthenticationChallenge.make(authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
        let expectation = XCTestExpectation(description: "challenge completion handler")
        var disposition: URLSession.AuthChallengeDisposition?
        var credential: URLCredential?
        viewController.webView(viewController.webView, didReceive: challenge) {
            disposition = $0
            credential = $1
            expectation.fulfill()
        }
        drainMainQueue()
        let alert = try XCTUnwrap(router.presented as? UIAlertController)
        XCTAssertEqual(alert.title, "Login")
        let cancel = try XCTUnwrap(alert.actions.first { $0.title == "Cancel" } as? AlertAction)
        XCTAssertNotNil(cancel.handler)
        cancel.handler?(cancel)
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(disposition, .performDefaultHandling)
        XCTAssertNil(credential)
    }

    func testWebViewDidReceiveChallengeServerTrust() throws {
        load()
        let challenge = URLAuthenticationChallenge.make(authenticationMethod: NSURLAuthenticationMethodServerTrust)
        let expectation = XCTestExpectation(description: "challenge completion handler")
        var disposition: URLSession.AuthChallengeDisposition?
        var credential: URLCredential?
        viewController.webView(viewController.webView, didReceive: challenge) {
            disposition = $0
            credential = $1
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(disposition, .performDefaultHandling)
        XCTAssertNil(credential)
    }

    func handleUsernameAndPasswordChallenge(_ authenticationMethod: String) throws {
        let challenge = URLAuthenticationChallenge.make(authenticationMethod: authenticationMethod)
        let expectation = XCTestExpectation(description: "challenge completion handler")
        var disposition: URLSession.AuthChallengeDisposition?
        var credential: URLCredential?
        viewController.webView(viewController.webView, didReceive: challenge) {
            disposition = $0
            credential = $1
            expectation.fulfill()
        }
        drainMainQueue()
        let alert = try XCTUnwrap(router.presented as? UIAlertController)
        XCTAssertEqual(alert.title, "Login")
        XCTAssertEqual(alert.textFields?.count, 2)
        alert.textFields?.first?.text = "user1"
        alert.textFields?.last?.text = "password123"
        let submit = try XCTUnwrap(alert.actions.first { $0.title == "OK" } as? AlertAction)
        XCTAssertNotNil(submit.handler)
        submit.handler?(submit)
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(disposition, .useCredential)
        XCTAssertEqual(credential?.user, "user1")
        XCTAssertEqual(credential?.password, "password123")
    }
}
