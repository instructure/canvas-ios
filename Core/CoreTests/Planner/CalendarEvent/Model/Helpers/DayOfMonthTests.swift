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

final class DayOfMonthTests: XCTestCase {
    typealias DayOfWeek = RecurrenceRule.DayOfWeek
    typealias DayOfMonth = EditCustomFrequencyViewModel.DayOfMonth

    func test_title_day() {
        let dayOfMonth = DayOfMonth.day(4)
        let expected = String(localized: "Day %@", bundle: .core)
            .asFormat(for: 4.formatted(.number))
        XCTAssertEqual(dayOfMonth.title, expected)
    }

    func test_title_weekday() {
        let dayOfWeek = DayOfWeek(.sunday, weekNumber: 1)
        let dayOfMonth = DayOfMonth.weekday(dayOfWeek)
        XCTAssertEqual(dayOfMonth.title, dayOfWeek.standaloneText)
    }

    func test_id_day() {
        let dayOfMonth = DayOfMonth.day(2)
        let expectedID = "[day: 2]"
        XCTAssertEqual(dayOfMonth.id, expectedID)
    }

    func test_id_weekday_of_month() {
        let dayOfWeek = DayOfWeek(.sunday, weekNumber: 1)
        let dayOfMonth = DayOfMonth.weekday(dayOfWeek)
        let expectedID = "[weekday: \(Weekday.sunday.dateComponent), weekNumber: 1]"
        XCTAssertEqual(dayOfMonth.id, expectedID)
    }

    func test_id_weekday() {
        let dayOfWeek = DayOfWeek(.sunday)
        let dayOfMonth = DayOfMonth.weekday(dayOfWeek)
        let expectedID = "[weekday: \(Weekday.sunday.dateComponent)]"
        XCTAssertEqual(dayOfMonth.id, expectedID)
    }
}
