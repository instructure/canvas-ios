//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

class DateExtensionsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        Cal.mockCalendar(Calendar(identifier: .gregorian), timeZone: TimeZone(abbreviation: "MDT")!)
    }

    override func tearDown() {
        Cal.reset()
        super.tearDown()
    }

    func testIsoString() {
        XCTAssertEqual(Date(timeIntervalSince1970: 0).isoString(), "1970-01-01T00:00:00Z")
    }

    func testFromISOString() {
        XCTAssertEqual(Date(fromISOString: "bad wolf"), nil)
        XCTAssertEqual(Date(fromISOString: "1970-01-01T00:00:00Z"), Date(timeIntervalSince1970: 0))
    }

    func testPlusYears() {
        let a = Date(fromISOString: "2019-12-25T14:24:37Z")!
        let b = Date(fromISOString: "2020-12-25T14:24:37Z")!
        let c = Date(fromISOString: "2018-12-25T14:24:37Z")!
        XCTAssertEqual(a.addYears(1), b)
        XCTAssertEqual(a.addYears(-1), c)
    }

    func testPlusMonths() {
        let a = Date(fromISOString: "2019-08-25T14:24:37Z")!
        let b = Date(fromISOString: "2019-09-25T14:24:37Z")!
        let c = Date(fromISOString: "2019-07-25T14:24:37Z")!
        XCTAssertEqual(a.addMonths(1), b)
        XCTAssertEqual(a.addMonths(-1), c)
    }

    func testPlusDays() {
        let a = Date(fromISOString: "2019-12-25T14:24:37Z")!
        let b = Date(fromISOString: "2019-12-26T14:24:37Z")!
        let c = Date(fromISOString: "2019-12-24T14:24:37Z")!
        XCTAssertEqual(a.addDays(1), b)
        XCTAssertEqual(a.addDays(-1), c)
    }

    func testPlusMinutes() {
        let a = Date(fromISOString: "2019-12-25T14:24:37Z")!
        let b = Date(fromISOString: "2019-12-25T14:25:37Z")!
        let c = Date(fromISOString: "2019-12-25T14:23:37Z")!
        XCTAssertEqual(a.addMinutes(1), b)
        XCTAssertEqual(a.addMinutes(-1), c)
    }

    func testStartOfMonth() {
        let a = Date(fromISOString: "2019-12-25T14:24:37Z")!
        let b = Date(fromISOString: "2019-12-01T07:00:00Z")!
        XCTAssertEqual(a.startOfMonth(), b)
    }

    func testEndOfMonth() {
        let a = Date(fromISOString: "2019-12-25T14:24:37Z")!
        let b = Date(fromISOString: "2019-12-31T07:00:00Z")!
        XCTAssertEqual(a.endOfMonth(), b)
    }

    func testStartOfWeek() {
        let a = Date(fromISOString: "2019-12-25T14:24:37Z")!
        let b = Date(fromISOString: "2019-12-22T07:00:00Z")!
        XCTAssertEqual(a.startOfWeek(), b)
    }

    func testEndOfWeek() {
        let a = Date(fromISOString: "2019-12-25T14:24:37Z")!
        let b = Date(fromISOString: "2019-12-29T07:00:00Z")!
        XCTAssertEqual(a.endOfWeek(), b)
    }

    func testRemoveTime() {
        let a = Date(fromISOString: "2020-02-21T06:59:59Z")!
        let b = Date(fromISOString: "2020-02-20T07:00:00Z")!
        XCTAssertEqual(a.removeTime(), b)
    }

    func testUTCToLocal() {
        let utc = Date(fromISOString: "2020-02-21T06:59:59Z")!
        let expectedLocalTime = Date(fromISOString: "2020-02-20T23:59:59Z")!
        XCTAssertEqual(utc.utcToLocal(), expectedLocalTime)
    }

    func testlocalToUTC() {
        let local = Date(fromISOString: "2020-02-20T23:59:59Z")!
        let expectedUTClTime = Date(fromISOString: "2020-02-20T16:59:59Z")!
        XCTAssertEqual(local.utcToLocal(), expectedUTClTime)
    }

    func testAddSeconds() {
        let a = Date(fromISOString: "2020-02-21T06:59:59Z")!
        let b = Date(fromISOString: "2020-02-21T07:00:00Z")!
        let c = Date(fromISOString: "2020-02-21T06:59:58Z")!
        XCTAssertEqual(a.addSeconds(1), b)
        XCTAssertEqual(a.addSeconds(-1), c)
    }

    func testDateMediumString() {
        Clock.mockNow(DateComponents(calendar: .current, timeZone: .current, year: 2019, month: 12, day: 25).date!)
        XCTAssertEqual(DateComponents(calendar: .current, timeZone: .current, year: 2019, month: 1, day: 1).date?.dateMediumString, "Jan 1")
        XCTAssertEqual(DateComponents(calendar: .current, timeZone: .current, year: 2020, month: 12, day: 25).date?.dateMediumString, "Dec 25, 2020")
    }
}
