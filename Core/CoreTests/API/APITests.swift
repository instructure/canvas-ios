//
// Copyright (C) 2016-present Instructure, Inc.
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
        typealias Response = [APIAccountResults]
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
        wait(for: [expectation], timeout: 1.0)
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
        XCTAssertNoThrow(try URLSessionAPI().uploadTask(GetNoContent(), fromFile: URL(string: "/")!))
    }
}
