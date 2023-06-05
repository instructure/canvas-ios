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
        let student = seeder.createUser()
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)
        seeder.enrollStudent(student, in: course)

        let announcements = AnnouncementsHelper.createAnnouncements(course: course, count: 3)
        logInDSUser(student)

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
        let student = seeder.createUser()
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)
        seeder.enrollStudent(student, in: course)
        let announcement = AnnouncementsHelper.createAnnouncements(course: course)[0]

        logInDSUser(student)

        AnnouncementsHelper.navigateToAnnouncementsPage(course: course, pull_to_refresh: true)

        let firstAnnouncement = AnnouncementList.cell(index: 0).waitToExist()
        XCTAssertTrue(firstAnnouncement.isVisible)
        XCTAssertTrue(firstAnnouncement.label().contains(announcement.title))

        firstAnnouncement.tap()
        let announcementTitle = AnnouncementsHelper.announcementDetailsTitle.waitToExist()
        XCTAssertTrue(announcementTitle.isVisible)
        XCTAssertEqual(announcementTitle.label(), announcement.title)

        let announcementMessage = AnnouncementsHelper.announcementDetailsMessage.waitToExist()
        XCTAssertTrue(announcementMessage.isVisible)
        XCTAssertEqual(announcementMessage.label(), announcement.message)
    }

    func testAnnouncementToggle() {
        let student = seeder.createUser()
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)
        seeder.enrollStudent(student, in: course)
        let globalAnnouncement = AnnouncementsHelper.postAccountNotification()

        logInDSUser(student)

        let courseCard = Dashboard.courseCard(id: course.id).waitToExist()
        XCTAssertTrue(courseCard.isVisible)
        let annountementTitle = AnnouncementsHelper.notificationTitle(announcement: globalAnnouncement).waitToExist()
        XCTAssertTrue(annountementTitle.isVisible)

        let toggleButton = AccountNotifications.toggleButton(id: globalAnnouncement.id).waitToExist()
        XCTAssertTrue(toggleButton.isVisible)
        var dismissButton = AccountNotifications.dismissButton(id: globalAnnouncement.id)
        XCTAssertFalse(dismissButton.isVisible)

        toggleButton.tap()
        dismissButton = dismissButton.waitToExist()
        XCTAssertTrue(dismissButton.isVisible)
        let announcementMessage = AnnouncementsHelper.notificationMessage(announcement: globalAnnouncement).waitToExist()
        XCTAssertTrue(announcementMessage.isVisible)
        XCTAssertEqual(announcementMessage.label(), globalAnnouncement.message)

        dismissButton.tap()
        dismissButton = dismissButton.waitToVanish()
        XCTAssertFalse(dismissButton.isVisible)
    }
}

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
