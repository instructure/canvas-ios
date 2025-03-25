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

        XCTAssertEqual(testee.wrappedContext, nil)

        testee.context = testContext

        XCTAssertEqual(testee.rawContextID, testContext.canvasContextID)
        XCTAssertEqual(testee.context, testContext)
        XCTAssertEqual(testee.wrappedContext, testContext)
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
        testee.name = ""

        ContextColor.make(canvasContextID: "course_42", color: .red, in: databaseClient)

        XCTAssertEqual(testee.color.hexString, CourseColorsInteractorLive().courseColorFromAPIColor(.red).hexString)
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

    func testSaveWhenContextIsValid() {
        let result = CDCalendarFilterEntry.save(
            context: .group("42"),
            observedUserId: "7",
            name: "some name",
            purpose: .viewing,
            in: databaseClient
        )
        XCTAssertNoThrow(try databaseClient.save())

        let fetched: CDCalendarFilterEntry? = databaseClient.fetch().first

        XCTAssertEqual(result?.rawContextID, "group_42")
        XCTAssertEqual(result?.observedUserId, "7")
        XCTAssertEqual(result?.name, "some name")
        XCTAssertEqual(result?.rawPurpose, CDCalendarFilterPurpose.viewing.rawValue)

        XCTAssertEqual(fetched?.context, result?.context)
        XCTAssertEqual(fetched?.observedUserId, result?.observedUserId)
        XCTAssertEqual(fetched?.name, result?.name)
        XCTAssertEqual(fetched?.purpose, result?.purpose)
    }

    func testSaveWhenContextIsNotValid() {
        let result = CDCalendarFilterEntry.save(
            context: .group(""),
            name: "name",
            in: databaseClient
        )
        XCTAssertNoThrow(try databaseClient.save())

        let fetched: CDCalendarFilterEntry? = databaseClient.fetch().first

        XCTAssertEqual(result, nil)
        XCTAssertEqual(fetched, nil)
    }
}
