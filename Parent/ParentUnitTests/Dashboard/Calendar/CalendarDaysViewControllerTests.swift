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
@testable import Parent
import TestsFoundation

class CalendarDaysViewControllerTests: ParentTestCase, CalendarDaysDelegate {
    lazy var selectedDate = Clock.now
    var isExpanded = false

    lazy var controller = CalendarDaysViewController.create(anchorDate: Clock.now, delegate: self)

    func testDates() {
        Clock.mockNow(DateComponents(calendar: .current, timeZone: .current, year: 2020, month: 2, day: 14).date!)
        controller.view.layoutIfNeeded()

        XCTAssertEqual(controller.firstDate(isExpanded: true), DateComponents(calendar: .current, timeZone: .current, year: 2020, month: 1, day: 26).date)
        XCTAssertEqual(controller.firstDate(isExpanded: false), DateComponents(calendar: .current, timeZone: .current, year: 2020, month: 2, day: 9).date)

        XCTAssertEqual(controller.monthDate(isExpanded: true), DateComponents(calendar: .current, timeZone: .current, year: 2020, month: 2, day: 12).date)
        XCTAssertEqual(controller.monthDate(isExpanded: false), DateComponents(calendar: .current, timeZone: .current, year: 2020, month: 2, day: 12).date)

        XCTAssertEqual(controller.lastDate(isExpanded: true), DateComponents(calendar: .current, timeZone: .current, year: 2020, month: 2, day: 29).date)
        XCTAssertEqual(controller.lastDate(isExpanded: false), DateComponents(calendar: .current, timeZone: .current, year: 2020, month: 2, day: 15).date)

        (controller.weeksStackView.arrangedSubviews.first?.subviews.first as? UIButton)?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(selectedDate, controller.firstDate(isExpanded: isExpanded))
        XCTAssertEqual((controller.weeksStackView.arrangedSubviews.first?.subviews.first as? UIButton)?.isSelected, true)
    }

    func testToday() {
        let button = CalendarDayButton(date: Date(), selectedDate: Date(), calendar: .current)
        XCTAssertEqual(button.circleView.backgroundColor?.hexString, button.tintColor.hexString)
        XCTAssertEqual(button.label.textColor, .named(.white))
    }
}
