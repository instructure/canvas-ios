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
import Core

enum CalendarElements {
    static var todayButton: Element {
        return app.find(labelContaining: "Today")
    }

    static func text(containing text: String) -> Element {
        return app.find(labelContaining: text)
    }

    static var refreshButton: Element {
        return app.find(id: "CalendarMonthViewController.refreshButton")
    }

    static func dayLabel(_ date: Date) -> Element {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return app.find(id: "\(components.year!)-\(components.month!)-\(components.day!)-label")
    }

    static func dayEventIndicator(_ date: Date) -> Element {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return app.find(id: "\(components.year!)-\(components.month!)-\(components.day!)-eventIndicator")
    }
}

class CalendarTests: CoreUITestCase {
    func testCalendarTodayButton() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let monthYear = formatter.string(from: Date()).uppercased()
        formatter.dateFormat = "d"
        let day = formatter.string(from: Date())

        TabBar.calendarTab.tap()
        app.swipeDown()
        app.swipeDown()
        XCTAssertFalse(CalendarElements.text(containing: monthYear).exists)
        CalendarElements.todayButton.tap()
        CalendarElements.text(containing: monthYear).waitToExist()
        CalendarElements.text(containing: day).waitToExist()
    }
}

class MockedCalendarTests: StudentUITestCase {
    func testRefreshCalendarEvents() {
        let jan1 = DateComponents(calendar: .current, timeZone: .current, year: 2019, month: 1, day: 1).date!
        let jan2 = jan1.addDays(1)
        let jan3 = jan2.addDays(1)
        let jan4 = jan3.addDays(1)

        mockNow(jan1)
        mockBaseRequests()
        mockData(GetCoursesRequest(enrollmentState: nil, state: [.available, .completed]), value: [.make(id: "1", is_favorite: true)])
        // course event (moves after refresh)
        mockData(
            GetCalendarEventsRequest(
                contexts: [ContextModel(.course, id: "1")],
                startDate: jan1.addDays(-365),
                endDate: jan1.addDays(365),
                type: .event,
                perPage: 99,
                include: [.submission]
            ),
            value: [.make(id: "1", start_at: jan1, end_at: jan1.addMinutes(30), type: .event, context_code: "course_1")]
        )

        logIn()
        TabBar.calendarTab.tap()
        XCTAssertTrue(CalendarElements.text(containing: "JANUARY 2019").exists)
        XCTAssertTrue(CalendarElements.dayEventIndicator(jan1).waitToExist().isVisible)

        mockData(
            GetCalendarEventsRequest(
                contexts: [ContextModel(.course, id: "1")],
                startDate: jan1.addDays(-365),
                endDate: jan1.addDays(365),
                type: .event,
                perPage: 99,
                include: [.submission]
            ),
            value: [.make(id: "1", start_at: jan4, end_at: jan4.addMinutes(30), type: .event, context_code: "course_1")]
        )

        // course assignment
        mockData(
            GetCalendarEventsRequest(
                contexts: [ContextModel(.course, id: "1")],
                startDate: jan1.addDays(-365),
                endDate: jan1.addDays(365),
                type: .assignment,
                perPage: 99,
                include: [.submission]
            ),
            value: [.make(id: "2", start_at: jan2, end_at: jan2.addMinutes(30), type: .assignment, context_code: "course_1")]
        )

        // user event
        mockData(
            GetCalendarEventsRequest(
                contexts: nil,
                startDate: jan1.addDays(-365),
                endDate: jan1.addDays(365),
                type: .event,
                perPage: 99,
                include: [.submission]
            ),
            value: [.make(id: "3", start_at: jan3, end_at: jan3.addMinutes(30), type: .event, context_code: "course_1")]
        )

        CalendarElements.refreshButton.tap()

        CalendarElements.dayEventIndicator(jan1).waitToVanish()
        XCTAssertTrue(CalendarElements.dayEventIndicator(jan2).waitToExist().isVisible)
        XCTAssertTrue(CalendarElements.dayEventIndicator(jan3).waitToExist().isVisible)
        XCTAssertTrue(CalendarElements.dayEventIndicator(jan4).waitToExist().isVisible)
    }
}
