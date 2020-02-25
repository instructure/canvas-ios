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

class PlannerViewControllerTests: CoreTestCase {
    lazy var controller = PlannerViewController.create(studentID: "1")

    func testLayout() {
        Clock.mockNow(DateComponents(calendar: .current, year: 2020, month: 2, day: 14).date!)
        environment.mockStore = true
        controller.view.layoutIfNeeded()

        XCTAssertGreaterThan(controller.list.tableView.scrollIndicatorInsets.top, 143)
        XCTAssertGreaterThan(controller.list.tableView.contentInset.top, 143)

        XCTAssertEqual(controller.getPlannables(from: Clock.now, to: Clock.now).userID, controller.studentID)

        let selected = DateComponents(calendar: .current, year: 2020, month: 2, day: 22).date!
        controller.calendar.delegate?.calendarDidSelectDate(selected)
        XCTAssertEqual(controller.calendar.selectedDate, selected)
        XCTAssertEqual(controller.list.start, selected)
        XCTAssertEqual(controller.list.end, selected.addDays(1))
        controller.calendar.delegate?.calendarDidSelectDate(Clock.now)
        XCTAssertEqual(controller.calendar.selectedDate, Clock.now)

        let height: CGFloat = 264
        controller.calendar.delegate?.calendarDidResize(height: height, animated: false)
        XCTAssertEqual(controller.list.tableView.scrollIndicatorInsets.top, height)
        XCTAssertEqual(controller.list.tableView.contentInset.top, height)

        let mockTable = MockTableView()
        controller.list.delegate?.scrollViewWillBeginDragging?(mockTable)
        mockTable.contentInset.top = height
        mockTable.contentOffset.y = 200
        controller.list.delegate?.scrollViewDidScroll?(mockTable)
        XCTAssertLessThanOrEqual(mockTable.scrollIndicatorInsets.top, 144)
        XCTAssertLessThanOrEqual(mockTable.contentInset.top, 144)
        mockTable.contentOffset.y = -200
        controller.list.delegate?.scrollViewDidScroll?(mockTable)
        XCTAssertLessThanOrEqual(mockTable.scrollIndicatorInsets.top, 144)
        XCTAssertLessThanOrEqual(mockTable.contentInset.top, 144)
        controller.list.delegate?.scrollViewDidEndDragging?(mockTable, willDecelerate: false)
        XCTAssertEqual(controller.calendar.isExpanded, false)

        controller.studentID = "changed"
        controller.list.delegate?.plannerListWillRefresh()
        XCTAssertEqual(controller.calendar.days.plannables?.useCase.userID, "changed")

        let list = controller.list!
        let dataSource = controller.listPageController.dataSource
        let delegate = controller.listPageController.delegate
        let prev = dataSource?.pageViewController(controller.listPageController, viewControllerBefore: list) as? PlannerListViewController
        XCTAssertEqual(prev?.start, DateComponents(calendar: .current, year: 2020, month: 2, day: 13).date)
        XCTAssertEqual(prev?.end, DateComponents(calendar: .current, year: 2020, month: 2, day: 14).date)
        delegate?.pageViewController?(controller.listPageController, willTransitionTo: [prev!])
        controller.listPageController.setViewControllers([prev!], direction: .reverse, animated: false)
        delegate?.pageViewController?(controller.listPageController, didFinishAnimating: true, previousViewControllers: [list], transitionCompleted: true)
        XCTAssertEqual(controller.calendar.selectedDate, prev?.start)

        let next = dataSource?.pageViewController(controller.listPageController, viewControllerAfter: list) as? PlannerListViewController
        XCTAssertEqual(next?.start, DateComponents(calendar: .current, year: 2020, month: 2, day: 15).date)
        XCTAssertEqual(next?.end, DateComponents(calendar: .current, year: 2020, month: 2, day: 16).date)
        delegate?.pageViewController?(controller.listPageController, willTransitionTo: [next!])
        controller.listPageController.setViewControllers([next!], direction: .reverse, animated: false)
        delegate?.pageViewController?(controller.listPageController, didFinishAnimating: true, previousViewControllers: [list], transitionCompleted: true)
        XCTAssertEqual(controller.calendar.selectedDate, next?.start)
    }

    class MockTableView: UITableView {
        override var isDragging: Bool { true }
    }
}
