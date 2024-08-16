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
import SwiftUI
import XCTest

class CDCalendarFilterEntryTests: CoreTestCase {

    func testContext() {
        let testee: CDCalendarFilterEntry = databaseClient.insert()
        let testContext = Context(.group, id: "g1")

        testee.context = testContext

        XCTAssertEqual(testee.rawContextID, testContext.canvasContextID)
        XCTAssertEqual(testee.context, testContext)
    }

    func testSort() {
        let courseA: CDCalendarFilterEntry = databaseClient.insert()
        courseA.context = .course("1")
        courseA.name = "A"
        let courseB: CDCalendarFilterEntry = databaseClient.insert()
        courseB.context = .course("1")
        courseB.name = "B"
        let groupA: CDCalendarFilterEntry = databaseClient.insert()
        groupA.context = .group("1")
        groupA.name = "A"
        let groupB: CDCalendarFilterEntry = databaseClient.insert()
        groupB.context = .group("1")
        groupB.name = "B"
        let user: CDCalendarFilterEntry = databaseClient.insert()
        user.context = .user("1")
        user.name = "U"

        var testee = [courseA, courseB, user, groupA, groupB].shuffled()

        // WHEN
        testee.sort()

        // THEN
        XCTAssertEqual(testee, [user, courseA, courseB, groupA, groupB])
    }

    func testColorFetch() {
        let testee: CDCalendarFilterEntry = databaseClient.insert()
        testee.context = .course("42")

        let color: ContextColor = databaseClient.insert()
        color.canvasContextID = "course_42"
        color.colorRaw = UIColor.red.intValue

        XCTAssertEqual(UIColor(testee.color).hexString, UIColor.red.hexString)
    }

    func testCourseName() {
        let testee: CDCalendarFilterEntry = databaseClient.insert()
        testee.name = "some name"

        testee.context = .course("1")
        XCTAssertEqual(testee.courseName, "some name")

        testee.context = .user("1")
        XCTAssertEqual(testee.courseName, nil)

        testee.context = .group("1")
        XCTAssertEqual(testee.courseName, nil)
    }
}
