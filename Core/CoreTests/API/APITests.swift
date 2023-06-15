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

private let accountResultsUrl = Bundle(for: APITests.self).url(forResource: "APIAccountResults", withExtension: "json")!

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
        let path = accountResultsUrl.absoluteString
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

    var api: API { AppEnvironment.shared.api }
    override func setUp() {
        super.setUp()
        API.resetMocks(useMocks: false)
        AppEnvironment.shared.userDidLogin(session: .make())
    }

    func testUrlSession() {
        XCTAssertNil(api.urlSession.configuration.urlCache)
    }

    func testBaseURL() {
        let expected = URL(string: "https://foo.com")!
        XCTAssertEqual(API(.make(baseURL: expected)).baseURL, expected)
        XCTAssertEqual(API(.make(baseURL: URL(string: "https://bar.com")!), baseURL: expected).baseURL, expected)
        XCTAssertEqual(API().baseURL, URL(string: "https://canvas.instructure.com/"))
    }

    func testMakeRequestInvalidPath() {
        let expectation = XCTestExpectation(description: "request callback runs")
        let task = api.makeRequest(InvalidPath()) { value, response, error in
            XCTAssertNil(value)
            XCTAssertNotNil(response)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNotNil(task)
    }

    func testMakeRequestUnsupported() {
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
        let expectation = XCTestExpectation(description: "request callback runs")
        let task = api.makeRequest(WrongResponse()) { value, response, error in
            XCTAssertNil(value)
            XCTAssertNotNil(response)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        XCTAssertNotNil(task)
    }

    func testSuccess() {
        API.resetMocks()
        api.mock(GetAccountsSearchRequest(), value: [])
        let task = api.makeRequest(GetAccountsSearchRequest()) { value, response, error in
            XCTAssertNotNil(value)
            XCTAssertNil(response)
            XCTAssertNil(error)
        }
        XCTAssertNotNil(task)
    }

    func testNoContentNeeded() {
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

    func testMakeDownloadRequestErrorNoCallback() {
        let task = api.makeDownloadRequest(URL(string: "custom://host.tld/api/v1")!)
        XCTAssertNotNil(task)
    }

    func testMakeDownloadRequestError() {
        let downloadURL = URL(string: "custom://host.tld/api/v1")!
        let expectation = XCTestExpectation(description: "request callback runs")
        let task = api.makeDownloadRequest(downloadURL) { url, response, error in
            XCTAssertNil(url)
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
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
        let file = URL.Directories.temporary.appendingPathComponent(UUID.string)
        XCTAssert(FileManager.default.fileExists(atPath: file.path))
        let value = try? String(contentsOf: file, encoding: .utf8)
        XCTAssertEqual(value, "/file.png")
    }

    func testNoFollowRedirect() {
        let expectation = XCTestExpectation(description: "handler called")
        let url = URL(string: "/")!
        NoFollowRedirect().urlSession(
            URLSession.noFollowRedirect,
            task: URLSession.noFollowRedirect.dataTask(with: accountResultsUrl),
            willPerformHTTPRedirection: HTTPURLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil),
            newRequest: URLRequest(url: url)
        ) { request in
            XCTAssertNil(request)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testRefreshToken() {
        API.resetMocks()
        Clock.mockNow(Date())
        let session = LoginSession.make(
            accessToken: "expired-token",
            refreshToken: "refresh-token",
            clientID: "client-id",
            clientSecret: "client-secret"
        )
        AppEnvironment.shared.currentSession = session
        api.loginSession = session
        api.refreshQueue = OperationQueue.main
        let url = URL(string: "https://canvas.instructure.com/api/v1/courses")!
        let response = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)
        api.mock(url: url, response: response)
        let refresh = api.mock(
            PostLoginOAuthRequest(
                client: APIVerifyClient(
                    authorized: true,
                    base_url: api.baseURL,
                    client_id: "client-id",
                    client_secret: "client-secret"
                ),
                refreshToken: "refresh-token"
            ),
            value: .make(accessToken: "new-token", expiresIn: 3600)
        )
        refresh.suspend()
        api.makeRequest(url) { _, _, error in XCTAssertNil(error) }
        api.makeRequest(url) { _, _, error in XCTAssertNil(error) }
        refresh.resume()
        XCTAssertEqual(api.loginSession?.accessToken, "new-token")
        XCTAssertEqual(api.loginSession?.expiresAt, Clock.now.addingTimeInterval(3600))
        XCTAssertEqual(AppEnvironment.shared.currentSession?.accessToken, "new-token")
        XCTAssertTrue(LoginSession.sessions.contains(where: { $0.accessToken == "new-token" }))
    }

    func testRefreshTokenNotCurrentSession() {
        API.resetMocks()
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
        api.refreshQueue = OperationQueue.main
        let url = URL(string: "https://canvas.instructure.com/api/v1/courses")!
        let response = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)
        api.mock(url: url, response: response)
        api.mock(
            PostLoginOAuthRequest(
                client: APIVerifyClient(
                    authorized: true,
                    base_url: api.baseURL,
                    client_id: "client-id",
                    client_secret: "client-secret"
                ),
                refreshToken: "refresh-token"
            ),
            value: .make(accessToken: "new-token")
        )
        api.makeRequest(url) { _, _, error in XCTAssertNil(error) }
        XCTAssertEqual(api.loginSession?.accessToken, "new-token")
        XCTAssertNotEqual(AppEnvironment.shared.currentSession?.accessToken, "new-token")
        XCTAssertTrue(LoginSession.sessions.contains(where: { $0.accessToken == "new-token" }))
    }

    func testRefreshTokenError() {
        API.resetMocks()
        let session = LoginSession.make(
            accessToken: "expired-token",
            refreshToken: "refresh-token",
            clientID: "client-id",
            clientSecret: "client-secret"
        )
        api.loginSession = session
        api.refreshQueue = OperationQueue.main
        let url = URL(string: "https://canvas.instructure.com/api/v1/courses")!
        let response = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)
        api.mock(url: url, response: response, error: NSError.internalError())
        api.mock(
            PostLoginOAuthRequest(
                client: APIVerifyClient(
                    authorized: true,
                    base_url: api.baseURL,
                    client_id: "client-id",
                    client_secret: "client-secret"
                ),
                refreshToken: "refresh-token"
            ),
            error: NSError.internalError()
        )
        api.makeRequest(url) { _, _, error in XCTAssertNotNil(error) }
        XCTAssertEqual(api.loginSession?.accessToken, "expired-token")
    }

    func testNoRefreshToken() {
        API.resetMocks()
        AppEnvironment.shared.userDidLogin(session: .make(refreshToken: nil))
        let url = URL(string: "https://canvas.instructure.com/api/v1/courses")!
        let response = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)
        api.mock(url: url, response: response, error: NSError.internalError())
        api.makeRequest(url) { _, _, error in XCTAssertNotNil(error) }
        api.refreshQueue.waitUntilAllOperationsAreFinished()
    }

    func testExhaust() {
        API.resetMocks()
        let request = Exhaustable(path: "/1")
        api.mock(request, value: [1], response: HTTPURLResponse(next: "/2"))
        api.mock(Exhaustable(path: "/2"), value: [2], response: HTTPURLResponse(next: "/3"))
        api.mock(Exhaustable(path: "/3"), value: [3], response: nil)
        var response: [Int]?
        var urlResponse: URLResponse?
        var error: Error?
        api.exhaust(request) {
            response = $0
            urlResponse = $1
            error = $2
        }
        XCTAssertEqual(response, [1, 2, 3])
        XCTAssertNil(urlResponse)
        XCTAssertNil(error)
    }

    func testExhaustError() {
        API.resetMocks()
        let request = Exhaustable(path: "/1")
        api.mock(request, value: [1], response: HTTPURLResponse(next: "/2"))
        api.mock(Exhaustable(path: "/2"), value: [2], response: HTTPURLResponse(next: "/3"))
        api.mock(Exhaustable(path: "/3"), value: nil, error: NSError.internalError())
        var response: [Int]?
        var urlResponse: URLResponse?
        var error: Error?
        api.exhaust(request) {
            response = $0
            urlResponse = $1
            error = $2
        }
        XCTAssertNil(response)
        XCTAssertNil(urlResponse)
        XCTAssertNotNil(error)
    }

    func testRetryOnRateLimitedRequest() {
        API.resetMocks()
        api.refreshQueue = OperationQueue.main
        let responseExpectation = expectation(description: "API response")
        let url = URL(string: "https://instructure.com/")!

        let rateLimitResponse = HTTPURLResponse(url: url, statusCode: 403, httpVersion: nil, headerFields: nil)
        let rateLimitData = "403 Forbidden (Rate Limit Exceeded)\n".data(using: .utf8)
        api.mock(url, data: rateLimitData, response: rateLimitResponse, error: nil)

        api.makeRequest(url) { _, response, _ in
            // This will be called when the request is re-tried and the mock returns a non rate-limited response.
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
            responseExpectation.fulfill()
        }
        RunLoop.main.run(until: Date() + 0.1)

        let normalResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        api.mock(url, data: nil, response: normalResponse, error: nil)
        wait(for: [responseExpectation], timeout: 1)
    }
}
