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

class AnnouncementListViewControllerTests: CoreTestCase {
    lazy var controller = AnnouncementListViewController.create(context: .course("1"))

    func testCourseAnnouncements() {
        api.mock(GetCourse(courseID: "1"), value: .make(enrollments: [
            .make(
                id: nil,
                enrollment_state: .active,
                type: "TeacherEnrollment",
                user_id: environment.currentSession?.userID ?? "12"
            ),
        ]))
        api.mock(controller.colors, value: .init(custom_colors: [ "course_1": "#0000ff" ]))
        api.mock(controller.topics, value: [
            .make(
                delayed_post_at: DateComponents(calendar: .current, year: 2030, month: 11, day: 3).date,
                html_url: URL(string: "/courses/1/announcements/1"),
                id: "1",
                permissions: .make(delete: true),
                posted_at: Date(),
                subscription_hold: "topic_is_announcement",
                title: "Class Cancelled due to alien invasion"
            ),
            .make(
                html_url: URL(string: "/courses/1/announcements/2"),
                id: "2",
                last_reply_at: DateComponents(calendar: .current, year: 2020, month: 11, day: 3).date,
                posted_at: DateComponents(calendar: .current, year: 2020, month: 11, day: 3).date,
                subscription_hold: "topic_is_announcement",
                title: "Class Cancelled due to Covid-19"
            ),
            .make(
                html_url: URL(string: "/courses/1/announcements/3"),
                id: "3",
                posted_at: DateComponents(calendar: .current, year: 2020, month: 11, day: 2).date,
                subscription_hold: "topic_is_announcement",
                title: "Another Announcement"
            ),
        ])

        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.titleSubtitleView.title, "Announcements")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Course One")
        XCTAssertEqual(nav.navigationBar.barTintColor?.hexString, "#0000ff")
        XCTAssertNil(controller.navigationItem.rightBarButtonItem)

        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 3)
        var cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AnnouncementListCell
        XCTAssertEqual(cell?.iconImageView.icon, .calendarClockLine)
        XCTAssertEqual(cell?.iconImageView.state, nil)
        XCTAssertEqual(cell?.titleLabel.text, "Class Cancelled due to alien invasion")
        XCTAssertEqual(cell?.dateLabel.text, "Delayed until Nov 3, 2030 at 12:00 AM")

        let actions = controller.tableView.delegate?.tableView?(controller.tableView, trailingSwipeActionsConfigurationForRowAt: IndexPath(row: 0, section: 0))?.actions
        XCTAssertEqual(actions?.count, 1)
        XCTAssertEqual(actions?.first?.title, "Delete")
        actions?.first?.handler(actions!.first!, UIView(), { _ in })
        let alert = router.presented as? UIAlertController
        XCTAssertEqual(alert?.title, "Delete Announcement")
        api.mock(DeleteDiscussionTopicRequest(context: .course("1"), topicID: "1"), error: NSError.internalError())
        let confirm = alert?.actions.first as? AlertAction
        confirm?.handler?(confirm!)
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Internal Error")

        cell = controller.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? AnnouncementListCell
        XCTAssertEqual(cell?.iconImageView.icon, .announcementLine)
        XCTAssertEqual(cell?.iconImageView.state, .published)
        XCTAssertEqual(cell?.titleLabel.text, "Class Cancelled due to Covid-19")
        XCTAssertEqual(cell?.dateLabel.text, "Last post Nov 3, 2020 at 12:00 AM")

        XCTAssertNil(controller.tableView.delegate?.tableView?(controller.tableView, trailingSwipeActionsConfigurationForRowAt: IndexPath(row: 1, section: 0)))

        cell = controller.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? AnnouncementListCell
        XCTAssertEqual(cell?.iconImageView.icon, .announcementLine)
        XCTAssertEqual(cell?.iconImageView.state, .published)
        XCTAssertEqual(cell?.titleLabel.text, "Another Announcement")
        XCTAssertEqual(cell?.dateLabel.text, "Nov 2, 2020 at 12:00 AM")

        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: IndexPath(row: 2, section: 0))
        XCTAssert(router.lastRoutedTo("courses/1/announcements/3", withOptions: .detail))

        XCTAssertNoThrow(controller.viewWillDisappear(false))
    }

    func testGroupAnnouncements() {
        controller = AnnouncementListViewController.create(context: .group("1"))
        api.mock(GetGroup(groupID: "1"), value: .make(permissions: .make(create_announcement: true)))
        api.mock(controller.colors, value: .init(custom_colors: [ "group_1": "#000000" ]))
        api.mock(controller.topics, value: [
            .make(
                html_url: URL(string: "/groups/1/announcements/1"),
                id: "1",
                permissions: .make(delete: true),
                posted_at: DateComponents(calendar: .current, year: 2020, month: 11, day: 3).date,
                subscription_hold: "topic_is_announcement",
                title: "Study group tomorrow"
            ),
        ])

        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.titleSubtitleView.title, "Announcements")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Group One")
        XCTAssertEqual(nav.navigationBar.barTintColor?.hexString, "#000000")
        XCTAssertNotNil(controller.navigationItem.rightBarButtonItem)

        _ = controller.addButton.target?.perform(controller.addButton.action)
        XCTAssert(router.lastRoutedTo("groups/1/announcements/new", withOptions: .modal(isDismissable: false, embedInNav: true)))

        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 1)
        let cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AnnouncementListCell
        XCTAssertEqual(cell?.iconImageView.icon, .announcementLine)
        XCTAssertEqual(cell?.iconImageView.state, nil)
        XCTAssertEqual(cell?.titleLabel.text, "Study group tomorrow")
        XCTAssertEqual(cell?.dateLabel.text, "Nov 3, 2020 at 12:00 AM")

        api.mock(controller.topics, error: NSError.internalError())
        controller.tableView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.errorView.isHidden, false)

        api.mock(controller.topics, value: [])
        controller.errorView.retryButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.errorView.isHidden, true)
        XCTAssertEqual(controller.emptyView.isHidden, false)
    }
}
