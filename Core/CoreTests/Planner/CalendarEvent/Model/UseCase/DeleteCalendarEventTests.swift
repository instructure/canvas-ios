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

import XCTest
@testable import Core

final class DeleteCalendarEventTests: CoreTestCase {

    func testRequest() {
        let testee = DeleteCalendarEvent(id: "42", seriesModificationType: .following)
        XCTAssertEqual(testee.request.id, "42")
        XCTAssertEqual(testee.request.body?.which, .following)
    }

    func testWrite() {
        CalendarEvent.save(.make(id: "1"), in: databaseClient)
        CalendarEvent.save(.make(id: "2"), in: databaseClient)
        CalendarEvent.save(.make(id: "3"), in: databaseClient)
        let testee = DeleteCalendarEvent(id: "2", seriesModificationType: nil)

        testee.write(response: nil, urlResponse: nil, to: databaseClient)

        let event1: CalendarEvent? = databaseClient.first(where: #keyPath(CalendarEvent.id), equals: "1")
        let event2: CalendarEvent? = databaseClient.first(where: #keyPath(CalendarEvent.id), equals: "2")
        let event3: CalendarEvent? = databaseClient.first(where: #keyPath(CalendarEvent.id), equals: "3")
        XCTAssertEqual(event1?.id, "1")
        XCTAssertEqual(event2?.id, nil)
        XCTAssertEqual(event3?.id, "3")
    }
}
