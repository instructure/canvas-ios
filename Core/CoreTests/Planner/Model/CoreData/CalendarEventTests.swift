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

class CalendarEventTests: CoreTestCase {

    func testRoutingURL() {
        let event = CalendarEvent.make()
        let expected = URL(string: "calendar_events/1")
        XCTAssertEqual(event.routingURL, expected)
    }

    func testIsPartOfSeries() {
        let event = CalendarEvent.make()

        event.repetitionRule = nil
        event.seriesInNaturalLanguage = nil
        XCTAssertEqual(event.isPartOfSeries, false)

        event.repetitionRule = ""
        event.seriesInNaturalLanguage = ""
        XCTAssertEqual(event.isPartOfSeries, false)

        event.repetitionRule = "something"
        event.seriesInNaturalLanguage = nil
        XCTAssertEqual(event.isPartOfSeries, false)

        event.repetitionRule = nil
        event.seriesInNaturalLanguage = "anything"
        XCTAssertEqual(event.isPartOfSeries, false)

        event.repetitionRule = "something"
        event.seriesInNaturalLanguage = "anything"
        XCTAssertEqual(event.isPartOfSeries, true)
    }
}
