//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import TestsFoundation

class AnnouncementsTests: E2ETestCase {
    typealias Helper = AnnouncementsHelper
    typealias DetailsHelper = Helper.Details
    typealias AccountNotifications = Helper.AccountNotifications

    func testAnnouncementsMatchWebOrder() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Create some announcements and get the user logged in
        let announcements = Helper.createAnnouncements(course: course, count: 3)
        logInDSUser(student)

        // MARK: Navigate to Announcement page and check the order of the announcements
        AnnouncementsHelper.navigateToAnnouncementsPage(course: course)

        let firstAnnouncement = AnnouncementsHelper.cell(index: 0).waitUntil(.visible)
        XCTAssertTrue(firstAnnouncement.isVisible)
        XCTAssertTrue(firstAnnouncement.hasLabel(label: announcements[2].title, strict: false))

        let secondAnnouncement = AnnouncementsHelper.cell(index: 1).waitUntil(.visible)
        XCTAssertTrue(secondAnnouncement.isVisible)
        XCTAssertTrue(secondAnnouncement.hasLabel(label: announcements[1].title, strict: false))

        let thirdAnnouncement = AnnouncementsHelper.cell(index: 2).waitUntil(.visible)
        XCTAssertTrue(thirdAnnouncement.isVisible)
        XCTAssertTrue(thirdAnnouncement.hasLabel(label: announcements[0].title, strict: false))
    }

    func testAccountNotification() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Post an account notification and get the user logged in
        let globalAnnouncement = Helper.postAccountNotification()
        logInDSUser(student)

        // MARK: Check visibility of the course and the announcement notification title
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)
        let announcementTitle = Helper.notificationTitle(announcement: globalAnnouncement)
        announcementTitle.actionUntilElementCondition(action: .pullToRefresh, condition: .visible, timeout: 60, gracePeriod: 3)
        XCTAssertTrue(announcementTitle.isVisible)

        // MARK: Check visibility toggle and dismiss button of the announcement notificaiton
        let toggleButton = AccountNotifications.toggleButton(notification: globalAnnouncement).waitUntil(.visible)
        XCTAssertTrue(toggleButton.isVisible)
        XCTAssertEqual(toggleButton.label, "\(globalAnnouncement.subject), Tap to view announcement")
        var dismissButton = AccountNotifications.dismissButton(notification: globalAnnouncement).waitUntil(.vanish)
        XCTAssertTrue(dismissButton.isVanished)

        // MARK: Tap the toggle button and check visibility of dismiss button again
        toggleButton.hit()
        dismissButton = dismissButton.waitUntil(.visible)
        XCTAssertEqual(toggleButton.label, "Hide content for \(globalAnnouncement.subject)")
        XCTAssertTrue(dismissButton.isVisible)
        XCTAssertEqual(dismissButton.label, "Dismiss \(globalAnnouncement.subject)")

        // MARK: Check the message of the announcement
        let announcementMessage = Helper.notificationMessage(announcement: globalAnnouncement).waitUntil(.visible)
        XCTAssertTrue(announcementMessage.isVisible)
        XCTAssertTrue(announcementMessage.hasLabel(label: globalAnnouncement.message))

        // MARK: Tap dismiss button and check the visibility
        dismissButton.hit()
        dismissButton = dismissButton.waitUntil(.vanish)
        XCTAssertTrue(dismissButton.isVanished)
    }

    func testAnnouncementDetails() {
        typealias NewDiscussion = DiscussionsHelper.NewDetails

        // MARK: Seed the usual stuff with an announcement, enable NewDiscussion feature
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        let announcement = Helper.createAnnouncement(course: course)

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Discussions and check visibility of buttons and labels
        Helper.navigateToAnnouncementsPage(course: course)
        let announcementsButton = Helper.cell(index: 0).waitUntil(.visible)
        XCTAssertTrue(announcementsButton.isVisible)
        XCTAssertTrue(announcementsButton.hasLabel(label: announcement.title, strict: false))

        announcementsButton.hit()
        let searchField = NewDiscussion.searchField.waitUntil(.visible)
        let filterByLabel = NewDiscussion.filterByLabel.waitUntil(.visible)
        let sortButton = NewDiscussion.sort.waitUntil(.visible)
        let viewSplitScreenButton = NewDiscussion.viewSplitScreenButton.waitUntil(.visible)
        let subscribeButton = NewDiscussion.subscribeButton.waitUntil(.visible)
        let manageDiscussionButton = NewDiscussion.manageDiscussionButton.waitUntil(.visible)
        let announcementTitle = NewDiscussion.discussionTitle(discussion: announcement).waitUntil(.visible)
        let announcementBody = NewDiscussion.discussionBody(discussion: announcement).waitUntil(.visible)
        let replyButton = NewDiscussion.replyButton.waitUntil(.visible)
        XCTAssertTrue(searchField.isVisible)
        XCTAssertTrue(filterByLabel.isVisible)
        XCTAssertTrue(sortButton.isVisible)
        XCTAssertTrue(sortButton.hasValue(value: "Newest First", strict: false))
        XCTAssertTrue(viewSplitScreenButton.isVisible)
        XCTAssertTrue(subscribeButton.isVisible)
        XCTAssertTrue(manageDiscussionButton.isVisible)
        XCTAssertTrue(announcementTitle.isVisible)
        XCTAssertTrue(announcementBody.isVisible)
        XCTAssertTrue(replyButton.isVisible)

        viewSplitScreenButton.hit()
        let viewInlineButton = NewDiscussion.viewInlineButton.waitUntil(.visible)
        XCTAssertTrue(viewSplitScreenButton.isVanished)
        XCTAssertTrue(viewInlineButton.isVisible)

        subscribeButton.hit()
        let unsubscribeButton = NewDiscussion.unsubscribeButton.waitUntil(.visible)
        XCTAssertTrue(subscribeButton.isVanished)
        XCTAssertTrue(unsubscribeButton.isVisible)

        manageDiscussionButton.hit()
        let markAllAsReadButton = NewDiscussion.markAllAsRead.waitUntil(.visible)
        let markAllAsUnreadButton = NewDiscussion.markAllAsUnread.waitUntil(.visible)
        XCTAssertTrue(markAllAsReadButton.isVisible)
        XCTAssertTrue(markAllAsUnreadButton.isVisible)
    }
}
