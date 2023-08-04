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

class DSTeacherAnnouncementsE2ETests: E2ETestCase {
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
        DashboardHelper.courseCard(course: course).hit()
        pullToRefresh()
        CourseDetailsHelper.cell(type: .announcements).hit()
        AnnouncementsHelper.cell(index: 0).hit()
        XCTAssertTrue(app.find(label: announcementMessage).waitUntil(.visible).isVisible)
        XCTAssertEqual(DiscussionsHelper.Details.titleLabel.label, announcementTitle)
        AnnouncementsHelper.backButton.hit()

        // Add a new announcement from the app
        AnnouncementsHelper.addNewAnnouncement.hit()
        let newAnnouncementTitle = "New Announcement"
        DiscussionsHelper.Editor.titleField.writeText(text: newAnnouncementTitle)
        DiscussionsHelper.Editor.richContentEditorWebView.writeText(text: "Description")
        DiscussionsHelper.Editor.doneButton.hit()
        XCTAssertTrue(app.find(labelContaining: newAnnouncementTitle).waitUntil(.visible).isVisible)
        XCTAssertTrue(app.find(labelContaining: announcementTitle).waitUntil(.visible).isVisible)
    }
}
