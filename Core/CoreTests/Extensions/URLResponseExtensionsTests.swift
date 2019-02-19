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
}
