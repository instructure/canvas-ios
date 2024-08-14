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

final class CalendarEventRequestModelTests: CoreTestCase {

    func testIsValid() {
        var testee: CalendarEventRequestModel
        let date = Date.make(year: 2020, month: 1, day: 1, hour: 0)

        testee = .make(title: "title", isAllDay: true)
        XCTAssertEqual(testee.isValid, true)

        testee = .make(title: "", isAllDay: true)
        XCTAssertEqual(testee.isValid, false)

        testee = .make(title: "title", isAllDay: false, startTime: date, endTime: date)
        XCTAssertEqual(testee.isValid, true)

        testee = .make(title: "title", isAllDay: false, startTime: date, endTime: date.addMinutes(1))
        XCTAssertEqual(testee.isValid, true)

        testee = .make(title: "title", isAllDay: false, startTime: date.addMinutes(1), endTime: date)
        XCTAssertEqual(testee.isValid, false)

        testee = .make(title: "title", isAllDay: true, startTime: date.addMinutes(1), endTime: date)
        XCTAssertEqual(testee.isValid, true)
    }

    func testProcessedTimes() {
        var testee: CalendarEventRequestModel
        let date = Date.make(year: 1984, month: 1, day: 1, hour: 5)
        let startTime = Date.make(year: 2000, month: 1, day: 1, hour: 11, minute: 15)
        let endTime = Date.make(year: 2000, month: 1, day: 1, hour: 14, minute: 10)

        testee = .make(date: date, isAllDay: true, startTime: startTime, endTime: endTime)
        XCTAssertEqual(testee.processedStartTime, Date.make(year: 1984, month: 1, day: 1))
        XCTAssertEqual(testee.processedEndTime, Date.make(year: 1984, month: 1, day: 1))

        testee = .make(date: date, isAllDay: false, startTime: startTime, endTime: endTime)
        XCTAssertEqual(testee.processedStartTime, Date.make(year: 1984, month: 1, day: 1, hour: 11, minute: 15))
        XCTAssertEqual(testee.processedEndTime, Date.make(year: 1984, month: 1, day: 1, hour: 14, minute: 10))
    }
}
