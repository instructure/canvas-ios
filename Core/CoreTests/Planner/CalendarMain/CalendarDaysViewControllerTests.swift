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
import TestsFoundation

class CalendarDaysViewControllerTests: CoreTestCase, CalendarViewControllerDelegate {
    var selectedDate = Clock.now
    func calendarDidSelectDate(_ date: Date) {
        selectedDate = date
    }
    func calendarDidTransitionToDate(_ date: Date) {
        selectedDate = date
    }

    func calendarDidResize(height: CGFloat, animated: Bool) {}

    func getPlannables(from: Date, to: Date) -> GetPlannables {
        return GetPlannables(startDate: from, endDate: to, contextCodes: ["course_1"])
    }

    func calendarWillFilter() {}

    lazy var controller = CalendarDaysViewController.create(selectedDate: Clock.now, delegate: self)

    func getPlannablesRequest(from: Date, to: Date) -> GetPlannablesRequest {
        GetPlannablesRequest(startDate: from, endDate: to, contextCodes: ["course_1"])
    }

    func testDates() {
        Clock.mockNow(DateComponents(calendar: .current, year: 2020, month: 2, day: 14).date!)
        api.mock(getPlannablesRequest(
            from: DateComponents(calendar: .current, year: 2020, month: 1, day: 26).date!,
            to: DateComponents(calendar: .current, year: 2020, month: 3, day: 1).date!
        ), value: [
            .make(plannable_id: "1", plannable_date: DateComponents(calendar: .current, year: 2020, month: 2, day: 14).date!),
            .make(plannable_id: "2", plannable_date: DateComponents(calendar: .current, year: 2020, month: 2, day: 15).date!),
            .make(plannable_id: "3", plannable_date: DateComponents(calendar: .current, year: 2020, month: 2, day: 15, hour: 12).date!),
            .make(plannable_id: "4", plannable_date: DateComponents(calendar: .current, year: 2020, month: 2, day: 16, hour: 12).date!),
            .make(plannable_id: "5", plannable_date: DateComponents(calendar: .current, year: 2020, month: 2, day: 16, hour: 13).date!),
            .make(plannable_id: "6", plannable_date: DateComponents(calendar: .current, year: 2020, month: 2, day: 16, hour: 23, minute: 59).date!)
        ])
        controller.view.layoutIfNeeded()

        XCTAssertEqual(controller.midDate(isExpanded: true), DateComponents(calendar: .current, year: 2020, month: 2, day: 12).date)
        XCTAssertEqual(controller.midDate(isExpanded: false), DateComponents(calendar: .current, year: 2020, month: 2, day: 12).date)

        XCTAssertFalse(controller.hasDate(DateComponents(calendar: .current, year: 2020, month: 1, day: 25).date!, isExpanded: true))
        XCTAssertTrue(controller.hasDate(DateComponents(calendar: .current, year: 2020, month: 1, day: 26).date!, isExpanded: true))
        XCTAssertTrue(controller.hasDate(DateComponents(calendar: .current, year: 2020, month: 2, day: 29).date!, isExpanded: true))
        XCTAssertFalse(controller.hasDate(DateComponents(calendar: .current, year: 2020, month: 3, day: 1).date!, isExpanded: true))

        XCTAssertFalse(controller.hasDate(DateComponents(calendar: .current, year: 2020, month: 2, day: 8).date!, isExpanded: false))
        XCTAssertTrue(controller.hasDate(DateComponents(calendar: .current, year: 2020, month: 2, day: 9).date!, isExpanded: false))
        XCTAssertTrue(controller.hasDate(DateComponents(calendar: .current, year: 2020, month: 2, day: 15).date!, isExpanded: false))
        XCTAssertFalse(controller.hasDate(DateComponents(calendar: .current, year: 2020, month: 2, day: 16).date!, isExpanded: false))

        let feb13 = controller.weeksStackView.subviews[2].subviews[4] as? CalendarDayButton
        XCTAssertEqual(feb13?.activityDotCount, 0)
        let feb14 = controller.weeksStackView.subviews[2].subviews[5] as? CalendarDayButton
        XCTAssertEqual(feb14?.activityDotCount, 1)
        let feb15 = controller.weeksStackView.subviews[2].subviews[6] as? CalendarDayButton
        XCTAssertEqual(feb15?.activityDotCount, 2)
        let feb16 = controller.weeksStackView.subviews[3].subviews[0] as? CalendarDayButton
        XCTAssertEqual(feb16?.activityDotCount, 3)
        let feb17 = controller.weeksStackView.subviews[3].subviews[1] as? CalendarDayButton
        XCTAssertEqual(feb17?.activityDotCount, 0)

        (controller.weeksStackView.arrangedSubviews.first?.subviews.first as? UIButton)?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(selectedDate, DateComponents(calendar: .current, timeZone: .current, year: 2020, month: 1, day: 26).date)
        controller.updateSelectedDate(selectedDate)
        XCTAssertEqual((controller.weeksStackView.arrangedSubviews.first?.subviews.first as? UIButton)?.isSelected, true)

        Clock.reset()
    }

    func testTodayNotSelected() {
        let date = Date()
        let selectedDate = date.addDays(2)

        let button = CalendarDayButton(date: date, selectedDate: selectedDate, calendar: .current)
        button.activityDotCount = 2

        XCTAssertEqual(button.circleView.backgroundColor, nil)
        XCTAssertEqual(button.label.textColor, button.tintColor)
        XCTAssertEqual(button.dotContainer.isHidden, false)
    }

    func testNotTodayNotSelected() {
        let date = Date().addDays(1)
        let selectedDate = date.addDays(1)

        let button = CalendarDayButton(date: date, selectedDate: selectedDate, calendar: .current)
        button.activityDotCount = 2

        XCTAssertEqual(button.circleView.backgroundColor, nil)
        let isLabelTextDarkOrDarkest = button.label.textColor == .textDark || button.label.textColor == .textDarkest
        XCTAssertEqual(isLabelTextDarkOrDarkest, true)
        XCTAssertEqual(button.dotContainer.isHidden, false)
    }

    func testTodaySelected() {
        let date = Date()
        let selectedDate = date

        let button = CalendarDayButton(date: date, selectedDate: selectedDate, calendar: .current)
        button.activityDotCount = 2

        XCTAssertEqual(button.circleView.backgroundColor, button.tintColor)
        XCTAssertEqual(button.label.textColor, .white)
        XCTAssertEqual(button.dotContainer.isHidden, true)
    }

    func testNotTodaySelected() {
        let date = Date().addDays(1)
        let selectedDate = date

        let button = CalendarDayButton(date: date, selectedDate: selectedDate, calendar: .current)
        button.activityDotCount = 2

        XCTAssertEqual(button.circleView.backgroundColor, button.tintColor)
        XCTAssertEqual(button.label.textColor, .white)
        XCTAssertEqual(button.dotContainer.isHidden, true)
    }
}
