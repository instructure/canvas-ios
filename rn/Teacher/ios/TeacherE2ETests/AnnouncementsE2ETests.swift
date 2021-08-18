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

import XCTest
import TestsFoundation

class AnnouncementsE2ETests: CoreUITestCase {
    func testAnnouncementsE2E() {
        let announcementTitle = "This is a test announcement"
        let announcementDescription = "For testing purposes"
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.announcements.tap()
        Announcements.emptyAnnouncements.waitToExist()
        NavBar.backButton.tap()
        NavBar.backButton.tap()
        Dashboard.courseCard(id: "892").waitToExist()
        Dashboard.courseCard(id: "892").tap()
        CourseNavigation.announcements.tap()
        Announcements.addNewAnnouncement.waitToExist()
        Announcements.announcementByTitle(title: announcementTitle).waitToExist()
        Announcements.announcementByTitle(title: announcementTitle).tap()
        AnnouncementsDetails.optionButton.waitToExist()
        AnnouncementsDetails.replyButton.waitToExist()
        AnnouncementsDetails.detailsByText(text: announcementDescription).waitToExist()
        AnnouncementsDetails.optionButton.tap()
        app.find(label: "Edit").waitToExist()
    }
}
