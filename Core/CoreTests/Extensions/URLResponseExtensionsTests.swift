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
            "Link": "<\(curr)>; rel=\"current\",<>;, <\(prev)>; rel=\"prev\", <\(next)>; rel=\"next\"; count=1",
        ]
        let response = HTTPURLResponse(url: URL(string: curr)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
        XCTAssertEqual(response?.links, [
            "current": URL(string: curr)!,
            "prev": URL(string: prev)!,
            "next": URL(string: next)!,
        ])
    }

    func testURLResponseLinks() {
        let response = URLResponse(url: URL(string: "a")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        XCTAssertNil(response.links)
    }

    func testUnauthenticated() {
        XCTAssertTrue(HTTPURLResponse(url: URL(string: "/")!, statusCode: 401, httpVersion: nil, headerFields: nil)!.unauthorized)
        XCTAssertFalse(HTTPURLResponse(url: URL(string: "/")!, statusCode: 201, httpVersion: nil, headerFields: nil)!.unauthorized)
        XCTAssertFalse(URLResponse(url: URL(string: "/")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil).unauthorized)
    }
}
