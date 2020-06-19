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
        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        XCTAssertEqual(nav.navigationBar.barTintColor, Brand.shared.navBackground)

        _ = controller.profileButton.target?.perform(controller.profileButton.action)
        XCTAssert(router.lastRoutedTo("/profile", withOptions: .modal()))

        _ = controller.addNoteButton.target?.perform(controller.addNoteButton.action)
        XCTAssert(router.presented is CreateTodoViewController)

        XCTAssertGreaterThan(controller.list.tableView.scrollIndicatorInsets.top, 143)
        XCTAssertGreaterThan(controller.list.tableView.contentInset.top, 143)

        XCTAssertEqual(controller.getPlannables(from: Clock.now, to: Clock.now).userID, controller.studentID)

        let selected = DateComponents(calendar: .current, year: 2020, month: 2, day: 22).date!
        controller.calendar.delegate?.calendarDidSelectDate(selected)
        XCTAssertEqual(controller.calendar.selectedDate, selected)
        XCTAssertEqual(controller.list.start, selected)
        XCTAssertEqual(controller.list.end, selected.addDays(1))
        controller.calendar.delegate?.calendarDidTransitionToDate(selected.addMonths(1))
        let transitionTo = selected.addMonths(1)
        XCTAssertEqual(controller.list.start, transitionTo)
        XCTAssertEqual(controller.list.end, transitionTo.addDays(1))
        XCTAssertEqual(controller.calendar.selectedDate, transitionTo)
        controller.calendar.delegate?.calendarDidSelectDate(Clock.now)
        XCTAssertEqual(controller.calendar.selectedDate, Clock.now)

        // hide first calendar
        api.mock(GetCoursesRequest(enrollmentState: .active, state: [.available], include: [.observed_users], perPage: 100, studentID: "1"), value: [
            .make(id: "1", name: "BIO 101", enrollments: [.make(associated_user_id: "1")]),
            .make(id: "2", name: "BIO 102", enrollments: [.make(associated_user_id: "1")]),
        ])
        XCTAssertNil(controller.list.plannables?.useCase.contextCodes) // planner nil
        XCTAssertEqual(controller.calendar.filterButton.title(for: .normal), "Calendars")
        controller.calendar.delegate?.calendarWillFilter()
        var filter = router.presented as! PlannerFilterViewController
        filter.view.layoutIfNeeded()
        filter.tableView.delegate?.tableView?(filter.tableView!, didSelectRowAt: IndexPath(row: 0, section: 0))
        router.dismiss()
        XCTAssertEqual(controller.calendar.filterButton.title(for: .normal), "Calendars (1)")
        XCTAssert(controller.calendar.days.plannables?.useCase.contextCodes!.contains("course_2") == true)
        XCTAssert(controller.list.plannables?.useCase.contextCodes!.contains("course_2") == true)
        XCTAssert(controller.calendar.days.plannables?.useCase.contextCodes!.contains("user_1") == true)
        XCTAssert(controller.list.plannables?.useCase.contextCodes!.contains("user_1") == true)

        // select all calendars
        controller.calendar.filterButton.sendActions(for: .primaryActionTriggered)
        filter = router.presented as! PlannerFilterViewController
        filter.view.layoutIfNeeded()
        filter.tableView.delegate?.tableView?(filter.tableView!, didSelectRowAt: IndexPath(row: 0, section: 0))
        router.dismiss()
        XCTAssertNil(controller.list.plannables?.useCase.contextCodes) // all selected

        let height: CGFloat = controller.calendar.maxHeight
        controller.calendar.delegate?.calendarDidResize(height: height, animated: false)
        XCTAssertEqual(controller.list.tableView.scrollIndicatorInsets.top, height)
        XCTAssertEqual(controller.list.tableView.contentInset.top, height)

        controller.calendar.setExpanded(true)
        let mockTable = MockTableView()
        mockTable.contentInset.top = controller.calendar.height
        mockTable.contentOffset.y = 0
        controller.list.delegate?.scrollViewWillBeginDragging?(mockTable)
        mockTable.contentOffset.y = 500 // push to collapse
        controller.list.delegate?.scrollViewDidScroll?(mockTable)
        XCTAssertEqual(controller.calendar.height, controller.calendar.minHeight)
        mockTable.contentOffset.y = -500 // reverse to pull back open
        controller.list.delegate?.scrollViewDidScroll?(mockTable)
        XCTAssertEqual(controller.calendar.height, controller.calendar.maxHeight)
        controller.list.delegate?.scrollViewDidEndDragging?(mockTable, willDecelerate: false)
        XCTAssertEqual(controller.calendar.isExpanded, true)

        controller.calendar.setExpanded(false)
        mockTable.contentInset.top = controller.calendar.height
        controller.list.delegate?.scrollViewWillBeginDragging?(mockTable)
        mockTable.contentOffset.y = -500 // pull should not open if starting at collapsed
        controller.list.delegate?.scrollViewDidScroll?(mockTable)
        XCTAssertEqual(controller.calendar.height, controller.calendar.minHeight)
        controller.list.delegate?.scrollViewDidEndDragging?(mockTable, willDecelerate: false)
        XCTAssertEqual(controller.calendar.isExpanded, false)

        controller.studentID = "changed"
        controller.list.delegate?.plannerListWillRefresh()
        XCTAssertEqual(controller.calendar.days.plannables?.useCase.userID, "changed")

        let list = controller.list!
        let dataSource = controller.listPageController.dataSource
        let delegate = controller.listPageController.delegate
        let prev = dataSource?.pagesViewController(controller.listPageController, pageBefore: list) as? PlannerListViewController
        XCTAssertEqual(prev?.start, DateComponents(calendar: .current, year: 2020, month: 2, day: 13).date)
        XCTAssertEqual(prev?.end, DateComponents(calendar: .current, year: 2020, month: 2, day: 14).date)
        delegate?.pagesViewController?(controller.listPageController, isShowing: [ prev!, list ])
        controller.listPageController.setCurrentPage(prev!)
        delegate?.pagesViewController?(controller.listPageController, didTransitionTo: prev!)
        XCTAssertEqual(controller.calendar.selectedDate, prev?.start)

        let next = dataSource?.pagesViewController(controller.listPageController, pageAfter: list) as? PlannerListViewController
        XCTAssertEqual(next?.start, DateComponents(calendar: .current, year: 2020, month: 2, day: 15).date)
        XCTAssertEqual(next?.end, DateComponents(calendar: .current, year: 2020, month: 2, day: 16).date)
        delegate?.pagesViewController?(controller.listPageController, isShowing: [ list, next! ])
        controller.listPageController.setCurrentPage(next!)
        delegate?.pagesViewController?(controller.listPageController, didTransitionTo: next!)
        XCTAssertEqual(controller.calendar.selectedDate, next?.start)

        _ = controller.todayButton.target?.perform(controller.todayButton.action)
        XCTAssertEqual(controller.calendar.selectedDate, Clock.now.startOfDay())
        XCTAssertEqual(controller.list.start, Clock.now.startOfDay())
    }

    class MockTableView: UITableView {
        override var isDragging: Bool { true }
    }
}
