//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import TooLegit
import SoAutomated
import XCTest
import Marshal

class NSDateTests: XCTestCase {

    func testMarshalValueType_whenObjectIsNotAString_itThrowsAnError() {
        let notAString = 1
        XCTAssertThrowsError(try Date.value(from: notAString), "it should show an error")
    }

    func testMarshalValueType_whenStringDoesNotConvertToADate_itThrowsAnError() {
        XCTAssertThrowsError(try Date.value(from: "no way this is a date"), "it should throw an error")
    }

    func testMarshalValueType_whenStringDoesConvertToADate_itReturnsTheDate() {
        let dateString = "2012-07-01T23:59:00-06:00"
        var date: Date!
        attempt {
            date = try Date.value(from: dateString)
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

        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = TimeZone(secondsFromGMT: -(6*60*60))!

        (calendar as NSCalendar).getEra(&era, year: &year, month: &month, day: &day, from: date)
        (calendar as NSCalendar).getHour(&hour, minute: &minute, second: &second, nanosecond: &nanosecond, from: date)

        XCTAssertEqual(2012, year)
        XCTAssertEqual(7, month)
        XCTAssertEqual(1, day)
        XCTAssertEqual(23, hour)
        XCTAssertEqual(59, minute)
        XCTAssertEqual(0, second)
    }

}
