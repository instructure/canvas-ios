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

class GetPageTests: CoreTestCase {
    let context = ContextModel(.course, id: "1")
    let pageURL = "page-test"

    func testCacheKey() {
        XCTAssertEqual(GetPage(context: context, url: pageURL).cacheKey, "get-course_1-page-test")
    }

    func testRequest() {
        let request = GetPage(context: context, url: pageURL).request
        XCTAssertEqual(request.context.canvasContextID, context.canvasContextID)
        XCTAssertEqual(request.url, pageURL)
    }

    func testScope() {
        let scope = GetPage(context: context, url: pageURL).scope
        XCTAssertEqual(scope.predicate, NSPredicate(format: "%K == %@ && %K == %@", #keyPath(Page.contextID), context.canvasContextID, #keyPath(Page.url), pageURL))
    }
}
