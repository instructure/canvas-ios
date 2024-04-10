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
        return GetPlannables(userID: userID, startDate: from, endDate: to, contextCodes: contextCodes)
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

    func getPlannablesRequest(from: Date, to: Date) -> GetPlannablesRequest {
        GetPlannablesRequest(startDate: from, endDate: to)
    }

    var start = Clock.now.startOfDay()
    var end = Clock.now.startOfDay().addDays(1)
    var userID: String?
    var contextCodes: [String]?
    lazy var controller = PlannerListViewController.create(start: start, end: end, delegate: self)

    func testLayout() {
        let date = Clock.now
        ContextColor.make()
        let assignment = APIPlannable.make(
            plannable: .init(points_possible: 1, title: "assignment a"),
            plannable_date: date
        )
        let note = APIPlannable.make(
            course_id: nil, context_type: nil,
            plannable_id: "2", plannable_type: "planner_note",
            plannable: .init(details: "deets", title: "note"),
            plannable_date: date.addMinutes(60)
        )
        api.mock(getPlannablesRequest(from: start, to: end), value: [ assignment, note ])
        controller.view.layoutIfNeeded()

        XCTAssertEqual(controller.emptyStateView.isHidden, true)
        XCTAssertEqual(controller.spinnerView.isHidden, true)
        XCTAssertEqual(controller.tableView.refreshControl?.isRefreshing, false)
        let index0 = IndexPath(row: 0, section: 0)
        let cell = controller.tableView.cellForRow(at: index0) as? PlannerListCell
        XCTAssertEqual(cell?.title.text, "assignment a")
        XCTAssertEqual(cell?.courseCode.text, "Assignment Grades")
        XCTAssertEqual(cell?.courseCode.textColor.hexString, UIColor.red.ensureContrast(against: .backgroundLightest).hexString)
        XCTAssertEqual(cell?.dueDate.text, DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short) )
        XCTAssertEqual(cell?.points.text, "1 point")
        XCTAssertEqual(cell?.pointsDivider.isHidden, false)

        let index1 = IndexPath(row: 1, section: 0)
        let cell1 = controller.tableView.cellForRow(at: index1) as? PlannerListCell
        XCTAssertEqual(cell1?.title.text, "note")
        XCTAssertEqual(cell1?.points.text, nil)
        XCTAssertEqual(cell1?.pointsDivider.isHidden, true)

        controller.tableView.selectRow(at: index0, animated: false, scrollPosition: .none)
        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: index0)
        let to = assignment.html_url!.rawValue.appendingQueryItems(URLQueryItem(name: "origin", value: "calendar"))
        XCTAssertTrue(router.lastRoutedTo(to))
        controller.viewWillAppear(false)
        XCTAssertNil(controller.tableView.indexPathForSelectedRow)

        controller.tableView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertTrue(willRefresh)
    }

    func testLayoutParentApp() {
        environment.app = .parent
        userID = "1"
        contextCodes = ["course_1"]
        api.mock(GetCoursesRequest(
            enrollmentState: .active,
            enrollmentType: .observer,
            state: [.available],
            perPage: 100
        ), value: [.make(id: "1", enrollments: [.make(id: "1", associated_user_id: userID)])])
        api.mock(GetCalendarEventsRequest(
            contexts: [Context(.course, id: "1")],
            startDate: start,
            endDate: end,
            type: .event,
            include: [.submission],
            allEvents: false,
            userID: userID
        ), value: [.make(id: "1", title: "Event", start_at: Clock.now, type: .event)])
        api.mock(GetCalendarEventsRequest(
            contexts: [Context(.course, id: "1")],
            startDate: start,
            endDate: end,
            type: .assignment,
            include: [.submission],
            allEvents: false,
            userID: userID
        ), value: [.make(id: "2", title: "Assignment", start_at: Clock.now, type: .assignment)])
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.tableView.dataSource?.tableView(controller.tableView, numberOfRowsInSection: 0), 2)
        let index0 = IndexPath(row: 0, section: 0)
        let cell = controller.tableView.cellForRow(at: index0) as? PlannerListCell
        XCTAssertEqual(cell?.title.text, "Assignment")

        let index1 = IndexPath(row: 1, section: 0)
        let cell1 = controller.tableView.cellForRow(at: index1) as? PlannerListCell
        XCTAssertEqual(cell1?.title.text, "Event")
    }

    func testNavigationToTodo() {
        let date = Clock.now
        let note = APIPlannable.make(
            plannable_id: "2",
            plannable_type: "planner_note",
            plannable: APIPlannable.plannable(details: "hello world", title: "to do title"),
            plannable_date: date
        )
        api.mock(getPlannablesRequest(from: start, to: end), value: [note])
        controller.view.layoutIfNeeded()
        let index0 = IndexPath(row: 0, section: 0)
        controller.tableView.selectRow(at: index0, animated: false, scrollPosition: .none)
        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: index0)
        let todo = try? XCTUnwrap(router.viewControllerCalls.last?.0 as? PlannerNoteDetailViewController)
        XCTAssert(router.lastRoutedTo(viewController: todo!, from: controller, withOptions: .detail))
    }

    func testEmptyState() {
        api.mock(getPlannablesRequest(from: start, to: end), value: [])
        controller.view.layoutIfNeeded()

        XCTAssertEqual(controller.emptyStateView.isHidden, false)
        XCTAssertEqual(controller.emptyStateHeader.text, "No Events Today!")
        XCTAssertEqual(controller.emptyStateSubHeader.text, "It looks like a great day to rest, relax, and recharge.")

        controller.tableView.delegate?.scrollViewWillBeginDragging?(controller.tableView)
        XCTAssertTrue(isDragging)
        controller.tableView.contentInset.top = 50
        controller.tableView.delegate?.scrollViewDidScroll?(controller.tableView)
        XCTAssertTrue(didScroll)
        controller.tableView.delegate?.scrollViewDidEndDragging?(controller.tableView, willDecelerate: false)
        XCTAssertFalse(isDragging)
    }

    func testErrorState() {
        api.mock(getPlannablesRequest(from: start, to: end), error: NSError.instructureError("oops"))
        controller.view.layoutIfNeeded()

        XCTAssertEqual(controller.errorView.isHidden, false)
        XCTAssertEqual(controller.errorView.messageLabel.text, "There was an error loading events. Pull to refresh to try again.")

        controller.errorView.retryButton.sendActions(for: .primaryActionTriggered)
        XCTAssertTrue(willRefresh)

        api.mock(getPlannablesRequest(from: start, to: end), value: [])
        controller.refresh(force: true)
        XCTAssertEqual(controller.errorView.isHidden, true)
    }
}
