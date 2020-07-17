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

class DiscussionDetailsE2ETests: CoreUITestCase {
    override var abstractTestClass: CoreUITestCase.Type { return DiscussionDetailsE2ETests.self }

    override func setUp() {
        super.setUp()
        Dashboard.courseCard(id: "263").tapUntil {
            CourseNavigation.discussions.exists
        }
        CourseNavigation.discussions.tap()
        DiscussionListCell.graded.waitToExist()
    }

    func testPreviewAttachment() {
        let attachmentLink = app.find(label: "xcode-black.png", type: .link)
        DiscussionListCell.graded.tapUntil {
            attachmentLink.exists
        }

        attachmentLink.tap()
        FileDetails.shareButton.waitToExist()
    }

    func xtestLinks() {
        setAnimationsEnabled(true)

        DiscussionListCell.simple.tapUntil {
            app.find(label: "Posted to All Sections").exists
        }

        app.find(label: "Assignment One", type: .link).tap()
        app.find(label: "This is assignment one.").waitToExist()
        NavBar.backButton.tap()

        app.find(label: "Page Module", type: .link).tap()
        app.find(label: "Page One").waitToExist()
        NavBar.backButton.tap()

//        app.find(label: "Syllabus", type: .link).tap()
//        app.find(label: "Course Syllabus").waitToExist()
//        NavBar.backButton.tap()

        app.swipeUp()

        app.find(label: "Files", type: .link).tap()
        FilesList.file(id: "10528").waitToExist()
        NavBar.backButton.tap()

        app.find(label: "Announcements", type: .link).tap()
        app.find(label: "Announcements, Assignments").waitToExist()
        NavBar.backButton.tap()

        app.find(label: "Quiz One", type: .link).tap()
        app.find(label: "This is the first quiz.").waitToExist()

        setAnimationsEnabled(false)
    }
}
