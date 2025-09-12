//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

class APIPageInfoTests: XCTestCase {

    func test_nextCursor() {
        let pageInfoWithNext = APIPageInfo(endCursor: "cursor123", hasNextPage: true)
        XCTAssertEqual(pageInfoWithNext.nextCursor, "cursor123")

        let pageInfoWithoutNext = APIPageInfo(endCursor: "cursor123", hasNextPage: false)
        XCTAssertNil(pageInfoWithoutNext.nextCursor)

        let pageInfoNilCursorWithNext = APIPageInfo(endCursor: nil, hasNextPage: true)
        XCTAssertNil(pageInfoNilCursorWithNext.nextCursor)

        let pageInfoNilCursorWithoutNext = APIPageInfo(endCursor: nil, hasNextPage: false)
        XCTAssertNil(pageInfoNilCursorWithoutNext.nextCursor)
    }
}
