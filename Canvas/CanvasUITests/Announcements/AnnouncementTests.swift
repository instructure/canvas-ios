//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
import TestsFoundation

enum Announcements {
    static func announcement(index: Int) -> Element {
        return app.find(id: "announcements.list.announcement.row-\(index)")
    }
}

enum AnnouncementDetail {
    static var text: Element {
        return app.find(label: "This is the third announcement")
    }
}

class AnnouncementTest: CanvasUITests {
    func testAnnouncementsMatchWebOrder() {
        // Dashboard
        Dashboard.courseCard(id: "262").waitToExist()
        Dashboard.courseCard(id: "262").tap()

        // Course
        CourseNavigation.announcements.tap()

        // Announcements
        Announcements.announcement(index: 0).waitToExist()
        XCTAssert(Announcements.announcement(index: 0).label.contains("Announcement Three"))
        XCTAssert(Announcements.announcement(index: 1).label.contains("Announcement Two"))
        XCTAssert(Announcements.announcement(index: 2).label.contains("Announcement One"))
    }

    func testViewAnnouncement() {
        // Dashboard
        Dashboard.courseCard(id: "262").waitToExist()
        Dashboard.courseCard(id: "262").tap()

        // Course
        CourseNavigation.announcements.tap()

        // Announcements
        Announcements.announcement(index: 0).waitToExist()
        Announcements.announcement(index: 0).tapAt(.zero)

        AnnouncementDetail.text.waitToExist()
        XCTAssert(AnnouncementDetail.text.exists)
    }
}
