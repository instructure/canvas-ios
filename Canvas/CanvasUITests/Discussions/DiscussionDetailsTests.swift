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

class DiscussionDetailsTests: CanvasUITests {
    override func setUp() {
        super.setUp()
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.discussions.tap()
        DiscussionListCell.graded.waitToExist()
    }

    func testPreviewAttachment() {
        DiscussionListCell.graded.tapUntil {
            DiscussionDetails.attachmentButton.exists
        }

        DiscussionDetails.attachmentButton.tap()
        app.find(id: "attachment-view.share-btn").waitToExist()
    }

    func testLinks() {
        DiscussionListCell.simple.tapUntil {
            app.find(label: "Posted to All Sections").exists
        }

        app.find(label: "Assignment One", type: .link).tap()
        app.find(label: "This is assignment one.").waitToExist()
        NavBar.backButton.tap()

        app.find(label: "Page Module", type: .link).tap()
        app.find(label: "ITEMS").waitToExist()
        NavBar.backButton.tap()

        app.find(label: "Syllabus", type: .link).tap()
        app.find(label: "Course Syllabus").waitToExist()
        NavBar.backButton.tap()

        app.swipeUp()

        app.find(label: "Files", type: .link).tap()
        FilesList.file(id: "10528").waitToExist()
        NavBar.backButton.tap()

        app.find(label: "Announcements", type: .link).tap()
        app.find(label: "Announcements, Assignments").waitToExist()
        NavBar.backButton.tap()

        app.find(label: "Quiz One", type: .link).tap()
        app.find(label: "This is the first quiz.").waitToExist()
    }
}
