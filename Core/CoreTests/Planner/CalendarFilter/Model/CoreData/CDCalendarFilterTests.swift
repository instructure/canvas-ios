//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Core
import XCTest

class CDCalendarFilterTests: CoreTestCase {

    func testSelectedContexts() {
        let courseContext = Context(.course, id: "1")
        let groupContext = Context(.group, id: "2")
        let userContext = Context(.user, id: "3")
        let testee: CDCalendarFilter = databaseClient.insert()

        testee.selectedContexts = [
            courseContext,
            groupContext,
            userContext,
        ]

        XCTAssertEqual(testee.rawSelectedContexts.count, 3)
        XCTAssertTrue(testee.rawSelectedContexts.contains(courseContext.canvasContextID))
        XCTAssertTrue(testee.rawSelectedContexts.contains(groupContext.canvasContextID))
        XCTAssertTrue(testee.rawSelectedContexts.contains(userContext.canvasContextID))
        XCTAssertEqual(testee.selectedContexts, Set([
            courseContext,
            groupContext,
            userContext,
        ]))
    }
}
