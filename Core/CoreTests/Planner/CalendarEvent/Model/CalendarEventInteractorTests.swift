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

@testable import Core
import XCTest

class CalendarEventInteractorTests: CoreTestCase {

    func testLoadsEventData() {
        let mockAPIEvent: APICalendarEvent = .make(id: "testEventID")
        let mockAPIColor = "#FF0000"
        api.mock(GetCustomColorsRequest(),
                 value: .init(custom_colors: [mockAPIEvent.context_code: mockAPIColor]))
        api.mock(GetCalendarEventRequest(eventID: mockAPIEvent.id.rawValue),
                 value: mockAPIEvent)

        let testee = CalendarEventInteractorLive()

        XCTAssertFirstValueAndCompletion(testee.getCalendarEvent(id: mockAPIEvent.id.rawValue)) { (event, color) in
            XCTAssertEqual(color, UIColor(hexString: mockAPIColor))
            XCTAssertEqual(event.id, mockAPIEvent.id.rawValue)
        }
    }

    func testLoadFailsIfEventNotReceived() {
        let mockAPIEvent: APICalendarEvent = .make(id: "testEventID")
        let mockAPIColor = "#FF0000"
        api.mock(GetCustomColorsRequest(),
                 value: .init(custom_colors: [mockAPIEvent.context_code: mockAPIColor]))
        api.mock(GetCalendarEventRequest(eventID: mockAPIEvent.id.rawValue),
                 value: nil)

        let testee = CalendarEventInteractorLive()

        XCTAssertFailure(testee.getCalendarEvent(id: mockAPIEvent.id.rawValue))
    }

    func testLoadsEventIfColorAPIFails() {
        let mockAPIEvent: APICalendarEvent = .make(id: "testEventID")
        api.mock(GetCustomColorsRequest(),
                 error: NSError.internalError())
        api.mock(GetCalendarEventRequest(eventID: mockAPIEvent.id.rawValue),
                 value: mockAPIEvent)

        let testee = CalendarEventInteractorLive()

        XCTAssertFirstValueAndCompletion(testee.getCalendarEvent(id: mockAPIEvent.id.rawValue)) { (event, color) in
            XCTAssertEqual(color, UIColor.ash)
            XCTAssertEqual(event.id, mockAPIEvent.id.rawValue)
        }
    }
}
