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

    struct Exhaustable: APIRequestable {
        typealias Response = [Int]

        let path: String
    }

    var api: URLSessionAPI!
    override func setUp() {
        super.setUp()
        MockURLSession.reset()
        api = AppEnvironment.shared.api as? URLSessionAPI
        AppEnvironment.shared.currentSession = LoginSession.make()
        ExperimentalFeature.allEnabled = true
    }

    override func tearDown() {
        super.tearDown()
        ExperimentalFeature.allEnabled = false
    }

    func testIdentifier() {
        XCTAssertEqual(api.identifier, api.urlSession.configuration.identifier)
    }

    func testUrlSession() {
        XCTAssertNotNil(api.urlSession.configuration.urlCache)
    }

    func testBaseURL() {
        let expected = URL(string: "https://foo.com")!
        XCTAssertEqual(URLSessionAPI(session: LoginSession.make(baseURL: expected)).baseURL, expected)
        XCTAssertEqual(URLSessionAPI(loginSession: LoginSession.make(baseURL: URL(string: "https://bar.com")!), baseURL: expected).baseURL, expected)
        XCTAssertEqual(URLSessionAPI(loginSession: nil, baseURL: nil).baseURL, URL(string: "https://canvas.instructure.com/")!)
    }

    func testMakeRequestInvalidPath() {
        let expectation = XCTestExpectation(description: "request callback runs")
        let task = api.makeRequest(InvalidPath()) { value, response, error in
            XCTAssertNil(value)
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(task)
    }

    func testMakeRequestUnsupported() {
        MockURLSession.mock(InvalidScheme(), error: NSError.internalError())
        let expectation = XCTestExpectation(description: "request callback runs")
        let task = api.makeRequest(InvalidScheme()) { value, response, error in
            XCTAssertNil(value)
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(task)
    }

    func testMakeRequestWrongResponse() {
        var data: Data?
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        data = try! encoder.encode([APIAccountResult.make()])
        MockURLSession.mock(WrongResponse(), data: data, response: HTTPURLResponse(url: api.baseURL, statusCode: 200, httpVersion: nil, headerFields: nil), error: NSError.internalError())

        let expectation = XCTestExpectation(description: "request callback runs")
        let task = api.makeRequest(WrongResponse()) { value, response, error in
            XCTAssertNil(value)
            XCTAssertNotNil(response)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(task)
    }

    func testNoCredsNeeded() {
        MockURLSession.mock(GetAccountsSearchRequest(), value: [APIAccountResult.make()], response: HTTPURLResponse(url: api.baseURL, statusCode: 200, httpVersion: nil, headerFields: nil))
        let expectation = XCTestExpectation(description: "request callback runs")
        let task = api.makeRequest(GetAccountsSearchRequest()) { value, response, error in
            XCTAssertNotNil(value)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(task)
    }

    func testNoContentNeeded() {
        MockURLSession.mock(GetNoContent(), value: nil, response: HTTPURLResponse(url: api.baseURL, statusCode: 200, httpVersion: nil, headerFields: nil))
        let expectation = XCTestExpectation(description: "request callback runs")
        let task = api.makeRequest(GetNoContent()) { value, response, error in
            XCTAssertNil(value)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        XCTAssertNotNil(task)
    }

    func testMakeDownloadRequest() {
        let downloadURL = URL(string: "https://download.com/download")!
        let tempURL = URL(string: "file://test/file.txt")
        MockURLSession.mockDownload(downloadURL, value: tempURL, response: HTTPURLResponse(url: api.baseURL, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil)
        let expectation = XCTestExpectation(description: "request callback runs")
        let task = api.makeDownloadRequest(downloadURL) { url, response, error in
            XCTAssertEqual(url, tempURL)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(task)
    }

    func testMakeDownloadRequestError() {
        let downloadURL = URL(string: "custom://host.tld/api/v1")!
        MockURLSession.mockDownload(downloadURL, value: nil, response: nil, error: NSError.internalError())
        let expectation = XCTestExpectation(description: "request callback runs")
        let task = api.makeDownloadRequest(downloadURL) { url, response, error in
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
        XCTAssertNoThrow(try api.uploadTask(request))
    }

    func testMakeUploadRequestEncodesToFile() {
        UUID.mock("testfile")
        let url = URL(fileURLWithPath: "/file.png")
        let request = UploadFile(body: url)
        try! api.uploadTask(request)
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
        Clock.mockNow(Date())
        let session = LoginSession.make(
            accessToken: "expired-token",
            refreshToken: "refresh-token",
            clientID: "client-id",
            clientSecret: "client-secret"
        )
        AppEnvironment.shared.currentSession = session
        api.loginSession = session
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
            value: APIOAuthToken.make(accessToken: "new-token", expiresIn: 3600),
            accessToken: session.accessToken
        )
        let expectation = XCTestExpectation(description: "request callback was called")
        api.makeRequest(request) { _, _, error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        XCTAssertEqual(api.loginSession?.accessToken, "new-token")
        XCTAssertEqual(api.loginSession?.expiresAt, Clock.now.addingTimeInterval(3600))
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
        api.loginSession = session
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
        api.loginSession = session
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

    func testExhaust() {
        let api = URLSessionAPI(session: .make(), urlSession: MockURLSession())
        let request = Exhaustable(path: "/1")
        MockURLSession.mock(request, value: [1], response: HTTPURLResponse(next: "/2"))
        MockURLSession.mock(Exhaustable(path: "/2"), value: [2], response: HTTPURLResponse(next: "/3"))
        MockURLSession.mock(Exhaustable(path: "/3"), value: [3], response: nil)
        var response: [Int]?
        var urlResponse: URLResponse?
        var error: Error?
        let expectation = XCTestExpectation(description: "exhaust callback")
        api.exhaust(request) {
            response = $0
            urlResponse = $1
            error = $2
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(response, [1, 2, 3])
        XCTAssertNil(urlResponse)
        XCTAssertNil(error)
    }

    func testExhaustError() {
        let api = URLSessionAPI(session: .make(), urlSession: MockURLSession())
        let request = Exhaustable(path: "/1")
        MockURLSession.mock(request, value: [1], response: HTTPURLResponse(next: "/2"))
        MockURLSession.mock(Exhaustable(path: "/2"), value: [2], response: HTTPURLResponse(next: "/3"))
        MockURLSession.mock(Exhaustable(path: "/3"), value: nil, error: NSError.internalError())
        var response: [Int]?
        var urlResponse: URLResponse?
        var error: Error?
        let expectation = XCTestExpectation(description: "exhaust callback")
        api.exhaust(request) {
            response = $0
            urlResponse = $1
            error = $2
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertNil(response)
        XCTAssertNil(urlResponse)
        XCTAssertNotNil(error)

    }
}
