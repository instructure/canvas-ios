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

class APIQueryItem_Tests: XCTestCase {
    func testToQueryItems() {
        XCTAssertEqual(APIQueryItem.name("param").toURLQueryItems(), [URLQueryItem(name: "param", value: nil)])
        XCTAssertEqual(APIQueryItem.value("a", "b").toURLQueryItems(), [URLQueryItem(name: "a", value: "b")])
        XCTAssertEqual(APIQueryItem.array("include", [ "a", "b" ]).toURLQueryItems(), [URLQueryItem(name: "include[]", value: "a"), URLQueryItem(name: "include[]", value: "b")])
    }
}

class APIRequestable_Tests: XCTestCase {
    let baseURL = URL(string: "https://cgnuonline-eniversity.edu")!
    let accessToken = "fhwdgads"

    struct DateHaver: Codable, Equatable {
        let date = Date(timeIntervalSince1970: 0)
    }

    struct GetDate: APIRequestable {
        typealias Response = DateHaver
        let path = "date"
    }

    struct InvalidPath: APIRequestable {
        typealias Response = DateHaver
        let path = "<>"
    }

    struct GetQueryItems: APIRequestable {
        typealias Response = DateHaver
        let path = ""
        let query: [APIQueryItem] = [.name("query")]
    }

    struct PostBody: APIRequestable {
        typealias Response = DateHaver
        typealias Body = DateHaver
        let body: Body? = DateHaver()
        let method: APIMethod = .post
        let path = "post"
        let headers: [String : String?] = [
            "Content-Type": "application/json"
        ]
    }

    func expectedUrlRequest(path: String) -> URLRequest {
        var expected = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
        expected.httpMethod = "GET"
        expected.setValue("application/json+canvas-string-ids", forHTTPHeaderField: "Accept")
        expected.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        expected.setValue(APIUserAgent, forHTTPHeaderField: "User-Agent")
        return expected
    }

    func testAPIUserAgent() {
        XCTAssert(APIUserAgent.contains(UIDevice.current.model))
        XCTAssert(APIUserAgent.contains(UIDevice.current.systemName))
        XCTAssert(APIUserAgent.contains(UIDevice.current.systemVersion))
    }
    
    func testUrlRequestPath() {
        let expected = expectedUrlRequest(path: "api/v1/date")
        XCTAssertEqual(try GetDate().urlRequest(relativeTo: baseURL, accessToken: accessToken), expected)
    }

    func testUrlRequestInvalidPath() {
        XCTAssertThrowsError(try InvalidPath().urlRequest(relativeTo: baseURL, accessToken: accessToken)) { error in
            XCTAssertEqual(error as! APIRequestableError, APIRequestableError.invalidPath("<>"))
        }
    }

    func testUrlRequestQuery() {
        let expected = expectedUrlRequest(path: "api/v1/?query")
        XCTAssertEqual(try GetQueryItems().urlRequest(relativeTo: baseURL, accessToken: accessToken), expected)
    }

    func testUrlRequestNoResolve() {
        var expected = expectedUrlRequest(path: "api/v1/post")
        expected.httpMethod = "POST"
        expected.setValue("application/json", forHTTPHeaderField: "Content-Type")
        expected.httpBody = "{\"date\":\"1970-01-01T00:00:00Z\"}".data(using: .utf8)
        XCTAssertEqual(try PostBody().urlRequest(relativeTo: baseURL, accessToken: accessToken), expected)
    }
}
