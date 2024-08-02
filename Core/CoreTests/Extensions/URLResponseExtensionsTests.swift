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

class URLResponseExtensionsTests: XCTestCase {
    func testHTTPURLResponseLinks() {
        let prev = "https://cgnuonline-eniversity.edu/api/v1/courses?page=1"
        let curr = "https://cgnuonline-eniversity.edu/api/v1/courses?page=2"
        let next = "https://cgnuonline-eniversity.edu/api/v1/courses?page=3"
        let headers = [
            "Link": "<\(curr)>; rel=\"current\",<>;, <\(prev)>; rel=\"prev\", <\(next)>; rel=\"next\"; count=1"
        ]
        let response = HTTPURLResponse(url: URL(string: curr)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
        XCTAssertEqual(response?.links, [
            "current": URL(string: curr)!,
            "prev": URL(string: prev)!,
            "next": URL(string: next)!
        ])
    }

    func testURLResponseLinks() {
        let response = URLResponse(url: URL(string: "a")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        XCTAssertNil(response.links)
    }

    func testUnauthorized() {
        let unautorizedResponse = HTTPURLResponse(
            url: .make(),
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )!
        XCTAssertTrue(unautorizedResponse.isUnauthorized)

        let forbiddenResponse = HTTPURLResponse(
            url: .make(),
            statusCode: 403,
            httpVersion: nil,
            headerFields: nil
        )!
        XCTAssertFalse(forbiddenResponse.isUnauthorized)

        let createdResponse = HTTPURLResponse(
            url: .make(),
            statusCode: 201,
            httpVersion: nil,
            headerFields: nil
        )!
        XCTAssertFalse(createdResponse.isUnauthorized)

        let nonHttpURLResponse = URLResponse(
            url: .make(),
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
        XCTAssertFalse(nonHttpURLResponse.isUnauthorized)
    }

    func testExceededLimit() {
        let httpResponse = HTTPURLResponse(url: URL(string: "https://instructure.com")!, statusCode: 403, httpVersion: "HTTP/2.0", headerFields: [:])!
        let data = "403 Forbidden (Rate Limit Exceeded)".data(using: .utf8)

        XCTAssertTrue(httpResponse.exceededLimit(responseData: data))
    }

    func testExceededLimitWithoutData() {
        let httpResponse = HTTPURLResponse(url: URL(string: "https://instructure.com")!, statusCode: 403, httpVersion: "HTTP/2.0", headerFields: [:])!

        XCTAssertFalse(httpResponse.exceededLimit(responseData: nil))
    }

    func testExceededLimitWithMismatchingData() {
        let httpResponse = HTTPURLResponse(url: URL(string: "https://instructure.com")!, statusCode: 403, httpVersion: "HTTP/2.0", headerFields: [:])!
        let data = "403 Forbidden".data(using: .utf8)

        XCTAssertFalse(httpResponse.exceededLimit(responseData: data))
    }

    func testExceededLimitWithNonHTTPResponse() {
        let response = URLResponse(url: URL(string: "https://instructure.com")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let data = "403 Forbidden (Rate Limit Exceeded)".data(using: .utf8)

        XCTAssertFalse(response.exceededLimit(responseData: data))
    }
}
