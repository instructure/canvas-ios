//
//  NSDateTests.swift
//  TooLegit
//
//  Created by Nathan Armstrong on 6/14/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import TooLegit
import SoAutomated
import XCTest
import Marshal

class NSDateTests: UnitTestCase {

    func testMarshalValueType_whenObjectIsNotAString_itThrowsAnError() {
        let notAString = 1
        XCTAssertThrowsError(try NSDate.value(notAString), "it should show an error")
    }

    func testMarshalValueType_whenStringDoesNotConvertToADate_itThrowsAnError() {
        XCTAssertThrowsError(try NSDate.value("no way this is a date"), "it should throw an error")
    }

    func testMarshalValueType_whenStringDoesConvertToADate_itReturnsTheDate() {
        let dateString = "2012-07-01T23:59:00-06:00"
        var date: NSDate!
        attempt {
            date = try NSDate.value(dateString)
        }

        var year = 0
        var month = 0
        var day = 0
        var hour = 0
        var minute = 0
        var second = 0

        // less interested in these
        var era = 0
        var nanosecond = 0

        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        calendar.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        calendar.timeZone = NSTimeZone(forSecondsFromGMT: -(6*60*60))

        calendar.getEra(&era, year: &year, month: &month, day: &day, fromDate: date)
        calendar.getHour(&hour, minute: &minute, second: &second, nanosecond: &nanosecond, fromDate: date)

        XCTAssertEqual(2012, year)
        XCTAssertEqual(7, month)
        XCTAssertEqual(1, day)
        XCTAssertEqual(23, hour)
        XCTAssertEqual(59, minute)
        XCTAssertEqual(0, second)
    }

}
