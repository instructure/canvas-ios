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
    typealias DetailsHelper = Helper.Details
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

        // MARK: Navigate to Announcement page and check the order of the announcements
        AnnouncementsHelper.navigateToAnnouncementsPage(course: course)

        let firstAnnouncement = AnnouncementsHelper.cell(index: 0).waitUntil(.visible)
        XCTAssertTrue(firstAnnouncement.isVisible)
        XCTAssertTrue(firstAnnouncement.label.contains(announcements[1].title))

        let secondAnnouncement = AnnouncementsHelper.cell(index: 1).waitUntil(.visible)
        XCTAssertTrue(secondAnnouncement.isVisible)
        XCTAssertTrue(secondAnnouncement.label.contains(announcements[0].title))

        // MARK: Check title and message
        firstAnnouncement.hit()
        let announcementTitle = DetailsHelper.title.waitUntil(.visible)
        XCTAssertTrue(announcementTitle.isVisible)
        XCTAssertEqual(announcementTitle.label, announcements[1].title)

        let announcementMessage = DetailsHelper.message.waitUntil(.visible)
        XCTAssertTrue(announcementMessage.isVisible)
        XCTAssertEqual(announcementMessage.label, announcements[1].message)
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

    func testCreateNewAnnouncement() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        let title = "New Announcement Title"
        let description = "Description of \(title)"
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in, navigate to Announcements
        logInDSUser(teacher)
        AnnouncementsHelper.navigateToAnnouncementsPage(course: course)

        let createButton = AnnouncementsHelper.createAnnouncementButton.waitUntil(.visible)
        XCTAssertTrue(createButton.isVisible)

        // MARK: Create new announcement
        createButton.hit()
        let titleField = EditorHelper.title.waitUntil(.visible)
        let descriptionField = EditorHelper.description.waitUntil(.visible)
        let sections = EditorHelper.sections.waitUntil(.visible)
        let allowUsersToComment = EditorHelper.locked.waitUntil(.visible)
        let allowRating = EditorHelper.allowRating.waitUntil(.visible)
        let doneButton = EditorHelper.done.waitUntil(.visible)
        XCTAssertTrue(titleField.isVisible)
        XCTAssertTrue(descriptionField.isVisible)
        XCTAssertTrue(sections.isVisible)
        XCTAssertTrue(allowUsersToComment.isVisible)
        XCTAssertTrue(allowUsersToComment.hasValue(value: "0"))
        XCTAssertTrue(allowRating.isVisible)
        XCTAssertTrue(allowRating.hasValue(value: "0"))
        XCTAssertTrue(doneButton.isVisible)

        titleField.writeText(text: title)
        descriptionField.writeText(text: description)
        allowUsersToComment.actionUntilElementCondition(action: .swipeUp(.onApp), condition: .hittable)
        allowUsersToComment.hit()
        allowRating.actionUntilElementCondition(action: .swipeUp(.onApp), condition: .hittable)
        allowRating.hit()
        allowUsersToComment.waitUntil(.value(expected: "1"))
        allowRating.waitUntil(.value(expected: "1"))
        XCTAssertTrue(allowUsersToComment.hasValue(value: "1"))
        XCTAssertTrue(allowRating.hasValue(value: "1"))

        // MARK: Finish creating announcement, check if it was successful
        doneButton.hit()
        let newAnnouncementItem = Helper.cell(index: 0).waitUntil(.visible)
        XCTAssertTrue(newAnnouncementItem.isVisible)
        XCTAssertTrue(newAnnouncementItem.hasLabel(label: title, strict: false))
    }
}
