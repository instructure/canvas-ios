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
import TestsFoundation

class GetCalendarEventsTests: CoreTestCase {

    var ctx = Context(.course, id: "1")
    var useCase: GetCalendarEvents!

    override func setUp() {
        super.setUp()

        ctx = Context(.course, id: "1")
        useCase = GetCalendarEvents(context: ctx)
    }

    func testItCreatesCalendarEvents() {
        let event = APICalendarEvent.make(id: "1", context_code: "course_1")
        useCase.write(response: [event], urlResponse: nil, to: databaseClient)

        let events: [CalendarEvent] = databaseClient.fetch()
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.id, "1")
        XCTAssertEqual(events.first?.title, "calendar event #1")
        XCTAssertEqual(events.first?.context.canvasContextID, ctx.canvasContextID)
    }

    func testCache() {
        XCTAssertEqual("(courses/1)/calendar-events/event", useCase.cacheKey)
    }

    func testMultipleContextCache() {
        let contexts = [Context(.course, id: "1"), Context(.course, id: "2")]
        useCase = GetCalendarEvents(contexts: contexts)
        XCTAssertEqual("(courses/1|courses/2)/calendar-events/event", useCase.cacheKey)
    }

    func testScopePredicate() {
        let b = CalendarEvent.make(from: .make(id: "2", title: "b"))
        let a = CalendarEvent.make(from: .make(id: "1", title: "a"))
        CalendarEvent.make(from: .make(id: "3", title: "c", context_code: "course_2")) // should not show up b/c of context

        let events: [CalendarEvent] = databaseClient.fetch(useCase.scope.predicate, sortDescriptors: useCase.scope.order)

        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events.first, a)
        XCTAssertEqual(events.last, b)
    }
}
