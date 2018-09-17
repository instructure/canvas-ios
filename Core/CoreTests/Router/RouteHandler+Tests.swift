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

class RouteHandlerTests: XCTestCase {
    func testSegments() {
        let route = RouteHandler("/a//b/:c/d/*e") { _, _ in return nil }
        XCTAssertEqual(route.segments, [
            .literal("a"),
            .literal("b"),
            .param("c"),
            .literal("d"),
            .splat("e"),
        ])
    }

    func testMatch() {
        let route = RouteHandler("/a//b/:c/d/*e") { url, params in
            XCTAssertEqual(params, [
                "c": "c",
                "e": "e/f/g",
            ])
            XCTAssertEqual(url.path, "a/b//c/d/e//f/g")
            XCTAssertEqual(url.queryItems, [
                URLQueryItem(name: "h", value: "i"),
                URLQueryItem(name: "j", value: " k"),
                URLQueryItem(name: "l", value: nil),
            ])
            XCTAssertEqual(url.fragment, "mnop")
            return UIViewController()
        }
        XCTAssertNotNil(route.match(URLComponents(string: "a/b//c/d/e//f/g?h=%69&j=+k&l#mnop")!))
    }

    func testMatchTooShort() {
        let route = RouteHandler("/a//b/:c/d") { _, _ in return UIViewController() }
        XCTAssertNil(route.match(URLComponents(string: "a/b/c")!))
    }

    func testMatchTooLong() {
        let route = RouteHandler("/a//b/:c/d") { _, _ in return UIViewController() }
        XCTAssertNil(route.match(URLComponents(string: "a/b/c/d/e")!))
    }

    func testMatchNone() {
        let route = RouteHandler("a") { _, _ in return UIViewController() }
        XCTAssertNil(route.match(URLComponents(string: "b")!))
    }

    func testMatchRoute() {
        let route = RouteHandler(.login) { _, _ in return UIViewController() }
        XCTAssertNotNil(route.match(Route.login.url))
    }
}
