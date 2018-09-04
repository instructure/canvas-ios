//
//  ClientTests.swift
//
//  Created by Garrett Richards on 8/2/18.
//  Copyright © 2018 Instructure. All rights reserved.
//

import XCTest
@testable import Core

class LoginPresenterTests: XCTestCase {

    var presenter = LoginPresenter(host: "localhost")
    var resultingAuthToken: String?
    var expectation: XCTestExpectation!
    var resultingError: Error?
    var resultingRequest: URLRequest?

    override func setUp() {
        super.setUp()
        expectation = XCTestExpectation(description: "expectation")
        presenter = LoginPresenter(host: "localhost")
        presenter.session = URLSession.mockSession()
        presenter.view = self
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
            ],
            "refresh_token": "<refresh_token>",
            "expires_in": 10,
        ]

        MockURLProtocolSupport.responses.append(MockURLProtocolSupport.responseWithStatusCode(200, responseData: responseData))
        MockURLProtocolSupport.responses.append(MockURLProtocolSupport.responseWithStatusCode(200, responseData: responseData2))

        presenter.constructAuthenticationRequest(method: .defaultMethod)
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

    func testPrepRequestUserAgent() {
        //  given
        let expected = UserAgent.safari.description
        var req = defuaultRequest()

        //  when
        req = LoginPresenter.prepLoginRequest(req, method: .defaultMethod)

        //  then
        XCTAssertEqual(req.value(forHTTPHeaderField: HttpHeader.userAgent), expected)
    }

    func defuaultRequest() -> URLRequest {
        let host = "https://localhost"
        let url = URL(string: host)!
        let mobileVerify = APIVerifyClient(authorized: true, base_url: url, client_id: "1", client_secret: "secret")
        let params = LoginParams(host: host, authenticationProvider: "", method: .defaultMethod)
        var req = try! LoginWebRequest(clientID: mobileVerify.client_id, params: params).urlRequest(relativeTo: url, accessToken: "")
        req.setValue(UserAgent.safari.description, forHTTPHeaderField: HttpHeader.userAgent)
        return req
    }
}

extension LoginPresenterTests: LoginViewProtocol, ErrorViewController {
    func didConstructAuthenticationRequest(_ request: URLRequest) {
        resultingRequest = request
        expectation.fulfill()
    }

    func userDidLogin(auth: APIOAuthToken) {
        resultingAuthToken = auth.access_token
        expectation.fulfill()
    }

    func showError(_ error: Error) {
        resultingError = error
        expectation.fulfill()
    }
}
