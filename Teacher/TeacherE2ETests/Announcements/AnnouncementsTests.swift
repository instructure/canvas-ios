//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
    typealias DetailsHelper = DiscussionsHelper.NewDetails
    typealias AccountNotifications = Helper.AccountNotifications
    typealias EditorHelper = Helper.Editor

    func testAnnouncementsOrderTitleMessage() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Create some announcements and get the user logged in
        let announcements = Helper.createAnnouncements(course: course, count: 2)
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Announcement page and check the order of the announcements
        AnnouncementsHelper.navigateToAnnouncementsPage(course: course)

        let firstAnnouncement = AnnouncementsHelper.cell(index: 0).waitUntil(.visible)
        XCTAssertTrue(firstAnnouncement.isVisible)
        XCTAssertTrue(firstAnnouncement.hasLabel(label: announcements[1].title, strict: false))

        let secondAnnouncement = AnnouncementsHelper.cell(index: 1).waitUntil(.visible)
        XCTAssertTrue(secondAnnouncement.isVisible)
        XCTAssertTrue(secondAnnouncement.hasLabel(label: announcements[0].title, strict: false))

        // MARK: Check title and message
        firstAnnouncement.hit()
        let announcementTitle = DetailsHelper.discussionTitle(discussion: announcements[1]).waitUntil(.visible)
        let announcementMessage = DetailsHelper.discussionBody(discussion: announcements[1]).waitUntil(.visible)
        XCTAssertTrue(announcementTitle.isVisible)
        XCTAssertTrue(announcementTitle.hasLabel(label: announcements[1].title, strict: false))
        XCTAssertTrue(announcementMessage.isVisible)
        XCTAssertTrue(announcementMessage.hasLabel(label: announcements[1].message))
    }

    func testGlobalAnnouncement() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Post an account notification and get the user logged in
        let globalAnnouncement = Helper.postAccountNotification()
        logInDSUser(teacher)

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

    func testCreateNewAnnouncement() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        let title = "New Announcement Title"
        let description = "Description of \(title)"
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in, navigate to Announcements
        logInDSUser(teacher)

        XCTContext.runActivity(named: "Navigate to new announcement screen") { _ in
            let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
            XCTAssertTrue(courseCard.isVisible)
            AnnouncementsHelper.navigateToAnnouncementsPage(course: course)
            let createButton = AnnouncementsHelper.createAnnouncementButton.waitUntil(.visible)
            XCTAssertTrue(createButton.isVisible)
            createButton.hit()
        }

        let cancelButton = EditorHelper.cancelButton
        let attachmentButton = EditorHelper.attachment
        let titleField = EditorHelper.title
        let descriptionField = EditorHelper.description
        let publishButton = EditorHelper.publishButton

        XCTContext.runActivity(named: "Check new announcement screen details") { _ in
            cancelButton.waitUntil(.visible)
            attachmentButton.waitUntil(.visible)
            titleField.waitUntil(.visible)
            descriptionField.waitUntil(.visible)
            publishButton.waitUntil(.visible)
            XCTAssertTrue(cancelButton.isVisible)
            XCTAssertTrue(attachmentButton.isVisible)
            XCTAssertTrue(titleField.isVisible)
            XCTAssertTrue(descriptionField.isVisible)
            XCTAssertTrue(publishButton.isVisible)
        }

        XCTContext.runActivity(named: "Save new announcement") { _ in
            titleField.writeText(text: title)
            descriptionField.writeText(text: description)
            publishButton.hit()
        }

        XCTContext.runActivity(named: "Check if new announcement is pushed") { _ in
            let backButton = DiscussionsHelper.Details.backButton.waitUntil(.visible)
            XCTAssertTrue(backButton.isVisible)
        }
    }
}
