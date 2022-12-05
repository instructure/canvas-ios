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

class DSAnnouncementsE2ETests: E2ETestCase {
    func testAnnouncementsE2E() {
        let student = seeder.createUser()
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)
        seeder.enrollStudent(student, in: course)

        let announcementTitle = "Announcement Title"
        let announcementMessage = "This is an announcement"
        seeder.createDiscussion(courseId: course.id, requestBody: .init(title: announcementTitle, message: announcementMessage, is_announcement: true, published: true))

        logInDSUser(student)
        Dashboard.courseCard(id: course.id).waitToExist()
        Dashboard.courseCard(id: course.id).tap()
        pullToRefresh()
        CourseNavigation.announcements.waitToExist()
        CourseNavigation.announcements.tap()
        XCTAssert(AnnouncementList.cell(index: 0).label().contains(announcementTitle))
        AnnouncementList.cell(index: 0).tap()
        XCTAssertEqual(DiscussionDetails.title.label(), announcementTitle)
        XCTAssertTrue(app.find(label: announcementMessage).waitToExist(10).exists())
    }

    func testAnnouncementToggleE2E() {
        let student = seeder.createUser()
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)
        seeder.enrollStudent(student, in: course)

        let dateFormatter = ISO8601DateFormatter()
        let globalAnnouncementSubject = "This is a GA"
        let globalAnnouncementMessage = "This will disappear in 4 minutes"
        let globalAnnouncementStartAt = dateFormatter.string(from: Date().addMinutes(-1))
        let globalAnnouncementEndAt = dateFormatter.string(from: Date().addMinutes(3))

        let globalAnnouncement = seeder.postAccountNotifications(requestBody:
                .init(subject: globalAnnouncementSubject, message: globalAnnouncementMessage,
                      start_at: globalAnnouncementStartAt, end_at: globalAnnouncementEndAt)
        )

        logInDSUser(student)
        Dashboard.courseCard(id: course.id).waitToExist()
        app.find(label: globalAnnouncement.subject).waitToExist()

        AccountNotifications.toggleButton(id: globalAnnouncement.id).waitToExist()
        XCTAssertFalse(AccountNotifications.dismissButton(id: globalAnnouncement.id).isVisible)

        AccountNotifications.toggleButton(id: globalAnnouncement.id).tap()
        AccountNotifications.dismissButton(id: globalAnnouncement.id).waitToExist()
        app.find(label: globalAnnouncement.message).waitToExist()

        AccountNotifications.dismissButton(id: globalAnnouncement.id).tap()
        AccountNotifications.dismissButton(id: globalAnnouncement.id).waitToVanish()
    }
}
