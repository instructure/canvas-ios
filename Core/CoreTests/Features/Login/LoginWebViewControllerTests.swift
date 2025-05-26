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
import WebKit
@testable import Core
import TestsFoundation
import XCTest

class LoginWebViewControllerTests: CoreTestCase {
    var opened: URL?
    var loggedIn: LoginSession?
    let url = URL(string: "https://localhost")!
    lazy var controller = LoginWebViewController.create(host: url.host!, loginDelegate: self, method: .normalLogin)

    override func setUp() {
        super.setUp()
        api.mock(GetMobileVerifyRequest(domain: url.host!), value: APIVerifyClient(authorized: true, base_url: url, client_id: "1", client_secret: "s"))
    }

    func testLayout() {
        controller = LoginWebViewController.create(host: url.host!, loginDelegate: self, method: .normalLogin, clientID: "1")
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.view.backgroundColor, .textLightest.variantForLightMode)
        XCTAssertTrue(
            controller.webView.url?.absoluteString.range(
                // swiftlint:disable:next line_length
                of: #"^https:\/\/localhost\/login\/oauth2\/auth\?client_id=1&redirect_uri=https:\/\/canvas\/login&response_type=code&code_challenge=[A-Za-z0-9_-]+&code_challenge_method=S256&mobile=1$"#,
                options: .regularExpression
            ) != nil
        )
    }

    func testPreloaded() {
        controller.mdmLogin = MDMLogin(host: "localhost", username: "u", password: "p")
        controller.mobileVerifyModel = APIVerifyClient(authorized: true, base_url: url, client_id: "1", client_secret: "s")
        controller.view.layoutIfNeeded()
        let urlExpectation = expectation(description: "")
        let observation = controller.webView.observe(\.url, options: .new) { _, change in
            if let newUrlValue = change.newValue, let newUrl = newUrlValue,
               newUrl.absoluteString == "https://localhost/?username=u&password=p" {
                urlExpectation.fulfill()
            }
        }
        controller.webView.loadHTMLString("""
        <!doctype html>
        <form action="/" method="GET" id="login_form">
        <input type="text" name="username" />
        <input type="password" name="password" />
        <input type="submit" />
        </form>
        """, baseURL: url)
        wait(for: [urlExpectation], timeout: 9)
        observation.invalidate()
    }

    func testPKCERedirectFlow() {
        controller = LoginWebViewController.create(host: url.host!, loginDelegate: self, method: .normalLogin, clientID: "client-id")
        controller.view.layoutIfNeeded()
        let action = MockAction()
        action.mockRequest = URLRequest(url: URL(string: "data:text/plain,")!)
        controller.webView(controller.webView, decidePolicyFor: action) { policy in
            XCTAssertEqual(policy, .allow)
        }

        action.mockRequest = URLRequest(url: URL(string: "https://community.canvaslms.com")!)
        controller.webView(controller.webView, decidePolicyFor: action) { policy in
            XCTAssertEqual(policy, .allow)
        }

        action.mockRequest = URLRequest(url: URL(string: "about:blank")!)
        controller.webView(controller.webView, decidePolicyFor: action) { policy in
            XCTAssertEqual(policy, .cancel)
        }

        let pkceOAuth = OAuthType.pkce(
            .init(
                baseURL: url,
                clientID: "client-id",
                codeVerifier: "code-verifier"
            )
        )
        api.mock(PostLoginOAuthRequest(oauthType: pkceOAuth, code: "c"))
        action.mockRequest = URLRequest(url: URL(string: "https://canvas/login?code=c")!)
        controller.webView(controller.webView, decidePolicyFor: action) { policy in
            XCTAssertEqual(policy, .cancel)
        }
        XCTAssertNotNil(router.presented)

        api.mock(PostLoginOAuthRequest(oauthType: pkceOAuth, code: "c"), value: .make())
        action.mockRequest = URLRequest(url: URL(string: "https://canvas/login?code=c")!)
        controller.webView(controller.webView, decidePolicyFor: action) { policy in
            XCTAssertEqual(policy, .cancel)
        }
        XCTAssertNotNil(loggedIn)
        XCTAssert(router.viewControllerCalls.last?.0 is LoadingViewController)

        action.mockRequest = URLRequest(url: URL(string: "https://canvas/login?error=access_denied")!)
        controller.webView(controller.webView, decidePolicyFor: action) { policy in
            XCTAssertEqual(policy, .cancel)
        }
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Authentication failed. Most likely the user denied the request for access.")

        action.mockRequest = URLRequest(url: URL(string: "https://canvas/login?error=false")!)
        controller.webView(controller.webView, decidePolicyFor: action) { policy in
            XCTAssertEqual(policy, .allow)
        }
    }

    func testManualOAuthRedirectFlow() {
        controller.mobileVerifyModel = APIVerifyClient(authorized: true, base_url: url, client_id: "1", client_secret: "s")
        controller.view.layoutIfNeeded()
        let action = MockAction()
        action.mockRequest = URLRequest(url: URL(string: "data:text/plain,")!)
        controller.webView(controller.webView, decidePolicyFor: action) { policy in
            XCTAssertEqual(policy, .allow)
        }

        action.mockRequest = URLRequest(url: URL(string: "https://community.canvaslms.com")!)
        controller.webView(controller.webView, decidePolicyFor: action) { policy in
            XCTAssertEqual(policy, .allow)
        }

        action.mockRequest = URLRequest(url: URL(string: "about:blank")!)
        controller.webView(controller.webView, decidePolicyFor: action) { policy in
            XCTAssertEqual(policy, .cancel)
        }

        api.mock(PostLoginOAuthRequest(oauthType: .manual(.init(client: controller.mobileVerifyModel!)), code: "c"))
        action.mockRequest = URLRequest(url: URL(string: "https://canvas/login?code=c")!)
        controller.webView(controller.webView, decidePolicyFor: action) { policy in
            XCTAssertEqual(policy, .cancel)
        }
        XCTAssertNotNil(router.presented)

        api.mock(PostLoginOAuthRequest(oauthType: .manual(.init(client: controller.mobileVerifyModel!)), code: "c"), value: .make())
        action.mockRequest = URLRequest(url: URL(string: "https://canvas/login?code=c")!)
        controller.webView(controller.webView, decidePolicyFor: action) { policy in
            XCTAssertEqual(policy, .cancel)
        }
        XCTAssertNotNil(loggedIn)
        XCTAssert(router.viewControllerCalls.last?.0 is LoadingViewController)

        action.mockRequest = URLRequest(url: URL(string: "https://canvas/login?error=access_denied")!)
        controller.webView(controller.webView, decidePolicyFor: action) { policy in
            XCTAssertEqual(policy, .cancel)
        }
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Authentication failed. Most likely the user denied the request for access.")

        action.mockRequest = URLRequest(url: URL(string: "https://canvas/login?error=false")!)
        controller.webView(controller.webView, decidePolicyFor: action) { policy in
            XCTAssertEqual(policy, .allow)
        }
    }

    func testLocaleIsSetOnLogin() {
        controller = LoginWebViewController.create(host: url.host!, loginDelegate: self, method: .normalLogin, clientID: "client-id")
        controller.view.layoutIfNeeded()
        let action = MockAction()
        let token = APIOAuthToken(
            access_token: "token",
            refresh_token: "refresh",
            token_type: "Bearer",
            user: APIOAuthUser(
                id: "1",
                name: "john doe",
                effective_locale: "pt",
                email: nil
            ),
            real_user: nil,
            expires_in: nil,
            canvas_region: "us-east-1"
        )
        let pkceOAuth = OAuthType.pkce(
            .init(
                baseURL: url,
                clientID: "client-id",
                codeVerifier: "code-verifier"
            )
        )
        api.mock(PostLoginOAuthRequest(oauthType: pkceOAuth, code: "c"), value: token)
        action.mockRequest = URLRequest(url: URL(string: "https://canvas/login?code=c")!)
        controller.webView(controller.webView, decidePolicyFor: action) { [weak self] _ in
            XCTAssertEqual(self?.loggedIn?.locale, token.user.effective_locale)
        }
    }

    func testAuthChallenge() {
        controller = LoginWebViewController.create(host: url.host!, loginDelegate: self, method: .normalLogin, clientID: "client-id")
        var disposition: URLSession.AuthChallengeDisposition?
        var credential: URLCredential?
        controller.view.layoutIfNeeded()
        controller.webView(controller.webView, didReceive: .make(authenticationMethod: NSURLAuthenticationMethodHTTPBasic)) {
            disposition = $0
            credential = $1
        }
        let alert = router.presented as? UIAlertController
        XCTAssertEqual(alert?.title, "Login")
        XCTAssertEqual(alert?.textFields?.count, 2)
        alert?.textFields?.first?.text = "user1"
        alert?.textFields?.last?.text = "password123"
        let submit = alert?.actions.first { $0.title == "OK" } as? AlertAction
        submit?.handler?(submit!)
        XCTAssertEqual(disposition, .useCredential)
        XCTAssertEqual(credential?.user, "user1")
        XCTAssertEqual(credential?.password, "password123")
    }

    func testAuthChallengeCancel() {
        controller = LoginWebViewController.create(host: url.host!, loginDelegate: self, method: .normalLogin, clientID: "client-id")
        controller.view.layoutIfNeeded()
        var disposition: URLSession.AuthChallengeDisposition?
        var credential: URLCredential?
        controller.webView(controller.webView, didReceive: .make(authenticationMethod: NSURLAuthenticationMethodHTTPBasic)) {
            disposition = $0
            credential = $1
        }
        let alert = router.presented as? UIAlertController
        XCTAssertEqual(alert?.title, "Login")
        let cancel = alert?.actions.first { $0.title == "Cancel" } as? AlertAction
        cancel?.handler?(cancel!)
        XCTAssertEqual(disposition, .performDefaultHandling)
        XCTAssertNil(credential)
    }

    func testAuthChallengeUnsupported() {
        var disposition: URLSession.AuthChallengeDisposition?
        var credential: URLCredential?
        controller.webView(controller.webView, didReceive: .make(authenticationMethod: NSURLAuthenticationMethodServerTrust)) {
            disposition = $0
            credential = $1
        }
        XCTAssertEqual(disposition, .performDefaultHandling)
        XCTAssertNil(credential)
    }

    func testOpenTab() {
        controller = LoginWebViewController.create(host: url.host!, loginDelegate: self, method: .normalLogin, clientID: "client-id")
        controller.view.layoutIfNeeded()
        let mockAction = MockAction()
        mockAction.mockRequest = URLRequest(url: URL(string: "data:text/plain,")!)
        XCTAssertNil(controller.webView(controller.webView, createWebViewWith: WKWebViewConfiguration(), for: mockAction, windowFeatures: WKWindowFeatures()))
        XCTAssertEqual(controller.webView.url, URL(string: "data:text/plain,"))
    }

    class MockAction: WKNavigationAction {
        var mockRequest: URLRequest!
        override var request: URLRequest { return mockRequest }
    }
}

extension LoginWebViewControllerTests: LoginDelegate {
    func openExternalURL(_ url: URL) {
        opened = url
    }

    func userDidLogin(session: LoginSession) {
        loggedIn = session
    }

    func userDidLogout(session: LoginSession) {}
}
