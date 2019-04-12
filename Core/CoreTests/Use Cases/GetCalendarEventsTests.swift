//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
