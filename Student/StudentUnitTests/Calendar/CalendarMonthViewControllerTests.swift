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
    func mockRange(_ startDate: Date, _ endDate: Date, courseEvents: [APICalendarEvent], assignments: [APICalendarEvent], userEvents: [APICalendarEvent]) {
        api.mock(
            GetCalendarEventsRequest(
                contexts: [ContextModel(.course, id: "1")],
                startDate: startDate,
                endDate: endDate,
                type: .event,
                perPage: 99,
                include: [.submission]
            ),
            value: courseEvents
        )
        api.mock(
            GetCalendarEventsRequest(
                contexts: [ContextModel(.course, id: "1")],
                startDate: startDate,
                endDate: endDate,
                type: .assignment,
                perPage: 99,
                include: [.submission]
            ),
            value: assignments
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
            value: userEvents
        )
    }

    func testCalendarMonthViewController() {
        let calendar = CalendarMonthViewController.new(Session.current!)
        XCTAssertNotNil(calendar)
    }
}
