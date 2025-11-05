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

class TodoDateRangeEndTests: XCTestCase {

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
        XCTAssertEqual(TodoDateRangeEnd.today.title, "Today")
        XCTAssertEqual(TodoDateRangeEnd.thisWeek.title, "This Week")
        XCTAssertEqual(TodoDateRangeEnd.nextWeek.title, "Next Week")
        XCTAssertEqual(TodoDateRangeEnd.inTwoWeeks.title, "In 2 Weeks")
        XCTAssertEqual(TodoDateRangeEnd.inThreeWeeks.title, "In 3 Weeks")
        XCTAssertEqual(TodoDateRangeEnd.inFourWeeks.title, "In 4 Weeks")
    }

    func testEndDateToday() {
        let result = TodoDateRangeEnd.today.endDate(relativeTo: referenceDate)
        let expected = Date(fromISOString: "2025-01-15T23:59:59Z")!
        XCTAssertEqual(result, expected)
    }

    func testEndDateThisWeek() {
        let result = TodoDateRangeEnd.thisWeek.endDate(relativeTo: referenceDate)
        let expected = Date(fromISOString: "2025-01-18T23:59:59Z")!
        XCTAssertEqual(result, expected)
    }

    func testEndDateNextWeek() {
        let result = TodoDateRangeEnd.nextWeek.endDate(relativeTo: referenceDate)
        let expected = Date(fromISOString: "2025-01-25T23:59:59Z")!
        XCTAssertEqual(result, expected)
    }

    func testEndDateInTwoWeeks() {
        let result = TodoDateRangeEnd.inTwoWeeks.endDate(relativeTo: referenceDate)
        let expected = Date(fromISOString: "2025-02-01T23:59:59Z")!
        XCTAssertEqual(result, expected)
    }

    func testEndDateInThreeWeeks() {
        let result = TodoDateRangeEnd.inThreeWeeks.endDate(relativeTo: referenceDate)
        let expected = Date(fromISOString: "2025-02-08T23:59:59Z")!
        XCTAssertEqual(result, expected)
    }

    func testEndDateInFourWeeks() {
        let result = TodoDateRangeEnd.inFourWeeks.endDate(relativeTo: referenceDate)
        let expected = Date(fromISOString: "2025-02-15T23:59:59Z")!
        XCTAssertEqual(result, expected)
    }

    func testSubtitle() {
        let result = TodoDateRangeEnd.today.subtitle(relativeTo: referenceDate)
        XCTAssertTrue(result.contains("Until"))
        XCTAssertTrue(result.contains("Jan 15"))
    }
}
