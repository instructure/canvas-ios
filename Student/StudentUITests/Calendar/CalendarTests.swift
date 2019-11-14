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
import TestsFoundation
@testable import CoreUITests
@testable import Core

enum CalendarElements {
    static var todayButton: Element {
        return app.find(labelContaining: "Today")
    }

    static func text(containing text: String) -> Element {
        return app.find(labelContaining: text)
    }
}

class CalendarTests: StudentUITestCase {
    lazy var today = Date(fromISOString: "2007-06-04T12:00:00Z")!
    lazy var tomorrow = today.addDays(1)

    lazy var event1: APICalendarEvent = APICalendarEvent.make(start_at: today, end_at: today)
    lazy var event2: APICalendarEvent = APICalendarEvent.make(id: "2", title: "event 2", start_at: tomorrow, end_at: tomorrow)

    override func setUp() {
        super.setUp()
        mockNow(today)

        let mockRanges = [
            ("2006-06-04T12:00:00Z", "2008-06-03T12:00:00Z"),
            ("2007-06-03T06:00:00Z", "2007-06-05T06:00:00Z"),
            ("2007-06-04T06:00:00Z", "2007-06-06T06:00:00Z"),
            ("2007-06-05T06:00:00Z", "2007-06-07T06:00:00Z"),
            ("2007-06-06T06:00:00Z", "2007-06-08T06:00:00Z"),
        ]
        for (start, end) in mockRanges {
            mockEncodableRequest("calendar_events?context_codes[]=course_1&end_date=\(end)&include[]=submission" +
                "&per_page=99&start_date=\(start)&type=event", value: [event1, event2])
            mockEncodableRequest("calendar_events?context_codes[]=course_1&end_date=\(end)&include[]=submission" +
                "&per_page=99&start_date=\(start)&type=assignment", value: [String]())
            mockEncodableRequest("calendar_events?end_date=\(end)&include[]=submission" +
                "&per_page=99&start_date=\(start)&type=event", value: [String]())
        }
        mockEncodableRequest("calendar_events/1?per_page=99", value: event1)
        mockEncodableRequest("calendar_events/2?per_page=99", value: event2)
    }

    func testCalendarTodayButton() {
        mockBaseRequests()
        mockNow(today)
        logIn()

        let monthYear = "JUNE 2007"
        let day = "4"

        TabBar.calendarTab.tap()
        app.swipeDown()
        app.swipeDown()
        XCTAssertFalse(CalendarElements.text(containing: monthYear).exists)
        CalendarElements.todayButton.tap()
        CalendarElements.text(containing: monthYear).waitToExist()
        CalendarElements.text(containing: day).waitToExist()
    }

    func testCalendarDayEvents() {
        mockBaseRequests()
        mockNow(today)
        logIn()
        TabBar.calendarTab.tap()
        app.find(label: "4th").tap()

        app.find(labelContaining: event1.title).waitToExist()
        app.find(labelContaining: "Course One").waitToExist()

        app.find(id: "next_day_button").tap()
        app.find(labelContaining: event1.title).waitToVanish()
        app.find(labelContaining: event2.title).waitToExist()

        app.find(id: "prev_day_button").tap()
        app.find(labelContaining: event2.title).waitToVanish()
        app.find(labelContaining: event1.title).waitToExist()

        app.find(id: "prev_day_button").tap()
        app.find(labelContaining: event1.title).waitToVanish()
        app.find(labelContaining: event2.title).waitToVanish()

        app.find(label: "Tue").tap()
        app.find(labelContaining: event2.title).waitToExist()

        CalendarElements.todayButton.tap()
        app.find(labelContaining: event1.title).waitToExist()

        app.swipeLeft()
        app.find(labelContaining: event2.title).waitToExist()

        app.find(labelContaining: event2.title).tap()
        app.find(label: "6/5/07, 6:00 AM").waitToExist()
        app.find(label: "Calendar Event").waitToExist()
        app.find(labelContaining: event2.title).waitToExist()
        app.find(labelContaining: "Course One").waitToExist()

        NavBar.backButton.tap()
        app.find(label: "June 5, 2007").waitToExist()
    }
}
