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

    func testIdentifier() {
        let api = URLSessionAPI()
        XCTAssertEqual(api.identifier, api.urlSession.configuration.identifier)
    }

    func testUrlSession() {
        let session = URLSessionAPI().urlSession
        XCTAssertNil(session.configuration.urlCache)
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
}
