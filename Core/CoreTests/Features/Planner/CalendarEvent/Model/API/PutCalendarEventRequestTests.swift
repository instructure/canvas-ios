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

final class PutCalendarEventRequestTests: XCTestCase {

    func testProperties() {
        let testee = PutCalendarEventRequest(id: "42", body: .make())

        XCTAssertEqual(testee.method, .put)
        XCTAssertEqual(testee.path, "calendar_events/42")
    }

    func testDecodingSingleEvent() throws {
        let testee = PutCalendarEventRequest(id: "", body: .make())
        let event = APICalendarEvent.make(id: "id 1", created_at: Date(fromISOString: "2018-05-18T06:00:00Z")!, updated_at: Date(fromISOString: "2018-05-18T06:00:00Z")!)
        let data = try APIJSONEncoder().encode(event)

        let response = try testee.decode(data)
        XCTAssertEqual(response, [event])
    }

    func testDecodingSingleEventInArray() throws {
        let testee = PutCalendarEventRequest(id: "", body: .make())
        let event = APICalendarEvent.make(id: "id 1")
        let data = try APIJSONEncoder().encode([event])

        let response = try testee.decode(data)
        XCTAssertEqual(response, [event])
    }

    func testDecodingEventArray() throws {
        let testee = PutCalendarEventRequest(id: "", body: .make())
        let event1 = APICalendarEvent.make(id: "id 1")
        let event2 = APICalendarEvent.make(id: "id 2")
        let data = try APIJSONEncoder().encode([event1, event2])

        let response = try testee.decode(data)
        XCTAssertEqual(response, [event1, event2])
    }
}
