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

class PlannerListViewControllerTests: CoreTestCase, PlannerListDelegate {
    func getPlannables(from: Date, to: Date) -> GetPlannables {
        return GetPlannables(startDate: from, endDate: to)
    }

    var willRefresh = false
    func plannerListWillRefresh() {
        willRefresh = true
    }

    var isDragging = false
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDragging = true
    }
    var didScroll = false
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScroll = true
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isDragging = false
    }

    var start = Clock.now.startOfDay()
    var end = Clock.now.startOfDay().addDays(1)
    lazy var controller = PlannerListViewController.create(start: start, end: end, delegate: self)

    override func setUp() {
        super.setUp()
        environment.mockStore = false
    }

    func testLayout() {
        let date = Clock.now
        let assignment = APIPlannable.make(plannable_date: date)
        api.mock(getPlannables(from: start, to: end), value: [assignment])
        controller.view.layoutIfNeeded()

        XCTAssertEqual(controller.emptyStateViewContainer.isHidden, true)
        XCTAssertEqual(controller.spinnerView.isHidden, true)
        XCTAssertEqual(controller.tableView.refreshControl?.isRefreshing, false)
        let index0 = IndexPath(row: 0, section: 0)
        let cell = controller.tableView.cellForRow(at: index0) as? PlannerListCell
        XCTAssertEqual(cell?.title.text, "assignment a")
        XCTAssertEqual(cell?.courseCode.text, "Assignment Grades")
        XCTAssertEqual(cell?.dueDate.text, DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short) )
        XCTAssertEqual(cell?.points.text, nil)

        controller.tableView.selectRow(at: index0, animated: false, scrollPosition: .none)
        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: index0)
        XCTAssertTrue(router.lastRoutedTo(assignment.html_url!.rawValue))
        controller.viewWillAppear(false)
        XCTAssertNil(controller.tableView.indexPathForSelectedRow)

        controller.tableView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertTrue(willRefresh)
    }

    func testEmptyState() {
        api.mock(getPlannables(from: start, to: end), value: [])
        controller.view.layoutIfNeeded()

        controller.emptyStateViewContainer.isHidden = false
        XCTAssertEqual(controller.emptyStateHeader.text, "No Assignments")
        XCTAssertEqual(controller.emptyStateSubHeader.text, "It looks like assignments haven’t been created in this space yet.")

        controller.tableView.delegate?.scrollViewWillBeginDragging?(controller.tableView)
        XCTAssertTrue(isDragging)
        controller.tableView.contentInset.top = 50
        controller.tableView.delegate?.scrollViewDidScroll?(controller.tableView)
        XCTAssertEqual(controller.emptyStateTop.constant, 50)
        controller.tableView.contentOffset.y = -64
        controller.tableView.delegate?.scrollViewDidScroll?(controller.tableView)
        XCTAssertEqual(controller.emptyStateTop.constant, 64)
        controller.tableView.delegate?.scrollViewDidEndDragging?(controller.tableView, willDecelerate: false)
        XCTAssertFalse(isDragging)
    }
}
