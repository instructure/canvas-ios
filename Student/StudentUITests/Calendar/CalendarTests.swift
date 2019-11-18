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

class CalendarTests: StudentUITestCase {
    lazy var today = Date(fromISOString: "2007-06-04T12:00:00Z")!
    lazy var tomorrow = today.addDays(1)

    lazy var courseEvent = APICalendarEvent.make(
        id: "1",
        title: "Course Event",
        start_at: jan(1),
        end_at: jan(1).addMinutes(30),
        type: .event,
        context_code: "course_1"
    )
    lazy var assignment = APICalendarEvent.make(
        id: "2",
        title: "Assignment Event",
        start_at: jan(2),
        end_at: jan(2).addMinutes(30),
        type: .assignment,
        context_code: "course_1",
        assignment: .make(id: "22")
    )
    lazy var userEvent = APICalendarEvent.make(
        id: "3",
        title: "User Event",
        start_at: jan(3),
        end_at: jan(3).addMinutes(30),
        type: .event,
        context_code: "user_1"
    )

    lazy var events = [courseEvent, assignment, userEvent]

    func mockRange(_ startDate: Date, _ endDate: Date) {
        mockData(
            GetCalendarEventsRequest(
                contexts: [ContextModel(.course, id: "1")],
                startDate: startDate,
                endDate: endDate,
                type: .event,
                perPage: 99,
                include: [.submission]
            ),
            value: [courseEvent]
        )
        mockData(
            GetCalendarEventsRequest(
                contexts: [ContextModel(.course, id: "1")],
                startDate: startDate,
                endDate: endDate,
                type: .assignment,
                perPage: 99,
                include: [.submission]
            ),
            value: [assignment]
        )
        mockData(
            GetCalendarEventsRequest(
                contexts: nil,
                startDate: startDate,
                endDate: endDate,
                type: .event,
                perPage: 99,
                include: [.submission]
            ),
            value: [userEvent]
        )
    }

    func mockDay(_ days: Date...) {
        for date in days {
            mockRange(date.addDays(-1), date.addDays(1))
        }
    }

    func mockYear(of date: Date) {
        mockRange(date.addDays(-365), date.addDays(365))
    }

    func jan(_ day: Int) -> Date {
        return DateComponents(calendar: .current, timeZone: .current, year: 2019, month: 1, day: day).date!
    }

    override func setUp() {
        super.setUp()
        mockNow(jan(1))
        mockBaseRequests()
        mockData(
            GetCoursesRequest(
                enrollmentState: nil,
                state: [.available, .completed]
            ),
            value: [.make(id: "1", is_favorite: true)]
        )
        mockData(
            GetAssignmentRequest(courseID: "1", assignmentID: assignment.assignment!.id.value, include: [.submission]),
            value: .make(id: assignment.assignment!.id, name: assignment.title)
        )
        mockData(GetCalendarEventRequest(id: "1"), value: courseEvent)
        mockYear(of: jan(1))
        mockDay(jan(1), jan(2), jan(3), jan(4), jan(5))
    }

    func testCalendarTodayButton() {
        logIn()
        TabBar.calendarTab.tap()
        app.swipeDown()
        app.swipeDown()
        XCTAssertFalse(CalendarElements.text(containing: "JANUARY 2019").exists)
        CalendarElements.todayButton.tap()
        CalendarElements.text(containing: "JANUARY 2019").waitToExist()
        CalendarElements.text(containing: "1").waitToExist()
    }

    func testCalendarRefreshAndDayEvents() {
        mockData(
            GetCalendarEventsRequest(
                contexts: [ContextModel(.course, id: "1")],
                startDate: jan(1).addDays(-365),
                endDate: jan(1).addDays(365),
                type: .event,
                perPage: 99,
                include: [.submission]
            ),
            value: [.make(id: "1", start_at: jan(4), end_at: jan(4).addMinutes(30), type: .event, context_code: "course_1")]
        )
        logIn()
        TabBar.calendarTab.tap()
        XCTAssertTrue(CalendarElements.text(containing: "JANUARY 2019").exists)
        XCTAssertTrue(CalendarElements.dayEventIndicator(jan(4)).waitToExist().isVisible)
        mockData(
            GetCalendarEventsRequest(
                contexts: [ContextModel(.course, id: "1")],
                startDate: jan(1).addDays(-365),
                endDate: jan(1).addDays(365),
                type: .event,
                perPage: 99,
                include: [.submission]
            ),
            value: [courseEvent]
        )
        CalendarElements.refreshButton.tap()
        CalendarElements.dayEventIndicator(jan(4)).waitToVanish()
        XCTAssertTrue(CalendarElements.dayEventIndicator(jan(1)).waitToExist().isVisible)
        XCTAssertTrue(CalendarElements.dayEventIndicator(jan(2)).waitToExist().isVisible)
        XCTAssertTrue(CalendarElements.dayEventIndicator(jan(3)).waitToExist().isVisible)
        CalendarElements.dayLabel(jan(1)).tap()
        app.find(labelContaining: courseEvent.title).waitToExist()
        app.find(id: "next_day_button").tap()
        app.find(labelContaining: courseEvent.title).waitToVanish()
        app.find(labelContaining: assignment.title).waitToExist()
        app.swipeLeft()
        app.find(labelContaining: assignment.title).waitToVanish()
        app.find(labelContaining: userEvent.title).waitToExist()
        app.find(id: "prev_day_button").tap()
        app.find(labelContaining: userEvent.title).waitToVanish()
        app.find(labelContaining: assignment.title).waitToExist()
        app.swipeRight()
        app.find(labelContaining: assignment.title).waitToVanish()
        app.find(label: "Wed").tap() // jan(2)
        app.find(labelContaining: assignment.title).tap()
        app.find(labelContaining: "Assignment Details").waitToExist()
        app.find(labelContaining: assignment.title).waitToExist()
        NavBar.backButton.tap()
        app.swipeRight()
        app.find(labelContaining: courseEvent.title).tap()
        app.find(labelContaining: "1/1/19").waitToExist()
        app.find(labelContaining: "12:00").waitToExist()
        app.find(labelContaining: "12:30").waitToExist()
        app.find(labelContaining: "Course Event").waitToExist()
        app.find(labelContaining: courseEvent.title).waitToExist()
        NavBar.backButton.tap()
        app.find(labelContaining: "January 1, 2019").waitToExist()
    }
}
