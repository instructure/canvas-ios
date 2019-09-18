//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

let accountResultsUrl = Bundle(for: APITests.self).url(forResource: "APIAccountResults", withExtension: "json")!

class APITests: XCTestCase {

    struct DateHaver: Codable, Equatable {
        let date: Date
    }

    struct InvalidScheme: APIRequestable {
        typealias Response = DateHaver
        let path = "custom://host.tld/api/v1"
    }

    struct InvalidPath: APIRequestable {
        typealias Response = DateHaver
        let path = "<>"
    }

    struct WrongResponse: APIRequestable {
        typealias Response = DateHaver
        var path = accountResultsUrl.absoluteString
    }

    struct GetAccountsSearchRequest: APIRequestable {
        typealias Response = [APIAccountResult]
        let path = accountResultsUrl.absoluteString
    }

    struct UploadBody: APIRequestable {
        typealias Response = DateHaver
        let path = "upload"
        func encode() throws -> Data? {
            return "hello".data(using: .utf8)!
        }
    }

    struct GetNoContent: APIRequestable {
        typealias Response = APINoContent

        let path = "/health_check"
        let headers: [String: String?] = [
            HttpHeader.accept: "text/html",
        ]
    }

    struct UploadFile: APIRequestable {
        typealias Response = APINoContent
        typealias Body = URL

        let body: URL?
        let path = "/file-upload"
        func encode(_ body: URL) throws -> Data {
            return body.path.data(using: .utf8)!
        }
    }

    override func setUp() {
        super.setUp()
        URLSessionAPI.defaultURLSession = {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.urlCache = nil
            return URLSession(configuration: configuration)
        }()
        AppEnvironment.shared.currentSession = LoginSession.make()
    }

    func testIdentifier() {
        let api = URLSessionAPI()
        XCTAssertEqual(api.identifier, api.urlSession.configuration.identifier)
    }

    func testUrlSession() {
        let session = URLSessionAPI().urlSession
        XCTAssertNil(session.configuration.urlCache)
    }

    func testBaseURL() {
        let expected = URL(string: "https://foo.com")!
        XCTAssertEqual(URLSessionAPI(session: LoginSession.make(baseURL: expected)).baseURL, expected)
        XCTAssertEqual(URLSessionAPI(loginSession: LoginSession.make(baseURL: URL(string: "https://bar.com")!), baseURL: expected).baseURL, expected)
        XCTAssertEqual(URLSessionAPI(loginSession: nil, baseURL: nil).baseURL, URL(string: "https://canvas.instructure.com")!)
    }

    func testMakeRequestInvalidPath() {
        let expectation = XCTestExpectation(description: "request callback runs")
        let task = URLSessionAPI().makeRequest(InvalidPath()) { value, response, error in
            XCTAssertNil(value)
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(task)
    }

    func testMakeRequestUnsupported() {
        let expectation = XCTestExpectation(description: "request callback runs")
        let task = URLSessionAPI().makeRequest(InvalidScheme()) { value, response, error in
            XCTAssertNil(value)
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(task)
    }

    func testMakeRequestWrongResponse() {
        let expectation = XCTestExpectation(description: "request callback runs")
        let task = URLSessionAPI().makeRequest(WrongResponse()) { value, response, error in
            XCTAssertNil(value)
            XCTAssertNotNil(response)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(task)
    }

    func testNoCredsNeeded() {
        let expectation = XCTestExpectation(description: "request callback runs")
        let task = URLSessionAPI().makeRequest(GetAccountsSearchRequest()) { value, response, error in
            XCTAssertNotNil(value)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(task)
    }

    func testNoContentNeeded() {
        let expectation = XCTestExpectation(description: "request callback runs")
        let task = URLSessionAPI().makeRequest(GetNoContent()) { value, response, error in
            XCTAssertNil(value)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        XCTAssertNotNil(task)
    }

    func testMakeDownloadRequest() {
        let expectation = XCTestExpectation(description: "request callback runs")
        let task = URLSessionAPI().makeDownloadRequest(URL(string: "custom://host.tld/api/v1")!) { url, response, error in
            XCTAssertNil(url)
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(task)
    }

    func testMakeUploadRequest() {
        UUID.mock("testfile")
        let url = URL(fileURLWithPath: "/file.png")
        let request = UploadFile(body: url)
        XCTAssertNoThrow(try URLSessionAPI().uploadTask(request))
    }

    func testMakeUploadRequestEncodesToFile() {
        UUID.mock("testfile")
        let url = URL(fileURLWithPath: "/file.png")
        let request = UploadFile(body: url)
        try! URLSessionAPI().uploadTask(request)
        let file = URL.temporaryDirectory.appendingPathComponent(UUID.string)
        XCTAssert(FileManager.default.fileExists(atPath: file.path))
        let value = try? String(contentsOf: file, encoding: .utf8)
        XCTAssertEqual(value, "/file.png")
    }

    func testNoFollowRedirect() {
        let expectation = XCTestExpectation(description: "handler called")
        let url = URL(string: "/")!
        NoFollowRedirect().urlSession(
            URLSessionAPI.noFollowRedirectURLSession,
            task: MockURLSession.MockDataTask(),
            willPerformHTTPRedirection: HTTPURLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil),
            newRequest: URLRequest(url: url)
        ) { request in
            XCTAssertNil(request)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }

    func testRefreshToken() {
        let session = LoginSession.make(
            accessToken: "expired-token",
            refreshToken: "refresh-token",
            clientID: "client-id",
            clientSecret: "client-secret"
        )
        AppEnvironment.shared.currentSession = session
        let api = URLSessionAPI(loginSession: session, urlSession: MockURLSession())
        let url = URL(string: "https://canvas.instructure.com/api/v1/courses")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)
        MockURLSession.mock(
            request,
            value: nil,
            response: response,
            accessToken: session.accessToken
        )
        MockURLSession.mock(
            PostLoginOAuthRequest(
                client: APIVerifyClient(
                    authorized: true,
                    base_url: api.baseURL,
                    client_id: "client-id",
                    client_secret: "client-secret"
                ),
                refreshToken: "refresh-token"
            ),
            value: APIOAuthToken.make(accessToken: "new-token"),
            accessToken: session.accessToken
        )
        let expectation = XCTestExpectation(description: "request callback was called")
        api.makeRequest(request) { _, _, error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        XCTAssertEqual(api.loginSession?.accessToken, "new-token")
        XCTAssertEqual(AppEnvironment.shared.currentSession?.accessToken, "new-token")
        XCTAssertTrue(LoginSession.sessions.contains(where: { $0.accessToken == "new-token" }))
    }

    func testRefreshTokenNotCurrentSession() {
        AppEnvironment.shared.currentSession = LoginSession.make(
            accessToken: "expired-token",
            baseURL: URL(string: "https://other.instructure.com")!,
            refreshToken: "refresh-token",
            clientID: "client-id",
            clientSecret: "client-secret"
        )
        let session = LoginSession.make(
            accessToken: "expired-token",
            baseURL: URL(string: "https://canvas.instructure.com")!,
            refreshToken: "refresh-token",
            clientID: "client-id",
            clientSecret: "client-secret"
        )
        let api = URLSessionAPI(loginSession: session, urlSession: MockURLSession())
        let url = URL(string: "https://canvas.instructure.com/api/v1/courses")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)
        MockURLSession.mock(
            request,
            value: nil,
            response: response,
            accessToken: session.accessToken
        )
        MockURLSession.mock(
            PostLoginOAuthRequest(
                client: APIVerifyClient(
                    authorized: true,
                    base_url: api.baseURL,
                    client_id: "client-id",
                    client_secret: "client-secret"
                ),
                refreshToken: "refresh-token"
            ),
            value: APIOAuthToken.make(accessToken: "new-token"),
            accessToken: session.accessToken
        )
        let expectation = XCTestExpectation(description: "request callback was called")
        api.makeRequest(request) { _, _, error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        XCTAssertEqual(api.loginSession?.accessToken, "new-token")
        XCTAssertNotEqual(AppEnvironment.shared.currentSession?.accessToken, "new-token")
        XCTAssertTrue(LoginSession.sessions.contains(where: { $0.accessToken == "new-token" }))
    }

    func testRefreshTokenError() {
        let session = LoginSession.make(
            accessToken: "expired-token",
            refreshToken: "refresh-token",
            clientID: "client-id",
            clientSecret: "client-secret"
        )
        let api = URLSessionAPI(loginSession: session, urlSession: MockURLSession())
        let url = URL(string: "https://canvas.instructure.com/api/v1/courses")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)
        MockURLSession.mock(
            request,
            value: nil,
            response: response,
            error: NSError.internalError(),
            accessToken: session.accessToken
        )
        MockURLSession.mock(
            PostLoginOAuthRequest(
                client: APIVerifyClient(
                    authorized: true,
                    base_url: api.baseURL,
                    client_id: "client-id",
                    client_secret: "client-secret"
                ),
                refreshToken: "refresh-token"
            ),
            error: NSError.internalError(),
            accessToken: session.accessToken
        )
        let expectation = XCTestExpectation(description: "request callback was called")
        api.makeRequest(request) { _, _, error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        XCTAssertEqual(api.loginSession?.accessToken, "expired-token")
    }

}
