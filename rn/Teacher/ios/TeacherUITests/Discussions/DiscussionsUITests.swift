//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import Core

class DiscussionsUITests: MiniCanvasUITestCase {
    lazy var discussion = firstCourse.discussions[0]
    let entry = MiniDiscussion.Entry(.make())

    override func setUp() {
        super.setUp()
    }

    func testEditTopic() {
        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.discussions.tap()
        DiscussionListCell.cell(id: discussion.id).tap()

        DiscussionDetails.options.tap()
        DiscussionDetails.edit.tap()

        XCTAssertEqual(DiscussionEdit.titleField.value(), discussion.api.title)
        DiscussionEdit.titleField.cutText().typeText("new title")
        app.webViews.staticTexts.lastElement.cutText()
        app.webViews.lastElement.typeText("HELLO!")
        DiscussionEdit.doneButton.tap()

        // TODO: remove after MBL-14509 is fixed
        pullToRefresh()

        XCTAssertEqual(DiscussionDetails.title.label(), "new title")
        XCTAssertEqual(discussion.api.title, "new title")
        XCTAssertEqual(discussion.api.message, "HELLO!")
    }

    func testEditReply() {
        discussion.entries = [entry]

        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.discussions.tap()
        DiscussionListCell.cell(id: discussion.id).tap()

        app.webViews.buttons["Show more options"].tap()
        DiscussionDetails.edit.tap()

        RichContentEditor.webView.cutText()
        RichContentEditor.webView.typeText("This is a better reply")

        let expectation = MiniCanvasServer.shared.expectationFor(request:
            PutDiscussionEntryRequest(context: .course(firstCourse.id), topicID: discussion.id, entryID: entry.id, message: "")
        )
        DiscussionEditReply.sendButton.tap()
        wait(for: [expectation], timeout: 5)

        XCTAssertEqual(discussion.entries.map(\.api.message), ["This is a better reply"])
    }

    func testCloseDiscussion() throws {
        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.discussions.tap()
        DiscussionListCell.cell(id: discussion.id).tap()

        DiscussionDetails.options.tap()
        DiscussionDetails.edit.tap()
        DiscussionEdit.lockAtButton.tap()

        let expectation = MiniCanvasServer.shared.expectationFor(request: PutDiscussionTopicRequest(context: .course(firstCourse.id), topicID: discussion.id))
        DiscussionEdit.doneButton.tap()
        wait(for: [expectation], timeout: 5)

        // check that lock_at was a valid date
        let lockAtData = try XCTUnwrap(expectation.lastRequest?.parseMultiPartFormData().first(where: { $0.name == "lock_at" })?.body)
        XCTAssertNotNil(Date(fromISOString: String(bytes: lockAtData, encoding: .utf8)!, formatOptions: .withFractionalSeconds))

        discussion.api.locked = true

        NavBar.backButton.tap()
        app.find(label: "Closed for Comments").waitToExist()
    }

    func testNoDiscussions() {
        firstCourse.discussions = []

        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.discussions.tap()

        app.find(label: "There are no discussions to display.").waitToExist()
    }
}
