//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class K5ScheduleViewModelTests: CoreTestCase {

    func testWeekRangeCalculation() {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let testee = K5ScheduleViewModel(currentDate: Date(fromISOString: "2021-12-31T12:00:00+00:00")!, calendar: calendar)

        XCTAssertEqual(testee.weekModels.count, 53)
        XCTAssertEqual(testee.weekModels[25].weekRange, Date(fromISOString: "2021-12-20T00:00:00+00:00")!..<Date(fromISOString: "2021-12-27T00:00:00+00:00")!)
        // current week is in the middle
        XCTAssertEqual(testee.weekModels[testee.defaultWeekIndex].weekRange, Date(fromISOString: "2021-12-27T00:00:00+00:00")!..<Date(fromISOString: "2022-01-03T00:00:00+00:00")!)
        XCTAssertEqual(testee.weekModels[27].weekRange, Date(fromISOString: "2022-01-03T00:00:00+00:00")!..<Date(fromISOString: "2022-01-10T00:00:00+00:00")!)
    }

    func testTodayButtonVisibility() {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let currentDate = Date(fromISOString: "2021-12-31T12:00:00+00:00")!
        let testee = K5ScheduleViewModel(currentDate: currentDate, calendar: calendar)
        let currentWeekRange = Date(fromISOString: "2021-12-27T00:00:00+00:00")!..<Date(fromISOString: "2022-01-03T00:00:00+00:00")!

        for weekModel in testee.weekModels {
            let isCurrentWeek = (weekModel.weekRange == currentWeekRange)
            XCTAssertEqual(weekModel.isTodayButtonAvailable, isCurrentWeek)
        }
    }
}
