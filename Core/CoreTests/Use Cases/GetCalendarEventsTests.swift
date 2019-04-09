//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import XCTest
@testable import Core
import TestsFoundation

class GetCalendarEventsTests: CoreTestCase {

    var ctx = ContextModel(.course, id: "1")
    var useCase: GetCalendarEvents!

    override func setUp() {
        super.setUp()

        ctx = ContextModel(.course, id: "1")
        useCase = GetCalendarEvents(context: ctx)
    }

    func testItCreatesCalendarEvents() {
        let event = APICalendarEvent.make(["id": "1", "context_code": "course_1"])
        try! useCase.write(response: [event], urlResponse: nil, to: databaseClient)

        let events: [CalendarEventItem] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.id, "1")
        XCTAssertEqual(events.first?.title, "calendar event #1")
        XCTAssertEqual(events.first?.context.canvasContextID, ctx.canvasContextID)
    }

    func testCache() {
        XCTAssertEqual("get-calendar-events", useCase.cacheKey)
    }

    func testScopePredicate() {
        let b = CalendarEventItem.make(["id": "2", "title": "b"])
        let a = CalendarEventItem.make(["id": "1", "title": "a"])
        CalendarEventItem.make(["id": "3", "title": "c", "contextRaw": "course_2"]) // should not show up b/c of context

        let events: [CalendarEventItem] = databaseClient.fetch(predicate: useCase.scope.predicate, sortDescriptors: useCase.scope.order)

        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events.first, a)
        XCTAssertEqual(events.last, b)
    }
}
