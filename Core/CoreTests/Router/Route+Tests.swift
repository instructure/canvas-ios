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

class RouteTests: XCTestCase {
    func testSegments() {
        let route = Route("/a//b/:c/d/*e") { _ in return nil }
        XCTAssertEqual(route.segments, [
            .literal("a"),
            .literal("b"),
            .param("c"),
            .literal("d"),
            .splat("e"),
        ])
    }

    func testMatch() {
        let route = Route("/a//b/:c/d/*e") { match in
            XCTAssertEqual(match.path, "a/b//c/d/e//f/g")
            XCTAssertEqual(match.params, [
                "c": "c",
                "e": "e/f/g",
            ])
            XCTAssertEqual(match.query, [
                "h": "i",
                "j": " k",
                "l": "",
            ])
            XCTAssertEqual(match.fragment, "mnop")
            return UIViewController()
        }
        XCTAssertNotNil(route.match(URLComponents(string: "a/b//c/d/e//f/g?h=%69&j=+k&l#mnop")!))
    }

    func testMatchTooShort() {
        let route = Route("/a//b/:c/d") { _ in return UIViewController() }
        XCTAssertNil(route.match(URLComponents(string: "a/b/c")!))
    }

    func testMatchTooLong() {
        let route = Route("/a//b/:c/d") { _ in return UIViewController() }
        XCTAssertNil(route.match(URLComponents(string: "a/b/c/d/e")!))
    }

    func testMatchNone() {
        let route = Route("a") { _ in return UIViewController() }
        XCTAssertNil(route.match(URLComponents(string: "b")!))
    }
}
