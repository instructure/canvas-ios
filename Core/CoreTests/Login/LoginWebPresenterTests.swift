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

class LoginWebPresenterTests: XCTestCase {
    lazy var presenter: LoginWebPresenter = {
        return LoginWebPresenter(authenticationProvider: nil, host: "localhost", loginDelegate: self, method: .normalLogin, view: self)
    }()
    var resultingSession: LoginSession?
    var expectation: XCTestExpectation!
    var resultingError: Error?
    var resultingRequest: URLRequest?
    var script: String?

    override func setUp() {
        super.setUp()
        expectation = XCTestExpectation(description: "expectation")
        presenter.session = URLSession.mockSession()
        presenter.mobileVerifyModel = APIVerifyClient(authorized: true, base_url: URL(string: "https://localhost"), client_id: "1", client_secret: "secret")
        MockURLProtocolSupport.responses.removeAll()
        resultingSession = nil
        resultingError = nil
        resultingRequest = nil
    }

    override func tearDown() {
        Clock.reset()
        super.tearDown()
    }

    func testNavigationActionPolicyAboutBlankScheme() {
        //  given
        let url = URL(string: "about:blank")!

        //  when
        let result = presenter.navigationActionPolicyForURL(url: url)

        //  then
        XCTAssertEqual(result, .cancel)
    }

    func testNavigationActionPolicyCommunityCanvasLMSLink() {
        //  given
        let url = URL(string: "https://community.canvaslms.com")!
        //  when
        let result = presenter.navigationActionPolicyForURL(url: url)
        //  then
        XCTAssertEqual(result, .cancel)
    }

    func testNavigationActionAuthCode() {
        //  given
        let model = APIVerifyClient(authorized: true, base_url: URL(string: "https://twilson.instructure.com"), client_id: "1", client_secret: "client_secret")
        presenter.mobileVerifyModel = model
        presenter.authenticationProvider = ""
        let code = "1234"
        let expectedToken = "access_token"
        let url = URL(string: "https://canvas/login?code=\(code)")!
        let responseData: [String: Any] = [
            "access_token": expectedToken,
            "token_type": "Bearer",
            "user": [
                "id": "1",
                 "name": "student3",
                 "global_id": "1",
                 "effective_locale": "en",
                 "email": "email@email.com",
            ],
            "refresh_token": "<refresh_token>",
            "expires_in": 10,
        ]
        MockURLProtocolSupport.responses.append(MockURLProtocolSupport.responseWithStatusCode(200, responseData: responseData))

        //  when
        let result = presenter.navigationActionPolicyForURL(url: url)
        wait(for: [expectation], timeout: 0.1)

        //  then
        XCTAssertEqual(result, .cancel)
        XCTAssertEqual(resultingSession?.accessToken, expectedToken)
    }

    func testNavigationActionAuthCodeWhenCodeIsNotFirst() {
        //  given
        let expectedCode = "OAUTH_CODE"
        let url = URL(string: "/canvas/login?bar=foo&code=\(expectedCode)")!
        //  when
        let result = presenter.navigationActionPolicyForURL(url: url)
        //  then
        XCTAssertEqual(result, .allow)
    }

    func testNavigationActionInvalidLogin() {
        //  given
        let error = "invalidCreds"
        let url = URL(string: "/canvas/login?error=\(error)")!

        //  when
        let result = presenter.navigationActionPolicyForURL(url: url)
        wait(for: [expectation], timeout: 0.1)
        //  then
        XCTAssertEqual(result, .cancel)
        XCTAssertEqual(resultingError?.localizedDescription, "Authentication failed. Most likely the user denied the request for access.")
    }

    func testFetchClientIDAndFetchAuthToken() {
        let now = Date()
        Clock.mockNow(now)
        presenter.mobileVerifyModel = nil
        let expectedRequest = defaultRequest()
        let expectedClientID = "1"
        let expectedToken = "token"
        let responseData: [String: Any] = [
            "authorized": true,
            "result": 0,
            "client_id": expectedClientID,
            "api_key": "key",
            "client_secret": "secret",
            "base_url": "https://localhost",
        ]

        let responseData2: [String: Any] = [
            "access_token": expectedToken,
            "token_type": "Bearer",
            "user": [
                "id": "1",
                 "name": "student3",
                 "global_id": "1",
                 "effective_locale": "en",
                 "email": "email@email.com",
            ],
            "refresh_token": "<refresh_token>",
            "expires_in": 10,
        ]

        MockURLProtocolSupport.responses.append(MockURLProtocolSupport.responseWithStatusCode(200, responseData: responseData))
        MockURLProtocolSupport.responses.append(MockURLProtocolSupport.responseWithStatusCode(200, responseData: responseData2))

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(resultingRequest?.url, expectedRequest.url)

        resultingSession = nil
        resultingError = nil

        expectation = XCTestExpectation(description: "expectation")
        let action =  presenter.navigationActionPolicyForURL(url: URL(string: "https://canvas/login?code=1234")!)
        wait(for: [expectation], timeout: 0.1)

        XCTAssertEqual(action, .cancel)
        XCTAssertEqual(resultingSession?.accessToken, expectedToken)
        XCTAssertEqual(resultingSession?.expiresAt, now + 10)
    }

    func testManualOAuthFlow() {
        let verify = presenter.mobileVerifyModel!
        presenter.method = .manualOAuthLogin
        presenter.viewIsReady()
        let expectedRequest = try? LoginWebRequest(
            clientID: verify.client_id!,
            params: LoginParams(host: "localhost", authenticationProvider: nil, method: .manualOAuthLogin)
        ).urlRequest(relativeTo: verify.base_url!, accessToken: nil, actAsUserID: nil)
        XCTAssertEqual(resultingRequest, expectedRequest)
    }

    func testWebViewFinishedLoading() {
        MDMManager.mockDefaults()
        presenter.mdmLogin = MDMManager.shared.logins[0]
        presenter.viewIsReady()
        presenter.webViewFinishedLoading()
        XCTAssertEqual(script, """
            const form = document.querySelector('#login_form')
            form.querySelector('[type=email],[type=text]').value = 'apple'
            form.querySelector('[type=password]').value = 'titaniumium'
            form.submit()
            """
        )
    }

    func defaultRequest() -> URLRequest {
        let host = "https://localhost"
        let url = URL(string: host)!
        let mobileVerify = APIVerifyClient(authorized: true, base_url: url, client_id: "1", client_secret: "secret")
        let params = LoginParams(host: host, authenticationProvider: nil, method: .normalLogin)
        var req = try! LoginWebRequest(clientID: mobileVerify.client_id!, params: params).urlRequest(relativeTo: url, accessToken: "", actAsUserID: nil)
        req.setValue(UserAgent.safari.description, forHTTPHeaderField: HttpHeader.userAgent)
        return req
    }
}

extension LoginWebPresenterTests: LoginWebViewProtocol, LoginDelegate {
    func openExternalURL(_ url: URL) {}

    func userDidLogin(session: LoginSession) {
        resultingSession = session
        expectation.fulfill()
    }

    func userDidLogout(session: LoginSession) {}

    func show(_ vc: UIViewController, sender: Any?) {
        // Loading is shown
    }

    func loadRequest(_ request: URLRequest) {
        resultingRequest = request
        expectation.fulfill()
    }

    func showAlert(title: String?, message: String?) {}

    func showError(_ error: Error) {
        resultingError = error
        expectation.fulfill()
    }

    func evaluateJavaScript(_ script: String) {
        self.script = script
    }
}
