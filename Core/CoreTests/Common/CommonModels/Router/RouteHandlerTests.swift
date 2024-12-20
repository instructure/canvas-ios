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
        let route = RouteHandler("/a//b/:c/d/*e") { _, _, _ in return nil }
        XCTAssertEqual(route.segments, [
            .literal("a"),
            .literal("b"),
            .param("c"),
            .literal("d"),
            .splat("e")
        ])
    }

    func testMatch() {
        let route = RouteHandler("/a//b/:c/d/*e") { _, _, _ in return nil }
        XCTAssertEqual(route.match(.parse("/api/v1/a/b//c/d/e//f/g?h=%69&j=+k&l#mnop")), [
            "c": "c",
            "e": "e/f/g"
        ])
    }

    func testMatchTooShort() {
        let route = RouteHandler("/a//b/:c/d") { _, _, _ in return UIViewController() }
        XCTAssertNil(route.match(.parse("a/b/c")))
    }

    func testMatchTooLong() {
        let route = RouteHandler("/a//b/:c/d") { _, _, _ in return UIViewController() }
        XCTAssertNil(route.match(.parse("a/b/c/d/e")))
    }

    func testMatchNone() {
        let route = RouteHandler("a") { _, _, _ in return UIViewController() }
        XCTAssertNil(route.match(.parse("b")))
    }

    func testMatchRoute() {
        let route = RouteHandler("/courses") { _, _, _ in return UIViewController() }
        XCTAssertNotNil(route.match(.parse("courses")))
    }

    func testTildeIDExpansion() {
        let route = RouteHandler(":contextID") { _, _, _ in return UIViewController() }
        let parts = route.match(.parse("1234~5678"))
        XCTAssertEqual(parts?["contextID"], "12340000000005678")
    }

    func testTildeIDRoute() {
        let route = RouteHandler("/courses/:courseID/quizzes/:quizID") { _, _, _ in return UIViewController() }
        let parts = route.match(.parse("courses/1234~5678/quizzes/1234~567"))
        XCTAssertEqual(parts?["courseID"], "12340000000005678")
        XCTAssertEqual(parts?["quizID"], "12340000000000567")
    }
}
