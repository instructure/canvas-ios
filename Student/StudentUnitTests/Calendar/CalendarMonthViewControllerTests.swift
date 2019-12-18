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
import TestsFoundation
@testable import Student
@testable import CanvasCore
@testable import Core

class CalendarMonthViewControllerTests: StudentTestCase {
    lazy var calendar: CalendarMonthViewController = CalendarMonthViewController.new(Session.current!)
    lazy var collectionView: UICollectionView = calendar.calendarView.collectionView!

    var contexts: [Context]?
    var courseEvents: [APICalendarEvent] = []
    var assignments: [APICalendarEvent] = []
    var userEvents: [APICalendarEvent] = []

    func testDayCellA11yValues() {
        let now = jan(1, 2019)
        userEvents = [
            .make(
                id: "1",
                title: "Event 1",
                start_at: jan(1, 2018),
                end_at: jan(1, 2018).addMinutes(30),
                type: .event,
                context_code: "user_1"
            ),
            .make(
                id: "2",
                title: "Event 2",
                start_at: jan(1, 2018),
                end_at: jan(1, 2018).addMinutes(30),
                type: .event,
                context_code: "user_1"
            ),
            .make(
                id: "3",
                title: "Event 3",
                start_at: jan(2, 2018),
                end_at: jan(2, 2018).addMinutes(30),
                type: .event,
                context_code: "user_1"
            ),
        ]
        Clock.mockNow(now)
        mockRange(now.addDays(-365), now.addDays(365))
        calendar.view.layoutIfNeeded()
        let jan1 = dayCell(at: IndexPath(item: 1, section: 0))
        let jan2 = dayCell(at: IndexPath(item: 2, section: 0))
        let jan3 = dayCell(at: IndexPath(item: 3, section: 0))
        XCTAssertEqual(jan1.dateLabel.accessibilityLabel, "1st")
        XCTAssertEqual(jan1.dateLabel.accessibilityValue, "2 events")
        XCTAssertEqual(jan2.dateLabel.accessibilityLabel, "2nd")
        XCTAssertEqual(jan2.dateLabel.accessibilityValue, "1 event")
        XCTAssertEqual(jan3.dateLabel.accessibilityLabel, "3rd")
        XCTAssertNil(jan3.dateLabel.accessibilityValue)
    }

    // MARK: - Helpers

    func jan(_ day: Int, _ year: Int) -> Date {
        return DateComponents(calendar: .current, timeZone: .current, year: year, month: 1, day: day).date!
    }

    func dayCell(at indexPath: IndexPath) -> CalendarDayCell {
        return collectionView.dataSource!.collectionView(collectionView, cellForItemAt: indexPath) as! CalendarDayCell
    }

    func mockRange(_ startDate: Date, _ endDate: Date) {
        api.mock(
            GetCalendarEventsRequest(
                contexts: contexts,
                startDate: startDate,
                endDate: endDate,
                type: .event,
                perPage: 99,
                include: [.submission]
            ),
            value: courseEvents,
            response: .httpSuccess
        )
        api.mock(
            GetCalendarEventsRequest(
                contexts: contexts,
                startDate: startDate,
                endDate: endDate,
                type: .assignment,
                perPage: 99,
                include: [.submission]
            ),
            value: assignments,
            response: .httpSuccess
        )
        api.mock(
            GetCalendarEventsRequest(
                contexts: nil,
                startDate: startDate,
                endDate: endDate,
                type: .event,
                perPage: 99,
                include: [.submission]
            ),
            value: userEvents,
            response: .httpSuccess
        )
    }
}
