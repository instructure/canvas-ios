//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class AnnouncementsE2ETests: CoreUITestCase {
    func testAnnouncementsE2E() {
        let announcementTitle = "This is a test announcement"
        let announcementDescription = "For testing purposes"
        DashboardHelper.courseCard(courseId: "263").hit()
        CourseDetailsHelper.cell(type: .announcements).hit()
        XCTAssertTrue(AnnouncementsHelper.emptyAnnouncements.waitUntil(condition: .visible).isVisible)
        AnnouncementsHelper.backButton.hit()
        AnnouncementsHelper.backButton.hit()
        DashboardHelper.courseCard(courseId: "892").hit()
        CourseDetailsHelper.cell(type: .announcements).hit()
        XCTAssertTrue(AnnouncementsHelper.addNewAnnouncement.waitUntil(condition: .visible).isVisible)
        app.find(labelContaining: announcementTitle).hit()
        XCTAssertTrue(AnnouncementsHelper.Details.optionButton.waitUntil(condition: .visible).isVisible)
        XCTAssertTrue(AnnouncementsHelper.Details.replyButton.waitUntil(condition: .visible).isVisible)
        XCTAssertTrue(AnnouncementsHelper.Details.detailsByText(text: announcementDescription).waitUntil(condition: .visible).isVisible)
        AnnouncementsHelper.Details.optionButton.hit()
        XCTAssertTrue(app.find(label: "Edit").waitUntil(condition: .visible).isVisible)
    }
}
