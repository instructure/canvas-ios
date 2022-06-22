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
        // Seed the usual stuff with an announcement
        let student = seeder.createUser()
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)
        seeder.enrollStudent(student, in: course)

        let announcementTitle = "Announcement Title"
        let announcementMessage = "This is an announcement"
        seeder.createDiscussion(courseId: course.id, requestBody: .init(title: announcementTitle, message: announcementMessage, is_announcement: true, published: true))

        // Login and check the seeded announcement
        logInDSUser(teacher)
        Dashboard.courseCard(id: course.id).waitToExist()
        Dashboard.courseCard(id: course.id).tap()
        pullToRefresh()
        CourseNavigation.announcements.waitToExist()
        CourseNavigation.announcements.tap()
        AnnouncementList.announcement(index: 0).waitToExist()
        AnnouncementList.announcement(index: 0).tap()
        XCTAssertEqual(DiscussionDetails.title.label(), announcementTitle)
        XCTAssertTrue(app.find(label: announcementMessage).exists())
        NavBar.backButton.tap()

        // Add a new announcement from the app
        Announcements.addNewAnnouncement.tap()
        let newAnnouncementTitle = "New Announcement"
        DiscussionEditor.titleField.typeText(newAnnouncementTitle)
        RichContentEditor.webView.typeText("Description")
        DiscussionEditor.doneButton.tap()
        XCTAssertTrue(Announcements.announcementByTitle(title: newAnnouncementTitle).exists())
        XCTAssertTrue(Announcements.announcementByTitle(title: announcementTitle).exists())
    }
}
