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

class DeepLinkE2ETests: CoreUITestCase {
    override func setUp() {
        super.setUp()

        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tapUntil {
            CourseNavigation.pages.exists()
        }
        CourseNavigation.pages.tapUntil {
            PageList.page(index: 0).exists()
        }
        PageList.page(index: 0).tap()
        sleep(1)
    }

    func testDeepLinkToGroupAnnouncements() {
        app.find(labelContaining: "group-announcements").tap()
        app.find(labelContaining: "It looks like announcements haven’t been created in this space yet.").waitToExist()
    }

    func testDeepLinkToGroup() {
        app.find(labelContaining: "group-home").tap()
        app.find(labelContaining: "Home").waitToExist()
    }

    func testDeepLinkToPublicCourse() {
        app.find(labelContaining: "public-course-page").tap()
        app.find(labelContaining: "this is a public course").waitToExist()
    }

    func testDeepLinkToDiscussion() {
        app.find(labelContaining: "discussion").tap()
        app.find(labelContaining: "A discussion").waitToExist()
    }

}
