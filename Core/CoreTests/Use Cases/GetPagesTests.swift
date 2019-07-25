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

import Foundation
import XCTest
@testable import Core

class GetPagesTest: CoreTestCase {
    let courseContext = ContextModel(.course, id: "42")

    func testProperties() {
        let useCase = GetPages(context: courseContext)
        XCTAssertEqual(useCase.cacheKey, "get-course_42-pages")
        XCTAssertEqual(useCase.request.context.canvasContextID, courseContext.canvasContextID)
    }

    func testWriteNothing() {
        GetPages(context: courseContext).write(response: nil, urlResponse: nil, to: databaseClient)
        let pages: [Page] = databaseClient.fetch()
        XCTAssertEqual(pages.count, 0)
    }

    func testWrite() {
        let useCase = GetPages(context: courseContext)
        let page = APIPage.make()
        useCase.write(response: [page], urlResponse: nil, to: databaseClient)
        let pages: [Page] = databaseClient.fetch()
        XCTAssertEqual(pages.count, 1)
        XCTAssertEqual(pages.first?.contextID, courseContext.canvasContextID)
    }
}
