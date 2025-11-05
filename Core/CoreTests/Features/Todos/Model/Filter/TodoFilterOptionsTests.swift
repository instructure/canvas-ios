//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

class TodoFilterOptionsTests: XCTestCase {

    func testDefaultFilterOptions() {
        let defaults = TodoFilterOptions.default
        XCTAssertTrue(defaults.visibilityOptions.isEmpty)
        XCTAssertEqual(defaults.dateRangeStart, .lastWeek)
        XCTAssertEqual(defaults.dateRangeEnd, .nextWeek)
        XCTAssertTrue(defaults.isDefault)
    }

    func testIsDefaultTrue() {
        let options = TodoFilterOptions(
            visibilityOptions: [],
            dateRangeStart: .lastWeek,
            dateRangeEnd: .nextWeek
        )
        XCTAssertTrue(options.isDefault)
    }

    func testIsDefaultFalseWithDifferentVisibility() {
        let options = TodoFilterOptions(
            visibilityOptions: [.showPersonalTodos],
            dateRangeStart: .lastWeek,
            dateRangeEnd: .nextWeek
        )
        XCTAssertFalse(options.isDefault)
    }

    func testIsDefaultFalseWithDifferentDateRange() {
        let options = TodoFilterOptions(
            visibilityOptions: [],
            dateRangeStart: .today,
            dateRangeEnd: .nextWeek
        )
        XCTAssertFalse(options.isDefault)
    }

    func testStartDateProperty() {
        let referenceDate = Date(fromISOString: "2025-01-15T12:00:00Z")!
        Clock.mockNow(referenceDate)

        let options = TodoFilterOptions(
            visibilityOptions: [],
            dateRangeStart: .thisWeek,
            dateRangeEnd: .nextWeek
        )

        let expected = Date(fromISOString: "2025-01-12T00:00:00Z")!
        XCTAssertEqual(options.startDate, expected)

        Clock.reset()
    }

    func testEndDateProperty() {
        let referenceDate = Date(fromISOString: "2025-01-15T12:00:00Z")!
        Clock.mockNow(referenceDate)

        let options = TodoFilterOptions(
            visibilityOptions: [],
            dateRangeStart: .thisWeek,
            dateRangeEnd: .nextWeek
        )

        let expected = Date(fromISOString: "2025-01-25T23:59:59Z")!
        XCTAssertEqual(options.endDate, expected)

        Clock.reset()
    }

    func testVisibilityOptionsSet() {
        let options = TodoFilterOptions(
            visibilityOptions: [.showPersonalTodos, .showCompleted],
            dateRangeStart: .today,
            dateRangeEnd: .today
        )

        XCTAssertEqual(options.visibilityOptions.count, 2)
        XCTAssertTrue(options.visibilityOptions.contains(.showPersonalTodos))
        XCTAssertTrue(options.visibilityOptions.contains(.showCompleted))
        XCTAssertFalse(options.visibilityOptions.contains(.showCalendarEvents))
    }

}
