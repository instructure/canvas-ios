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

class APICalendarEventTests: XCTestCase {
    var ctx = Context(.course, id: "1")
    let url = URL(string: "https://foo.instructure.com")!
    let mockDate = Date(fromISOString: "2019-12-25T14:24:37Z")!

    override func setUp() {
        super.setUp()
        ctx = Context(.course, id: "1")
        Clock.mockNow(mockDate)
    }

    override func tearDown() {
        Clock.reset()
        super.tearDown()
    }

    func testGetCalendarEvents() {
        let requestable = GetCalendarEventsRequest(
            contexts: [ctx],
            startDate: Clock.now,
            endDate: Clock.now,
            timeZone: .init(identifier: "GMT")!,
            include: [.submission]
        )
        XCTAssertEqual(requestable.path, "calendar_events")
        XCTAssertEqual(requestable.queryItems, [
            URLQueryItem(name: "type", value: "event"),
            URLQueryItem(name: "per_page", value: "100"),
            URLQueryItem(name: "include[]", value: "submission"),
            URLQueryItem(name: "start_date", value: "2019-12-25T14:24:37Z"),
            URLQueryItem(name: "end_date", value: "2019-12-25T14:24:37Z"),
            URLQueryItem(name: "context_codes[]", value: "course_1")
        ])
    }

    func testGetCalendarEventRequest() {
        let request = GetCalendarEventRequest(eventID: "1")
        XCTAssertEqual(request.path, "calendar_events/1")
    }
}
