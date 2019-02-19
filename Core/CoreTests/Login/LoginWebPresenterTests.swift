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

class LoginWebPresenterTests: XCTestCase {
    lazy var presenter: LoginWebPresenter = {
        return LoginWebPresenter(authenticationProvider: nil, host: "localhost", loginDelegate: self, method: .normalLogin, view: self)
    }()
    var resultingAuthToken: String?
    var expectation: XCTestExpectation!
    var resultingError: Error?
    var resultingRequest: URLRequest?
    var navigationController: UINavigationController?

    override func setUp() {
        super.setUp()
        expectation = XCTestExpectation(description: "expectation")
        presenter.session = URLSession.mockSession()
        presenter.mobileVerifyModel = APIVerifyClient(authorized: true, base_url: URL(string: "https://localhost"), client_id: "1", client_secret: "secret")
        MockURLProtocolSupport.responses.removeAll()
        resultingAuthToken = nil
        resultingError = nil
        resultingRequest = nil
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testNavigationActionPolicyAboutBlankScheme() {
        //  given
        let url = URL(string: "about:blank")!

        //  when
        let result = presenter.navigationActionPolicyForUrl(url: url)

        //  then
        XCTAssertEqual(result, .cancel)
    }

    func testNavigationActionPolicyCommunityCanvasLMSLink() {
        //  given
        let url = URL(string: "https://community.canvaslms.com")!
        //  when
        let result = presenter.navigationActionPolicyForUrl(url: url)
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
        let url = URL(string: "/canvas/login?code=\(code)")!
        let responseData: [String: Any] = [
            "access_token": expectedToken,
            "token_type": "Bearer",
            "user": ["id": "1",
                     "name": "student3",
                     "global_id": "1",
                     "effective_locale": "en",
            ],
            "refresh_token": "<refresh_token>",
            "expires_in": 10,
        ]
        MockURLProtocolSupport.responses.append(MockURLProtocolSupport.responseWithStatusCode(200, responseData: responseData))

        //  when
        let result = presenter.navigationActionPolicyForUrl(url: url)
        wait(for: [expectation], timeout: 0.1)

        //  then
        XCTAssertEqual(result, .cancel)
        XCTAssertEqual(resultingAuthToken, expectedToken)
    }

    func testNavigationActionAuthCodeWhenCodeIsNotFirst() {
        //  given
        let expectedCode = "OAUTH_CODE"
        let url = URL(string: "/canvas/login?bar=foo&code=\(expectedCode)")!
        //  when
        let result = presenter.navigationActionPolicyForUrl(url: url)
        //  then
        XCTAssertEqual(result, .allow)
    }

    func testNavigationActionInvalidLogin() {
        //  given
        let error = "invalidCreds"
        let url = URL(string: "/canvas/login?error=\(error)")!

        //  when
        let result = presenter.navigationActionPolicyForUrl(url: url)
        wait(for: [expectation], timeout: 0.1)
        //  then
        XCTAssertEqual(result, .cancel)
        XCTAssertEqual(resultingError?.localizedDescription, "Authentication failed. Most likely the user denied the request for access.")
    }

    func testFetchClientIDAndFetchAuthToken() {
        presenter.mobileVerifyModel = nil
        let expectedRequest = defuaultRequest()
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
            "user": ["id": "1",
                     "name": "student3",
                     "global_id": "1",
                     "effective_locale": "en",
            ],
            "refresh_token": "<refresh_token>",
            "expires_in": 10,
        ]

        MockURLProtocolSupport.responses.append(MockURLProtocolSupport.responseWithStatusCode(200, responseData: responseData))
        MockURLProtocolSupport.responses.append(MockURLProtocolSupport.responseWithStatusCode(200, responseData: responseData2))

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(resultingRequest?.url, expectedRequest.url)

        resultingAuthToken = nil
        resultingError = nil

        expectation = XCTestExpectation(description: "expectation")
        let action =  presenter.navigationActionPolicyForUrl(url: URL(string: "/canvas/login?code=1234")!)
        wait(for: [expectation], timeout: 0.1)

        XCTAssertEqual(action, .cancel)
        XCTAssertEqual(resultingAuthToken, expectedToken)
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

    func defuaultRequest() -> URLRequest {
        let host = "https://localhost"
        let url = URL(string: host)!
        let mobileVerify = APIVerifyClient(authorized: true, base_url: url, client_id: "1", client_secret: "secret")
        let params = LoginParams(host: host, authenticationProvider: "", method: .normalLogin)
        var req = try! LoginWebRequest(clientID: mobileVerify.client_id!, params: params).urlRequest(relativeTo: url, accessToken: "", actAsUserID: nil)
        req.setValue(UserAgent.safari.description, forHTTPHeaderField: HttpHeader.userAgent)
        return req
    }
}

extension LoginWebPresenterTests: LoginWebViewProtocol, LoginDelegate {
    var loginLogo: UIImage { return .icon(.instructure, .solid) }

    func openExternalURL(_ url: URL) {}

    func userDidLogin(keychainEntry: KeychainEntry) {
        resultingAuthToken = keychainEntry.accessToken
        expectation.fulfill()
    }

    func userDidLogout(keychainEntry: KeychainEntry) {}

    func show(_ vc: UIViewController, sender: Any?) {
        // Loading is shown
    }

    func loadRequest(_ request: URLRequest) {
        resultingRequest = request
        expectation.fulfill()
    }

    func showError(_ error: Error) {
        resultingError = error
        expectation.fulfill()
    }
}
