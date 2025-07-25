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

class DiscussionListViewControllerTests: CoreTestCase {

    private enum TestConstants {
        static let date1031 = DateComponents(calendar: .current, year: 2020, month: 10, day: 31).date!
        static let date1102 = DateComponents(calendar: .current, year: 2020, month: 11, day: 2).date!
        static let date1103 = DateComponents(calendar: .current, year: 2020, month: 11, day: 3).date!
    }

    lazy var controller = DiscussionListViewController.create(context: .course("1"), env: environment)

    func testCourseDiscussions() {
        api.mock(GetCourse(courseID: "1"), value: .make(enrollments: [
            .make(
                id: nil,
                enrollment_state: .active,
                type: "TeacherEnrollment",
                user_id: environment.currentSession?.userID ?? "12"
            )
        ]))
        api.mock(controller.colors, value: .init(custom_colors: [ "course_1": "#0000ff" ]))
        api.mock(controller.topics, value: [
            .make(
                html_url: URL(string: "/courses/1/discussion_topics/1"),
                id: "1",
                last_reply_at: TestConstants.date1103,
                permissions: .make(delete: true),
                pinned: true,
                posted_at: Date(),
                title: "Alien invasion probabilities"
            ),
            .make(
                assignment: .make(has_overrides: true),
                assignment_id: "1",
                html_url: URL(string: "/courses/1/discussion_topics/2"),
                id: "2",
                posted_at: TestConstants.date1103,
                title: "Overrides"
            ),
            .make(
                assignment: .make(
                    due_at: TestConstants.date1031,
                    id: "4"
                ),
                assignment_id: "4",
                html_url: URL(string: "/courses/1/discussion_topics/4"),
                id: "4",
                posted_at: TestConstants.date1102,
                title: "Dude"
            ),
            .make(
                assignment: .make(
                    due_at: TestConstants.date1031,
                    id: "3",
                    lock_at: TestConstants.date1031
                ),
                assignment_id: "3",
                html_url: URL(string: "/courses/1/discussion_topics/3"),
                id: "3",
                locked: true,
                posted_at: TestConstants.date1102,
                title: "Locked"
            )
        ])

        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.titleSubtitleView.title, "Discussions")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Course One")
        XCTAssertEqual(nav.navigationBar.barTintColor?.hexString, "#0000ff")
        XCTAssertNil(controller.navigationItem.rightBarButtonItem)

        XCTAssertEqual(controller.tableView.numberOfSections, 3)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 1)
        var cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? Core.DiscussionListCell
        XCTAssertEqual(cell?.iconImageView.icon, .discussionLine)
        XCTAssertEqual(cell?.iconImageView.state, .published)
        XCTAssertEqual(cell?.titleLabel.text, "Alien invasion probabilities")
        XCTAssertEqual(cell?.dateLabel.text, "Last post " + TestConstants.date1103.dateTimeString)

        let actions = controller.tableView.delegate?.tableView?(controller.tableView, trailingSwipeActionsConfigurationForRowAt: IndexPath(row: 0, section: 0))?.actions
        XCTAssertEqual(actions?.count, 3)
        XCTAssertEqual(actions?[0].title, "Delete")
        actions?[0].handler(actions![0], UIView(), { _ in })
        let alert = router.presented as? UIAlertController
        XCTAssertEqual(alert?.title, "Delete Discussion")
        api.mock(DeleteDiscussionTopicRequest(context: .course("1"), topicID: "1"), error: NSError.internalError())
        let confirm = alert?.actions.first as? AlertAction
        confirm?.handler?(confirm!)
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Internal Error")

        api.mock(PutDiscussionTopicRequest(context: .course("1"), topicID: "1"), error: NSError.internalError())
        XCTAssertEqual(actions?[1].title, "Close")
        actions?[1].handler(actions![1], UIView(), { _ in })
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Internal Error")
        XCTAssertEqual(actions?[2].title, "Unpin")
        actions?[2].handler(actions![2], UIView(), { _ in })
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Internal Error")

        cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? Core.DiscussionListCell
        XCTAssertEqual(cell?.iconImageView.icon, .assignmentLine)
        XCTAssertEqual(cell?.iconImageView.state, .published)
        XCTAssertEqual(cell?.titleLabel.text, "Dude")
        XCTAssertEqual(cell?.dateLabel.text, "Due " + TestConstants.date1031.relativeDateTimeString)

        XCTAssertEqual(controller.tableView.delegate?.tableView?(
            controller.tableView, trailingSwipeActionsConfigurationForRowAt: IndexPath(row: 0, section: 1)
        )?.actions.count, 2)

        cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? Core.DiscussionListCell
        XCTAssertEqual(cell?.iconImageView.icon, .assignmentLine)
        XCTAssertEqual(cell?.iconImageView.state, .published)
        XCTAssertEqual(cell?.titleLabel.text, "Locked")
        XCTAssertEqual(cell?.statusLabel.text, "Closed")
        XCTAssertEqual(cell?.dateLabel.text, "Due " + TestConstants.date1031.relativeDateTimeString)

        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 2))
        XCTAssert(router.lastRoutedTo("/courses/1/discussion_topics/3", withOptions: .detail))

        XCTAssertNoThrow(controller.viewWillDisappear(false))
    }

    func testPointsLabelWhenQuantitativeDataEnabled() {
        // Given
        mockCourseAndAssignmentWith(restrict_quantitative_data: true)

        // When
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        // Then
        let cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? Core.DiscussionListCell
        XCTAssertEqual(cell?.pointsLabel.isHidden, true)
        XCTAssertEqual(cell?.pointsLabel.text, "21 pts")
    }

    func testPointsLabelWhenQuantitativeDataDisabled() {
        // Given
        mockCourseAndAssignmentWith(restrict_quantitative_data: false)

        // When
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        // Then
        let cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? Core.DiscussionListCell
        XCTAssertEqual(cell?.pointsLabel.isHidden, false)
        XCTAssertEqual(cell?.pointsLabel.text, "21 pts")
    }

    func testPointsLabelWhenQuantitativeDataNotSpecified() {
        // Given
        mockCourseAndAssignmentWith(restrict_quantitative_data: nil)

        // When
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        // Then
        let cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? Core.DiscussionListCell
        XCTAssertEqual(cell?.pointsLabel.isHidden, false)
        XCTAssertEqual(cell?.pointsLabel.text, "21 pts")
    }

    private func mockCourseAndAssignmentWith(
        restrict_quantitative_data: Bool?,
        isAnonymousDiscussion: Bool = false
    ) {
        api.mock(
            GetCourse(courseID: "1"),
            value: .make(
                settings: APICourseSettings(
                    usage_rights_required: nil,
                    syllabus_course_summary: nil,
                    restrict_quantitative_data: restrict_quantitative_data,
                    hide_final_grade: nil
                )
            )
        )

        api.mock(controller.topics, value: [
            .make(
                anonymous_state: isAnonymousDiscussion ? "anonymous" : nil,
                assignment: .make(has_overrides: true, points_possible: 21),
                assignment_id: "1",
                html_url: URL(string: "/courses/1/discussion_topics/2"),
                id: "2",
                posted_at: TestConstants.date1103,
                title: "Overrides"
            )
        ])
    }

    func testGroupDiscussions() {
        controller = DiscussionListViewController.create(context: .group("1"), env: environment)
        api.mock(GetGroup(groupID: "1"), value: .make(permissions: .make(create_discussion_topic: true)))
        api.mock(controller.colors, value: .init(custom_colors: [ "group_1": "#000000" ]))
        api.mock(controller.topics, value: [
            .make(
                html_url: URL(string: "/groups/1/discussion_topics/1"),
                id: "1",
                last_reply_at: TestConstants.date1103,
                permissions: .make(delete: true),
                title: "Study group tomorrow"
            )
        ])

        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.titleSubtitleView.title, "Discussions")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Group One")
        XCTAssertEqual(nav.navigationBar.barTintColor?.hexString, "#000000")
        XCTAssertNotNil(controller.navigationItem.rightBarButtonItem)

        _ = controller.addButton.target?.perform(controller.addButton.action)
        XCTAssert(router.lastRoutedTo("groups/1/discussion_topics/new", withOptions: .modal(isDismissable: false, embedInNav: true)))

        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 1)
        let cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? Core.DiscussionListCell
        XCTAssertEqual(cell?.iconImageView.icon, .discussionLine)
        XCTAssertEqual(cell?.iconImageView.state, nil)
        XCTAssertEqual(cell?.titleLabel.text, "Study group tomorrow")
        XCTAssertEqual(cell?.dateLabel.text, "Last post " + TestConstants.date1103.dateTimeString)

        api.mock(controller.topics, error: NSError.internalError())
        controller.tableView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.errorView.isHidden, false)

        api.mock(controller.topics, value: [])
        controller.errorView.retryButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.errorView.isHidden, true)
        XCTAssertEqual(controller.emptyView.isHidden, false)
    }

    func testAnonymousDiscussionDeviceIsOffline() {
        // Given
        let mockInteractor = OfflineModeInteractorMock(mockIsInOfflineMode: true)
        controller = DiscussionListViewController.create(
            context: .course("1"),
            offlineModeInteractor: mockInteractor,
            env: environment
        )
        mockCourseAndAssignmentWith(restrict_quantitative_data: false, isAnonymousDiscussion: true)

        // When
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        // Then
        let cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? Core.DiscussionListCell
        XCTAssertEqual(cell?.statusLabel.text, "Not supported")
        XCTAssertEqual(cell?.contentView.alpha, 0.5)
    }

    func testAnonymousDiscussionWhenDeviceIsOnline() {
        // Given
        let mockInteractor = OfflineModeInteractorMock(mockIsInOfflineMode: false)
        controller = DiscussionListViewController.create(
            context: .course("1"),
            offlineModeInteractor: mockInteractor,
            env: environment
        )
        mockCourseAndAssignmentWith(restrict_quantitative_data: false, isAnonymousDiscussion: true)

        // When
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        // Then
        let cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? Core.DiscussionListCell
        XCTAssertEqual(cell?.statusLabel.text, "Closed")
        XCTAssertEqual(cell?.contentView.alpha, 1)
    }
}
