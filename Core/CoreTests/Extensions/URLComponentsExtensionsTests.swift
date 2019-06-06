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

class URLComponentsExtensionsTests: XCTestCase {
    func testParseURL() {
        let string = "scheme://user:password@host/path/1/2/3?query=a&b#fragment"
        let url = URL(string: string)!
        XCTAssertEqual(URLComponents.parse(url), URLComponents(string: string)!)
    }

    func testParseURLWithEncoding() {
        let string = "scheme://us%2Fer:pass%2Fword@ho%2Fst/pa%3Fth/1/2/3?query=%2F&b#fra%2Fgment"
        let url = URL(string: string)!
        XCTAssertEqual(URLComponents.parse(url), URLComponents(string: string)!)
    }

    func testParseString() {
        let string = "scheme://user:password@host/path/1/2/3?query=a&b#fragment"
        XCTAssertEqual(URLComponents.parse(string), URLComponents(string: string)!)
    }

    func testParseBadString() {
        let string = "scheme://host space/path|<>&:@%25?query=a&b#fragment"
        let url = URLComponents.parse(string)
        XCTAssertEqual(url.scheme, "scheme")
        XCTAssertEqual(url.host, "host space")
        XCTAssertEqual(url.path, "/path|<>&:@%")
        XCTAssertEqual(url.query, "query=a&b")
        XCTAssertEqual(url.fragment, "fragment")
    }

    func testParseReallyBadString() {
        let url = URLComponents.parse("%")
        XCTAssertEqual(url.scheme, nil)
        XCTAssertEqual(url.host, nil)
        XCTAssertEqual(url.path, "%")
        XCTAssertEqual(url.query, nil)
        XCTAssertEqual(url.fragment, nil)
        XCTAssertEqual(URLComponents.parse("").path, "")
    }

    func testCleanupApiVersionInPath() {
        var string = "scheme://host/api/v1/path"
        var url = URLComponents.parse(string)
        url.cleanupApiVersionInPath()
        XCTAssertEqual(url.scheme, "scheme")
        XCTAssertEqual(url.host, "host")
        XCTAssertEqual(url.path, "/path")

        string = "api/v1/path"
        url = URLComponents.parse(string)
        url.cleanupApiVersionInPath()
        XCTAssertEqual(url.path, "/path")

        string = "/api/v1/path"
        url = URLComponents.parse(string)
        url.cleanupApiVersionInPath()
        XCTAssertEqual(url.path, "/path")

        string = "/foobar/api/v1/path"
        url = URLComponents.parse(string)
        url.cleanupApiVersionInPath()
        XCTAssertEqual(url.path, "/foobar/api/v1/path")

        string = "/api/v2/path"
        url = URLComponents.parse(string)
        url.cleanupApiVersionInPath()
        XCTAssertEqual(url.path, "/path")

        string = "/api/V4/path"
        url = URLComponents.parse(string)
        url.cleanupApiVersionInPath()
        XCTAssertEqual(url.path, "/path")

        string = "/api/w1/path"
        url = URLComponents.parse(string)
        url.cleanupApiVersionInPath()
        XCTAssertEqual(url.path, "/api/w1/path")

        string = "/api/vv1/path"
        url = URLComponents.parse(string)
        url.cleanupApiVersionInPath()
        XCTAssertEqual(url.path, "/api/vv1/path")
    }
}
