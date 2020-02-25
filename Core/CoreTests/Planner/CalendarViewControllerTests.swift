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

    var height: CGFloat = 0
    func calendarDidResize(height: CGFloat, animated: Bool) {
        self.height = height
    }

    func getPlannables(from: Date, to: Date) -> GetPlannables {
        return GetPlannables(startDate: from, endDate: to)
    }

    lazy var controller = CalendarViewController.create(delegate: self)

    func testLayout() {
        Clock.mockNow(DateComponents(calendar: .current, year: 2020, month: 1, day: 14).date!)
        environment.mockStore = true
        controller.view.layoutIfNeeded()

        XCTAssertEqual(controller.monthButton.contentEdgeInsets.right, 28)
        XCTAssertEqual(controller.weekdayRow.arrangedSubviews.map { ($0 as? UILabel)?.text }, [
            "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat",
        ])

        XCTAssertEqual(controller.monthButton.accessibilityLabel, "Show a month at a time")
        XCTAssertEqual(controller.monthButton.isSelected, false)
        controller.monthButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.monthButton.isSelected, true)
        XCTAssertGreaterThanOrEqual(height, 883)

        XCTAssertNoThrow(controller.filterButton.sendActions(for: .primaryActionTriggered))
        controller.calendarDidSelectDate(DateComponents(calendar: .current, year: 2020, month: 1, day: 16).date!)
        controller.updateSelectedDate(selectedDate)

        let dataSource = controller.daysPageController.dataSource
        let delegate = controller.daysPageController.delegate
        let prev = dataSource?.pageViewController(controller.daysPageController, viewControllerBefore: controller.days) as? CalendarDaysViewController
        XCTAssertEqual(prev?.fromDate.isoString(), DateComponents(calendar: .current, year: 2019, month: 12, day: 15).date?.isoString())
        XCTAssertEqual(prev?.selectedDate.isoString(), DateComponents(calendar: .current, year: 2019, month: 12, day: 16).date?.isoString())
        delegate?.pageViewController?(controller.daysPageController, willTransitionTo: [prev!])
        delegate?.pageViewController?(controller.daysPageController, didFinishAnimating: true, previousViewControllers: [controller.days], transitionCompleted: true)
        XCTAssertEqual(controller.daysHeight.constant, 264)

        controller.monthButton.sendActions(for: .primaryActionTriggered)
        let next = dataSource?.pageViewController(controller.daysPageController, viewControllerAfter: controller.days) as? CalendarDaysViewController
        XCTAssertEqual(next?.fromDate.isoString(), DateComponents(calendar: .current, year: 2020, month: 1, day: 22).date?.isoString())
        XCTAssertEqual(next?.selectedDate.isoString(), DateComponents(calendar: .current, year: 2020, month: 1, day: 23).date?.isoString())
        delegate?.pageViewController?(controller.daysPageController, willTransitionTo: [next!])
        XCTAssertEqual(controller.daysHeight.constant, 48)
    }
}
