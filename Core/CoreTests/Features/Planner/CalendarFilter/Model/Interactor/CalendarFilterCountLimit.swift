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

import Core
import XCTest

class CalendarFilterCountLimitTests: CoreTestCase {

    func test_isCalendarFilterLimitEnabled() {
        var testee: AppEnvironment.App?
        XCTAssertEqual(testee.isCalendarFilterLimitEnabled, false)

        testee = .parent
        XCTAssertEqual(testee.isCalendarFilterLimitEnabled, false)

        testee = .student
        XCTAssertEqual(testee.isCalendarFilterLimitEnabled, false)

        testee = .teacher
        XCTAssertEqual(testee.isCalendarFilterLimitEnabled, true)
    }

    func test_calendarFilterCountLimit_emptyDatabase() {
        var testee: CDEnvironmentSettings?
        XCTAssertEqual(
            testee.calendarFilterCountLimit(isCalendarFilterLimitEnabled: false),
            .unlimited
        )

        XCTAssertEqual(
            testee.calendarFilterCountLimit(isCalendarFilterLimitEnabled: true),
            .base
        )

        testee = databaseClient.insert() as CDEnvironmentSettings
        testee?.calendarContextsLimit = nil
        XCTAssertEqual(
            testee.calendarFilterCountLimit(isCalendarFilterLimitEnabled: false),
            .unlimited
        )

        XCTAssertEqual(
            testee.calendarFilterCountLimit(isCalendarFilterLimitEnabled: true),
            .base
        )
    }

    func test_calendarFilterCountLimit_validDatabase() {
        let testee: CDEnvironmentSettings? = databaseClient.insert() as CDEnvironmentSettings
        testee?.calendarContextsLimit = 6

        XCTAssertEqual(
            testee.calendarFilterCountLimit(isCalendarFilterLimitEnabled: true),
            .extended(6)
        )
    }
}
