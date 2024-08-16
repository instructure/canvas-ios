//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import SwiftUI

class CoreDatePickerTests: CoreTestCase {

    func testRouting() {
        let controller = UIViewController()
        CoreDatePicker.showDatePicker(for: .constant(Clock.now), from: controller)
        XCTAssertTrue(router.presented is CoreHostingController<CoreDatePickerActionSheetCard>)
    }

    func testWeakRouting() {
        let controller = WeakViewController()
        CoreDatePicker.showDatePicker(for: .constant(Clock.now), from: controller)
        XCTAssertTrue(router.presented is CoreHostingController<CoreDatePickerActionSheetCard>)
    }

    func testDateRange() {
        var minDate: Date?
        var maxDate: Date?
        var dateRange: ClosedRange<Date> {
            CoreDatePickerActionSheetCard.dateRange(with: minDate, max: maxDate)
        }
        let now = Clock.now
        Clock.mockNow(now)
        // no date range is set
        XCTAssertEqual(dateRange, now.addYears(-1)...now.addYears(1))
        minDate = now
        // there is a minDate but no maxDate
        XCTAssertEqual(dateRange, now...now.addYears(2))
        maxDate = now.addDays(1)
        // a proper date range is set
        XCTAssertEqual(dateRange, now...now.addDays(1))
        minDate = nil
        // there is a maxDate but no minDate
        XCTAssertEqual(dateRange, now.addDays(1).addYears(-2)...now.addDays(1))
        minDate = now.addDays(1)
        maxDate = now.addDays(-1)
        // maxDate is before minDate (invalid date range)
        XCTAssertEqual(dateRange, now.addYears(-1)...now.addYears(1))

        Clock.reset()
    }
}
