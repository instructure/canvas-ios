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
import CoreData
@testable import Core
@testable import Parent
import TestsFoundation

class ObserverAlertListViewControllerTests: ParentTestCase {
    lazy var controller = ObserverAlertListViewController.create(studentID: "1")

    override func setUp() {
        super.setUp()
        api.mock(controller.alerts, value: [
            .make(
                action_date: DateComponents(calendar: .current, year: 2020, month: 6, day: 30).date,
                alert_type: .courseGradeHigh,
                context_id: "1", html_url: URL(string: "/courses/1"),
                id: "1", observer_alert_threshold_id: "1",
                title: "Course grade: 95% in C1",
                user_id: "1",
                workflow_state: .unread
            ),
            .make(
                action_date: DateComponents(calendar: .current, year: 2020, month: 6, day: 25).date,
                alert_type: .institutionAnnouncement,
                context_id: "1", html_url: nil,
                id: "3", observer_alert_threshold_id: "3",
                title: "Institution announcement: \"Finals will be cancelled\"",
                user_id: "1",
                workflow_state: .read
            ),
            .make(
                action_date: DateComponents(calendar: .current, year: 2020, month: 6, day: 15).date,
                alert_type: .assignmentGradeLow,
                course_id: "1", html_url: URL(string: "/courses/1/assignments/1"),
                id: "7", observer_alert_threshold_id: "7",
                title: "Assignment graded: 46% on Practice Worksheet 3 in C1",
                user_id: "1",
                workflow_state: .read
            ),
            .make(id: "17", workflow_state: .dismissed),
            .make(
                action_date: DateComponents(calendar: .current, year: 2020, month: 6, day: 5).date,
                alert_type: .courseGradeHigh,
                context_id: "1", html_url: URL(string: "/courses/1"),
                id: "11", observer_alert_threshold_id: "1",
                title: "Course grade: 95% in C1",
                user_id: "1",
                workflow_state: .unread,
                locked_for_user: true
            ),
        ])
        api.mock(controller.thresholds, value: [
            .make(id: "1", user_id: "1", alert_type: .courseGradeHigh, threshold: 90),
            .make(id: "2", user_id: "1", alert_type: .courseGradeLow, threshold: 60),
            .make(id: "3", user_id: "1", alert_type: .institutionAnnouncement, threshold: nil),
        ])
    }

    func testLayout() {
        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(nav.navigationBar.barTintColor?.hexString, ColorScheme.observee("1").color.darkenToEnsureContrast(against: .white).hexString)

        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 4)

        var index = IndexPath(row: 0, section: 0)
        var cell = controller.tableView.cellForRow(at: index) as? ObserverAlertListCell
        XCTAssertEqual(cell?.unreadView.isHidden, false)
        XCTAssertEqual(cell?.typeLabel.text, "Course Grade Above 90")
        XCTAssertEqual(cell?.titleLabel.text, "Course grade: 95% in C1")
        XCTAssertEqual(cell?.dateLabel.text, "Jun 30, 2020 at 12:00 AM")
        XCTAssertEqual(cell?.iconView.image, .infoLine)
        XCTAssertEqual(cell?.iconView.tintColor, .textInfo)

        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: index)
        XCTAssert(router.lastRoutedTo("/courses/1/grades"))

        index.row = 1
        cell = controller.tableView.cellForRow(at: index) as? ObserverAlertListCell
        XCTAssertEqual(cell?.unreadView.isHidden, true)
        XCTAssertEqual(cell?.typeLabel.text, "Institution Announcement")
        XCTAssertEqual(cell?.titleLabel.text, "Institution announcement: \"Finals will be cancelled\"")
        XCTAssertEqual(cell?.dateLabel.text, "Jun 25, 2020 at 12:00 AM")
        XCTAssertEqual(cell?.iconView.image, .infoLine)
        XCTAssertEqual(cell?.iconView.tintColor, .textDark)

        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: index)
        XCTAssert(router.lastRoutedTo("/accounts/self/account_notifications/1"))

        index.row = 2
        cell = controller.tableView.cellForRow(at: index) as? ObserverAlertListCell
        XCTAssertEqual(cell?.unreadView.isHidden, true)
        XCTAssertEqual(cell?.typeLabel.text, "Assignment Grade Below 0")
        XCTAssertEqual(cell?.titleLabel.text, "Assignment graded: 46% on Practice Worksheet 3 in C1")
        XCTAssertEqual(cell?.dateLabel.text, "Jun 15, 2020 at 12:00 AM")
        XCTAssertEqual(cell?.iconView.image, .warningLine)
        XCTAssertEqual(cell?.iconView.tintColor, .textDanger)

        index.row = 3
        cell = controller.tableView.cellForRow(at: index) as? ObserverAlertListCell
        XCTAssertEqual(cell?.unreadView.isHidden, false)
        XCTAssertEqual(cell?.typeLabel.text, "Course Grade Above 90 • Locked")
        XCTAssertEqual(cell?.titleLabel.text, "Course grade: 95% in C1")
        XCTAssertEqual(cell?.dateLabel.text, "Jun 5, 2020 at 12:00 AM")
        XCTAssertEqual(cell?.iconView.image, .lockLine)
        XCTAssertEqual(cell?.iconView.tintColor, .textInfo)

        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: index)
        XCTAssert(router.last is UIAlertController)

        index.row = 2
        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: index)
        XCTAssert(router.lastRoutedTo("/courses/1/assignments/1"))

        let swipe = controller.tableView(controller.tableView, trailingSwipeActionsConfigurationForRowAt: index)
        XCTAssertEqual(swipe?.actions.count, 1)
        XCTAssertEqual(swipe?.actions.first?.title, "Dismiss")
        swipe?.actions[0].handler(swipe!.actions[0], UIView()) { isSuccess in
            XCTAssertEqual(isSuccess, true)
        }

        api.mock(controller.alerts, error: NSError.internalError())
        controller.tableView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.errorView.isHidden, false)
        XCTAssertEqual(controller.errorView.messageLabel.text, "There was an error loading alerts. Pull to refresh to try again.")

        api.mock(controller.alerts, value: [])
        controller.errorView.retryButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.emptyView.isHidden, false)
        XCTAssertEqual(controller.emptyTitleLabel.text, "No Alerts")
        XCTAssertEqual(controller.emptyMessageLabel.text, "There's nothing to be notified of yet.")
    }
}
