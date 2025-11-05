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

class TodoDateRangeStartTests: XCTestCase {

    private let referenceDate = Date(fromISOString: "2025-01-15T12:00:00Z")!

    override func setUp() {
        super.setUp()
        Cal.mockCalendar(Calendar(identifier: .gregorian), timeZone: TimeZone(abbreviation: "UTC")!)
    }

    override func tearDown() {
        Cal.reset()
        super.tearDown()
    }

    func testTitles() {
        XCTAssertEqual(TodoDateRangeStart.fourWeeksAgo.title, "4 Weeks Ago")
        XCTAssertEqual(TodoDateRangeStart.threeWeeksAgo.title, "3 Weeks Ago")
        XCTAssertEqual(TodoDateRangeStart.twoWeeksAgo.title, "2 Weeks Ago")
        XCTAssertEqual(TodoDateRangeStart.lastWeek.title, "Last Week")
        XCTAssertEqual(TodoDateRangeStart.thisWeek.title, "This Week")
        XCTAssertEqual(TodoDateRangeStart.today.title, "Today")
    }

    func testStartDateToday() {
        let result = TodoDateRangeStart.today.startDate(relativeTo: referenceDate)
        let expected = Date(fromISOString: "2025-01-15T00:00:00Z")!
        XCTAssertEqual(result, expected)
    }

    func testStartDateThisWeek() {
        let result = TodoDateRangeStart.thisWeek.startDate(relativeTo: referenceDate)
        let expected = Date(fromISOString: "2025-01-12T00:00:00Z")!
        XCTAssertEqual(result, expected)
    }

    func testStartDateLastWeek() {
        let result = TodoDateRangeStart.lastWeek.startDate(relativeTo: referenceDate)
        let expected = Date(fromISOString: "2025-01-05T00:00:00Z")!
        XCTAssertEqual(result, expected)
    }

    func testStartDateTwoWeeksAgo() {
        let result = TodoDateRangeStart.twoWeeksAgo.startDate(relativeTo: referenceDate)
        let expected = Date(fromISOString: "2024-12-29T00:00:00Z")!
        XCTAssertEqual(result, expected)
    }

    func testStartDateThreeWeeksAgo() {
        let result = TodoDateRangeStart.threeWeeksAgo.startDate(relativeTo: referenceDate)
        let expected = Date(fromISOString: "2024-12-22T00:00:00Z")!
        XCTAssertEqual(result, expected)
    }

    func testStartDateFourWeeksAgo() {
        let result = TodoDateRangeStart.fourWeeksAgo.startDate(relativeTo: referenceDate)
        let expected = Date(fromISOString: "2024-12-15T00:00:00Z")!
        XCTAssertEqual(result, expected)
    }

    func testSubtitle() {
        let result = TodoDateRangeStart.today.subtitle(relativeTo: referenceDate)
        XCTAssertTrue(result.contains("From"))
        XCTAssertTrue(result.contains("Jan 15"))
    }
}
