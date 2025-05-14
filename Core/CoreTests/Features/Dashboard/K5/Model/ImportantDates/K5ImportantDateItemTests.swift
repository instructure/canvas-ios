//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import SwiftUI
@testable import Core

class K5ImportantDateItemTests: CoreTestCase {

    var calendarEvents: [CalendarEvent]!
    var importantDate: K5ImportantDate!

    override func setUp() {
        super.setUp()
        let assignment = APICalendarEvent.make(
            id: "1",
            html_url: URL(string: "https://canvas.instructure.com/assignments/1")!,
            title: "Important assignment title",
            start_at: Date(fromISOString: "2022-01-03T08:00:00Z"),
            type: .assignment,
            context_name: "Test subject name"
        )
        let event = APICalendarEvent.make(
            id: "2",
            html_url: URL(string: "https://canvas.instructure.com/events/2")!,
            title: "Important event title",
            start_at: Date(fromISOString: "2022-01-03T09:00:00Z"),
            type: .event,
            context_name: "Test event name"
        )
        calendarEvents = [.make(from: assignment, in: databaseClient),
                          .make(from: event, in: databaseClient) ]
        importantDate = K5ImportantDate(with: calendarEvents[0], color: .red)
    }

    func testImportantDate() {
        XCTAssertEqual(importantDate.title, "Monday, January 3")
        XCTAssertEqual(importantDate.events.count, 1)
        guard let event = importantDate.events.first else {
            XCTFail("Important Date events are not populated")
            return
        }
        XCTAssertEqual(event.subject, "Test subject name")
        XCTAssertEqual(event.route, URL(string: "https://canvas.instructure.com/assignments/1"))
        XCTAssertEqual(event.color, .red)
        XCTAssertEqual(event.date, Date(fromISOString: "2022-01-03T08:00:00Z"))
        XCTAssertEqual(event.iconImage, Image.assignmentLine)
        XCTAssertEqual(event.type, .assignment)
        XCTAssertEqual(event.title, "Important assignment title")
    }

    func testAddEvent() {
        importantDate.addEvent(calendarEvents[1], color: .green)
        XCTAssertEqual(importantDate.events.count, 2)
        let event = Array(importantDate.events)[1]
        XCTAssertEqual(event.subject, "Test event name")
        XCTAssertEqual(event.route, URL(string: "https://canvas.instructure.com/events/2"))
        XCTAssertEqual(event.color, .green)
        XCTAssertEqual(event.date, Date(fromISOString: "2022-01-03T09:00:00Z"))
        XCTAssertEqual(event.iconImage, Image.announcementLine)
        XCTAssertEqual(event.type, .event)
        XCTAssertEqual(event.title, "Important event title")
    }
}
