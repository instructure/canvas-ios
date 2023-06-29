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
import XCTest

class AnnouncementsTests: E2ETestCase {
    func testAnnouncementsMatchWebOrder() {
        typealias Helper = AnnouncementsHelper

        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Create some announcements and get the user logged in
        let announcements = Helper.createAnnouncements(course: course, count: 3)
        logInDSUser(student)

        // MARK: Navigate to Announcement page and check the order of the announcements
        AnnouncementsHelper.navigateToAnnouncementsPage(course: course)

        let firstAnnouncement = AnnouncementList.cell(index: 0).waitToExist()
        XCTAssertTrue(firstAnnouncement.isVisible)
        XCTAssertTrue(firstAnnouncement.label().contains(announcements[2].title))

        let secondAnnouncement = AnnouncementList.cell(index: 1).waitToExist()
        XCTAssertTrue(secondAnnouncement.isVisible)
        XCTAssertTrue(secondAnnouncement.label().contains(announcements[1].title))

        let thirdAnnouncement = AnnouncementList.cell(index: 2).waitToExist()
        XCTAssertTrue(thirdAnnouncement.isVisible)
        XCTAssertTrue(thirdAnnouncement.label().contains(announcements[0].title))
    }

    func testAnnouncementsTitleAndMessage() {
        typealias Helper = AnnouncementsHelper
        typealias DetailsHelper = Helper.Details

        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Create an announcement and get the user logged in
        let announcement = Helper.createAnnouncements(course: course)[0]
        logInDSUser(student)

        // MARK: Navigate to Announcement page and check the title and message of the announcement
        Helper.navigateToAnnouncementsPage(course: course, shouldPullToRefresh: true)

        let firstAnnouncement = AnnouncementList.cell(index: 0).waitToExist()
        XCTAssertTrue(firstAnnouncement.isVisible)
        XCTAssertTrue(firstAnnouncement.label().contains(announcement.title))

        firstAnnouncement.tap()
        let announcementTitle = DetailsHelper.title.waitToExist()
        XCTAssertTrue(announcementTitle.isVisible)
        XCTAssertEqual(announcementTitle.label(), announcement.title)

        let announcementMessage = DetailsHelper.message.waitToExist()
        XCTAssertTrue(announcementMessage.isVisible)
        XCTAssertEqual(announcementMessage.label(), announcement.message)
    }

    func testAnnouncementToggle() {
        typealias Helper = AnnouncementsHelper

        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Post an account notification and get the user logged in
        let globalAnnouncement = Helper.postAccountNotification()
        logInDSUser(student)

        // MARK: Check visibility of the course and the announcement notification title
        let courseCard = Dashboard.courseCard(id: course.id).waitToExist()
        XCTAssertTrue(courseCard.isVisible)
        let annountementTitle = Helper.notificationTitle(announcement: globalAnnouncement).waitToExist()
        XCTAssertTrue(annountementTitle.isVisible)

        // MARK: Check visibility toggle and dismiss button of the announcement notificaiton
        let toggleButton = AccountNotifications.toggleButton(id: globalAnnouncement.id).waitToExist()
        XCTAssertTrue(toggleButton.isVisible)
        var dismissButton = AccountNotifications.dismissButton(id: globalAnnouncement.id)
        XCTAssertFalse(dismissButton.isVisible)

        // MARK: Tap the toggle button and check visibility of dismiss button again
        toggleButton.tap()
        dismissButton = dismissButton.waitToExist()
        XCTAssertTrue(dismissButton.isVisible)

        // MARK: Check the message of the announcement
        let announcementMessage = Helper.notificationMessage(announcement: globalAnnouncement).waitToExist()
        XCTAssertTrue(announcementMessage.isVisible)
        XCTAssertEqual(announcementMessage.label(), globalAnnouncement.message)

        // MARK: Tap dismiss button and check the visibility
        dismissButton.tap()
        dismissButton = dismissButton.waitToVanish()
        XCTAssertFalse(dismissButton.isVisible)
    }
}

// MARK: Tests without DataSeeder (to be upgraded: MBL-16825)

class OldAnnouncementE2ETests: CoreUITestCase {
    func testPreviewAnnouncementAttachment() {
        Dashboard.courseCard(id: "262").tapUntil {
            CourseNavigation.announcements.exists
        }
        CourseNavigation.announcements.tap()

        AnnouncementList.cell(index: 0).tap()
        app.find(label: "run.jpg").tap()
        app.find(type: .image).waitToExist()
    }
}
