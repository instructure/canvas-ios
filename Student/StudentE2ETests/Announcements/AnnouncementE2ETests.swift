//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

enum AnnouncementList {
    static func cell(index: Int) -> Element {
        return app.find(id: "announcements.list.announcement.row-\(index)")
    }
}

class AnnouncementE2ETests: CoreUITestCase {
    override var abstractTestClass: CoreUITestCase.Type { return AnnouncementE2ETests.self }

    func testAnnouncementsMatchWebOrder() {
        Dashboard.courseCard(id: "262").tapUntil {
            CourseNavigation.announcements.exists
        }
        CourseNavigation.announcements.tap()

        XCTAssert(AnnouncementList.cell(index: 0).label().contains("Announcement Three"))
        XCTAssert(AnnouncementList.cell(index: 1).label().contains("Announcement Two"))
        XCTAssert(AnnouncementList.cell(index: 2).label().contains("Announcement One"))
    }

    func testViewAnnouncement() {
        Dashboard.courseCard(id: "262").tapUntil {
            CourseNavigation.announcements.exists
        }
        CourseNavigation.announcements.tap()

        AnnouncementList.cell(index: 0).tap()
        app.find(label: "This is the third announcement").waitToExist()
    }

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
