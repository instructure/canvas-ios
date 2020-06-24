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
            XCTAssertEqual(url.path, "/api/v1/a/b//c/d/e//f/g")
            XCTAssertEqual(url.queryItems, [
                URLQueryItem(name: "h", value: "i"),
                URLQueryItem(name: "j", value: " k"),
                URLQueryItem(name: "l", value: nil),
            ])
            XCTAssertEqual(url.fragment, "mnop")
            return UIViewController()
        }
        XCTAssertNotNil(route.match(URLComponents(string: "/api/v1/a/b//c/d/e//f/g?h=%69&j=+k&l#mnop")!))
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
        let route = RouteHandler("/courses") { _, _ in return UIViewController() }
        XCTAssertNotNil(route.match(.parse("courses")))
    }
}
