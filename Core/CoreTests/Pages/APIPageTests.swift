//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

class APIPageTests: XCTestCase {
    let courseContext = Context(.course, id: "42")
    let groupContext = Context(.group, id: "42")

    func testGetPagesRequest() {
        XCTAssertEqual(GetPagesRequest(context: courseContext).path, "courses/42/pages")
        XCTAssertEqual(GetPagesRequest(context: groupContext).path, "groups/42/pages")
        XCTAssertEqual(GetPagesRequest(context: courseContext).queryItems, [
            URLQueryItem(name: "sort", value: "title"),
            URLQueryItem(name: "include[]", value: "body"),
        ])
    }

    func testGetFrontPageRequest() {
        XCTAssertEqual(GetFrontPageRequest(context: courseContext).path, "courses/42/front_page")
        XCTAssertEqual(GetFrontPageRequest(context: groupContext).path, "groups/42/front_page")
    }

    func testGetPageRequest() {
        XCTAssertEqual(GetPageRequest(context: courseContext, url: "course-page").path, "courses/42/pages/course%2Dpage")
        XCTAssertEqual(GetPageRequest(context: groupContext, url: "group-page").path, "groups/42/pages/group%2Dpage")
        XCTAssertEqual(GetPageRequest(context: courseContext, url: "2-|-textbook-chapters-unit-3").path, "courses/42/pages/2%2D%7C%2Dtextbook%2Dchapters%2Dunit%2D3")
    }

    func testDeletePageRequest() {
        XCTAssertEqual(DeletePageRequest(context: courseContext, url: "course-page").path, "courses/42/pages/course%2Dpage")
        XCTAssertEqual(DeletePageRequest(context: courseContext, url: "2-|-textbook-chapters-unit-3").path, "courses/42/pages/2%2D%7C%2Dtextbook%2Dchapters%2Dunit%2D3")
        XCTAssertEqual(DeletePageRequest(context: groupContext, url: "group-page").path, "groups/42/pages/group%2Dpage")
        XCTAssertEqual(DeletePageRequest(context: courseContext, url: "course-page").method, APIMethod.delete)
    }
}
