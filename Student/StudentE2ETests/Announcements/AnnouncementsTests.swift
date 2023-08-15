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
        XCTAssertTrue(firstAnnouncement.label.contains(announcements[2].title))

        let secondAnnouncement = AnnouncementsHelper.cell(index: 1).waitUntil(.visible)
        XCTAssertTrue(secondAnnouncement.isVisible)
        XCTAssertTrue(secondAnnouncement.label.contains(announcements[1].title))

        let thirdAnnouncement = AnnouncementsHelper.cell(index: 2).waitUntil(.visible)
        XCTAssertTrue(thirdAnnouncement.isVisible)
        XCTAssertTrue(thirdAnnouncement.label.contains(announcements[0].title))
    }

    func testAnnouncementsTitleAndMessage() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Create an announcement and get the user logged in
        let announcement = Helper.createAnnouncements(course: course)[0]
        logInDSUser(student)

        // MARK: Navigate to Announcement page and check the title and message of the announcement
        Helper.navigateToAnnouncementsPage(course: course, shouldPullToRefresh: true)

        let firstAnnouncement = AnnouncementsHelper.cell(index: 0).waitUntil(.visible)
        XCTAssertTrue(firstAnnouncement.isVisible)
        XCTAssertTrue(firstAnnouncement.label.contains(announcement.title))

        firstAnnouncement.hit()
        let announcementTitle = DetailsHelper.title.waitUntil(.visible)
        XCTAssertTrue(announcementTitle.isVisible)
        XCTAssertEqual(announcementTitle.label, announcement.title)

        let announcementMessage = DetailsHelper.message.waitUntil(.visible)
        XCTAssertTrue(announcementMessage.isVisible)
        XCTAssertEqual(announcementMessage.label, announcement.message)
    }

    func testAnnouncementToggle() {
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
        let toggleButton = AccountNotifications.toggleButton(notification: globalAnnouncement)
            .waitUntil(.visible)
        XCTAssertTrue(toggleButton.isVisible)
        var dismissButton = AccountNotifications.dismissButton(notification: globalAnnouncement)
            .waitUntil(.vanish)
        XCTAssertFalse(dismissButton.isVisible)

        // MARK: Tap the toggle button and check visibility of dismiss button again
        toggleButton.hit()
        dismissButton = dismissButton.waitUntil(.visible)
        XCTAssertTrue(dismissButton.isVisible)

        // MARK: Check the message of the announcement
        let announcementMessage = Helper.notificationMessage(announcement: globalAnnouncement).waitUntil(.visible)
        XCTAssertTrue(announcementMessage.isVisible)
        XCTAssertEqual(announcementMessage.label, globalAnnouncement.message)

        // MARK: Tap dismiss button and check the visibility
        dismissButton.hit()
        dismissButton = dismissButton.waitUntil(.vanish)
        XCTAssertFalse(dismissButton.isVisible)
    }
}
