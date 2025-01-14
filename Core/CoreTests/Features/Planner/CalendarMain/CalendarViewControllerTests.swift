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

class CalendarViewControllerTests: CoreTestCase, CalendarViewControllerDelegate {
    var selectedDate = Clock.now
    func calendarDidSelectDate(_ date: Date) {
        selectedDate = date
    }
    func calendarDidTransitionToDate(_ date: Date) {
        selectedDate = date
    }

    var height: CGFloat = 0
    func calendarDidResize(height: CGFloat, animated: Bool) {
        self.height = height
    }

    func getPlannables(from: Date, to: Date) -> GetPlannables {
        return GetPlannables(startDate: from, endDate: to)
    }

    var willFilter = false
    func calendarWillFilter() {
        willFilter = true
    }
    var calendarCount: Int?

    lazy var controller = CalendarViewController.create(delegate: self)

    func testLayout() {
        Clock.mockNow(DateComponents(calendar: .current, year: 2020, month: 1, day: 14).date!)
        environment.mockStore = true
        controller.view.layoutIfNeeded()

        XCTAssertEqual(controller.monthButton.configuration?.contentInsets.trailing, 32)
        XCTAssertEqual(controller.weekdayRow.arrangedSubviews.map { ($0 as? UILabel)?.text }, [
            "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"
        ])

        XCTAssertEqual(controller.monthButton.accessibilityLabel, "Show a month at a time")
        XCTAssertEqual(controller.monthButton.isSelected, false)
        let deselectedHeight = height
        controller.monthButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.monthButton.isSelected, true)
        XCTAssertEqual(height > deselectedHeight, true)

        XCTAssertEqual(controller.filterButton.accessibilityLabel, "Filter events by Calendars")
        XCTAssertEqual(controller.filterButton.title(for: .normal), "Calendars")
        controller.filterButton.sendActions(for: .primaryActionTriggered)
        XCTAssertTrue(willFilter)
        calendarCount = 1
        controller.refresh()
        XCTAssertEqual(controller.filterButton.accessibilityLabel, "Filter events by Calendars")
        XCTAssertEqual(controller.filterButton.title(for: .normal), "Calendars")
        calendarCount = 7
        controller.refresh()
        XCTAssertEqual(controller.filterButton.accessibilityLabel, "Filter events by Calendars")
        XCTAssertEqual(controller.filterButton.title(for: .normal), "Calendars")

        controller.calendarDidSelectDate(DateComponents(calendar: .current, year: 2020, month: 1, day: 16).date!)
        controller.updateSelectedDate(selectedDate)

        let dataSource = controller.daysPageController.dataSource
        let delegate = controller.daysPageController.delegate
        let expandedDaysHeight = controller.daysHeight.constant
        let prev = dataSource?.pagesViewController(controller.daysPageController, pageBefore: controller.days) as? CalendarDaysViewController
        XCTAssertEqual(prev?.selectedDate.isoString(), DateComponents(calendar: .current, year: 2019, month: 12, day: 16).date?.isoString())
        delegate?.pagesViewController?(controller.daysPageController, isShowing: [ prev!, controller.days ])
        delegate?.pagesViewController?(controller.daysPageController, didTransitionTo: controller.days)
        XCTAssertEqual(controller.daysHeight.constant, expandedDaysHeight)

        controller.monthButton.sendActions(for: .primaryActionTriggered)
        let next = dataSource?.pagesViewController(controller.daysPageController, pageAfter: controller.days) as? CalendarDaysViewController
        XCTAssertEqual(next?.selectedDate.isoString(), DateComponents(calendar: .current, year: 2020, month: 1, day: 23).date?.isoString())
        delegate?.pagesViewController?(controller.daysPageController, isShowing: [ controller.days, next! ])
        XCTAssertEqual(controller.daysHeight.constant < expandedDaysHeight, true)

        controller.showDate(DateComponents(calendar: .current, year: 2020, month: 2, day: 1).date!)

        //  wait for set month animation
        RunLoop.current.run(until: Date() + 0.5)

        XCTAssertEqual(controller.monthButton.title(for: .normal), "February")
        XCTAssertEqual(controller.yearLabel.text, "2020")
        XCTAssertEqual(controller.days.selectedDate.isoString(), DateComponents(calendar: .current, year: 2020, month: 2, day: 1).date!.isoString())

        Clock.reset()
    }
}
