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
@testable import Core

class DiscussionReplyTests: CoreUITestCase {
    override var abstractTestClass: CoreUITestCase.Type { return DiscussionReplyTests.self }
    override var user: UITestUser? { return nil }

    lazy var course = mock(course: .make(
        permissions: .init(
            create_announcement: true,
            create_discussion_topic: true
    )))

    func mockDiscussion(allowAttachment: Bool? = true) -> APIDiscussionTopic {
        let discussId: ID = "1"
        let discussion = APIDiscussionTopic.make(
            id: discussId,
            message: "top message",
            html_url: URL(string: "/courses/\(course.id)/discussion_topics/\(discussId)"),
            permissions: .make(attach: allowAttachment)
        )
        mockData(ListDiscussionTopicsRequest(context: course), value: [discussion])
        mockData(GetTopicRequests(context: course, topicID: discussId.value), value: discussion)
        let fullTopic = APIDiscussionFullTopic.make()
        mockData(GetFullTopicRequests(context: course, topicID: discussId.value), value: fullTopic)
        mockData(ListDiscussionEntriesRequest(context: course, topicID: discussId.value), value: fullTopic.view)
        let readDiscussionUrl = URL(string: "https://canvas.instructure.com/api/v1/courses/\(course.id)/discussion_topics/\(discussId)/read")!
        mockURL(readDiscussionUrl, response: HTTPURLResponse(url: readDiscussionUrl, statusCode: 204, httpVersion: nil, headerFields: [:]))
        fullTopic.unread_entries.forEach {
            let url = URL(string: "https://canvas.instructure.com/api/v1/courses/\(course.id)/discussion_topics/\(discussId)/entries/\($0)/read")!
            mockURL(url, response: HTTPURLResponse(url: url, statusCode: 204, httpVersion: nil, headerFields: [:]))
        }
        return discussion
    }

    func mockCoursePermission(allowPost: Bool = true) {
        mockData(GetContextPermissionsRequest(context: course), value: .make(post_to_forum: allowPost))
    }

    func xtestUnreadMarkersCorrect() {
        mockBaseRequests()
        mockCoursePermission()
        let discussion = mockDiscussion()
        show("/courses/\(course.id)/discussion_topics/\(discussion.id)")

        XCTAssertTrue(DiscussionReply.replyUnread(id: "1").waitToExist(3).exists)
        XCTAssertFalse(DiscussionReply.replyUnread(id: "2").exists)
        XCTAssertTrue(DiscussionReply.replyUnread(id: "3").exists)
        XCTAssertTrue(DiscussionReply.replyUnread(id: "5").exists)
    }

    func helpTestViewReplies(expectReplyButtons: Bool) {
        let discussion = mockDiscussion()
        show("/courses/\(course.id)/discussion_topics/\(discussion.id)")
        app.find(label: discussion.message!).waitToExist()

        let messageLabels = ["m1", "m2", "m3", "m5"]
        var xs: [String: CGFloat] = [:]
        messageLabels.forEach {
            xs[$0] = app.find(label: $0).frame().minX
        }

        XCTAssertLessThan(xs["m1"]!, xs["m2"]!)
        XCTAssertLessThan(xs["m2"]!, xs["m3"]!)
        XCTAssertEqual(xs["m1"]!, xs["m5"]!)

        XCTAssertFalse(app.find(label: "m4 (deep)").exists)
        DiscussionReply.moreReplies.tap()
        app.find(label: "m4 (deep)").waitToExist()
        app.find(label: "Back to replies").tap()
        app.find(label: "m4 (deep)").waitToVanish()

        XCTAssertEqual(DiscussionReply.topReplyButton.exists, expectReplyButtons)
        XCTAssertEqual(DiscussionReply.replyButton(id: "1").exists, expectReplyButtons)
        XCTAssertEqual(DiscussionReply.replyButton(id: "2").exists, expectReplyButtons)
    }

    func testViewReplies() {
        mockBaseRequests()
        mockCoursePermission(allowPost: true)
        helpTestViewReplies(expectReplyButtons: true)
    }

    func testViewRepliesWithPostDisallowed() {
        mockBaseRequests()
        mockCoursePermission(allowPost: false)
        helpTestViewReplies(expectReplyButtons: false)
    }

    func testReplyingWithoutAttachment() {
        mockBaseRequests()
        mockCoursePermission()
        let discussion = mockDiscussion(allowAttachment: false)
        mockEncodableRequest("courses/\(course.id)/settings", value: ["allow_student_forum_attachments": false])
        show("/courses/\(course.id)/discussion_topics/\(discussion.id)")
        app.find(label: discussion.message!).waitToExist()

        mockData(PostDiscussionEntryRequest(context: course, topicID: "1", body: nil), value: .make())
        mockData(PostDiscussionEntryRequest(context: course, topicID: "1", body: nil, entryID: "2"), value: .make())

        let undoButton = app.find(id: "rich-text-toolbar-item-undo")

        DiscussionReply.topReplyButton.tap()
        undoButton.waitToExist()
        XCTAssertFalse(DiscussionEdit.attachmentButton.exists)
        NavBar.dismissButton.tap()
        undoButton.waitToVanish()

        DiscussionReply.topReplyButton.tap()
        DiscussionEditReply.doneButton.tapUntil {
            !DiscussionEditReply.doneButton.isVisible
        }

        DiscussionReply.replyButton(id: "2").tap()
        undoButton.waitToExist()
        XCTAssertFalse(DiscussionEditReply.attachmentButton.exists)
        DiscussionEditReply.doneButton.tapUntil {
            !DiscussionEditReply.doneButton.isVisible
        }
    }

    func testReplyingWithAttachment() {
        mockBaseRequests()
        mockCoursePermission()
        let discussion = mockDiscussion()
        show("/courses/\(course.id)/discussion_topics/\(discussion.id)")
        app.find(label: discussion.message!).waitToExist()

        mockData(PostDiscussionEntryRequest(context: course, topicID: "1", body: nil), value: .make())
        DiscussionReply.topReplyButton.tap()
        DiscussionEditReply.attachmentButton.tap()

        Attachments.addButton.tap()
        allowAccessToPhotos {
            app.find(label: "Choose From Library").tap()
        }

        let photo = app.find(labelContaining: "Photo, ")
        app.find(label: "All Photos").tapUntil { photo.exists }
        photo.tap()

        app.find(label: "Upload complete").waitToExist()
        let img = app.images["AttachmentView.image"]
        app.find(label: "Upload complete").tapUntil { img.exists == true }
        NavBar.dismissButton.tap()

        Attachments.dismissButton.tap()

        app.webViews.firstElement.typeText("Here's a nice picture I took")
        DiscussionEditReply.doneButton.tapUntil {
            !DiscussionEditReply.doneButton.isVisible
        }
    }
}
