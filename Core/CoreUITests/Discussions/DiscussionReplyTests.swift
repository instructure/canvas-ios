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
    override var abstractTestClass: CoreUITestCase.Type { DiscussionReplyTests.self }
    override var user: UITestUser? { nil }

    lazy var course = mock(course: .make(
        permissions: .init(
            create_announcement: true,
            create_discussion_topic: true
    )))

    var markedAsRead: [ID: Bool] = [:]

    @discardableResult
    func mockDiscussion(_ discussion: APIDiscussionTopic = .make(), fullTopic: APIDiscussionView = .make()) -> APIDiscussionTopic {
        mockData(ListDiscussionTopicsRequest(context: .course(course.id.value)), value: [discussion])
        mockData(GetDiscussionTopicRequest(context: .course(course.id.value), topicID: discussion.id.value), value: discussion)
        mockData(GetDiscussionViewRequest(context: .course(course.id.value), topicID: discussion.id.value), value: fullTopic)
        mockData(GetGroupsRequest(context: .course(course.id.value)), value: [])
        mockData(MarkDiscussionTopicReadRequest(context: .course(course.id.value), topicID: discussion.id.value, isRead: true), value: APINoContent())
        fullTopic.unread_entries.forEach { entry in
            mockData(MarkDiscussionEntryReadRequest(context: .course(course.id.value), topicID: discussion.id.value, entryID: entry.value, isRead: true, isForcedRead: false)) { [weak self] request in
                self?.markedAsRead[entry] = true
                return MockHTTPResponse(http: HTTPURLResponse(url: request.url!, statusCode: 204, httpVersion: nil, headerFields: [:]))
            }
        }
        return discussion
    }

    func mockCoursePermission(allowPost: Bool = true) {
        mockData(GetContextPermissionsRequest(context: .course(course.id.value), permissions: [.postToForum]), value: .make(post_to_forum: allowPost))
    }

//    func xtestUnreadMarkersCorrect() {
//        mockBaseRequests()
//        mockCoursePermission()
//        let discussion = mockDiscussion()
//        show("/courses/\(course.id)/discussion_topics/\(discussion.id)")
//        app.swipeDown()
//
//        XCTAssertTrue(DiscussionReply.unread(id: "1").waitToExist(3).exists)
//        XCTAssertFalse(DiscussionReply.unread(id: "2").exists)
//        XCTAssertTrue(DiscussionReply.unread(id: "3").exists)
//        XCTAssertTrue(DiscussionReply.unread(id: "5").exists)
//    }

    func helpTestViewReplies(repliesEnabled: Bool) {
        let discussion = mockDiscussion(.make(permissions: .make(reply: repliesEnabled)))
        show("/courses/\(course.id)/discussion_topics/\(discussion.id)")
        app.swipeDown()
        app.find(label: discussion.message!).waitToExist()

        let messageLabels = ["m1", "m2", "m3", "m5"]
        var xs: [String: CGFloat] = [:]
        messageLabels.forEach {
            xs[$0] = app.find(label: $0).frame().minX
        }

        XCTAssertLessThan(xs["m1"]!, xs["m2"]!)
        XCTAssertLessThan(xs["m2"]!, xs["m3"]!)
        XCTAssertEqual(xs["m1"]!, xs["m5"]!)

        app.swipeUp()
        XCTAssertFalse(app.find(label: "m4 (deep)").exists)
        app.find(label: "View more replies").tap()
        app.find(label: "m4 (deep)").waitToExist()

        app.find(label: "Back").tap()
        app.find(label: "m4 (deep)").waitToVanish()

        XCTAssertEqual(app.find(label: "Reply", type: .link).allElements.count, repliesEnabled ? 5 : 0)
    }

    func testViewReplies() {
        mockBaseRequests()
        mockCoursePermission(allowPost: true)
        helpTestViewReplies(repliesEnabled: true)
    }

    func testViewRepliesWithPostDisallowed() {
        mockBaseRequests()
        mockCoursePermission(allowPost: false)
        helpTestViewReplies(repliesEnabled: false)
    }

    func testReplyingWithoutAttachment() {
        mockBaseRequests()
        mockCoursePermission()
        let discussion = mockDiscussion(.make(permissions: .make(reply: true)))
        mockEncodableRequest("courses/\(course.id)/settings", value: ["allow_student_forum_attachments": false])
        show("/courses/\(course.id)/discussion_topics/\(discussion.id)")
        app.swipeDown()
        app.find(label: discussion.message!).waitToExist()

        mockData(PostDiscussionEntryRequest(context: .course(course.id.value), topicID: "1", message: ""), value: .make())
        mockData(PostDiscussionEntryRequest(context: .course(course.id.value), topicID: "1", entryID: "2", message: ""), value: .make())

        app.find(label: "Reply", type: .link).tap()
        DiscussionEditReply.sendButton.waitToExist()
        XCTAssertFalse(DiscussionEdit.attachmentButton.exists)
        NavBar.dismissButton.tap()
        DiscussionEditReply.sendButton.waitToVanish()

        app.find(label: "Reply", type: .link).tap()
        RichContentEditor.webView.typeText("hello!")
        DiscussionEditReply.sendButton.tapUntil {
            !DiscussionEditReply.sendButton.isVisible
        }

        app.find(label: "Reply", type: .link)[2].tap()
        DiscussionEditReply.sendButton.waitToExist()
        XCTAssertFalse(DiscussionEditReply.attachmentButton.exists)
        RichContentEditor.webView.typeText("hello!")
        DiscussionEditReply.sendButton.tapUntil {
            !DiscussionEditReply.sendButton.isVisible
        }
    }

    // blocked on MBL-14459
    func xtestReplyingWithAttachment() {
        mockBaseRequests()
        mockCoursePermission()
        let discussion = mockDiscussion(APIDiscussionTopic.make(permissions: .make(attach: true, reply: true)))
        show("/courses/\(course.id)/discussion_topics/\(discussion.id)")
        app.swipeDown()
        app.find(label: discussion.message!).waitToExist()

        mockData(PostDiscussionEntryRequest(context: .course(course.id.value), topicID: "1", message: ""), value: .make())
        app.find(label: "Reply", type: .link).tap()
        DiscussionEditReply.attachmentButton.tap()

//        Attachments.addButton.tap()
        allowAccessToPhotos {
            app.find(label: "Photo Library").tap()
        }

        let photo = app.find(labelContaining: "Photo, ")
        app.find(label: "All Photos").tapUntil { photo.exists }
        photo.tap()

        app.find(label: "Upload complete").waitToExist()
        let img = app.find(id: "AttachmentView.image")
        app.find(label: "Upload complete").tapUntil { img.exists == true }
        NavBar.dismissButton.tap()

        Attachments.dismissButton.tap()

        RichContentEditor.editor.typeText("Here's a nice picture I took")
        DiscussionEditReply.sendButton.tapUntil {
            !DiscussionEditReply.sendButton.isVisible
        }
    }

    func testLikeReply() throws {
        mockBaseRequests()
        mockCoursePermission()
        let topic = APIDiscussionTopic.make(allow_rating: true)
        var view = APIDiscussionView.make()
        mockDiscussion(topic, fullTopic: view)
        show("/courses/\(course.id)/discussion_topics/\(topic.id)")
        app.swipeDown()

        for entry in 1...5 {
            mockData(PostDiscussionEntryRatingRequest(context: .course(course.id.value), topicID: topic.id.value, entryID: "\(entry)", isLiked: true)) { [weak self] _ in
                view.entry_ratings["\(entry)"] = 1 - (view.entry_ratings["\(entry)"] ?? 0)
                self?.mockDiscussion(topic, fullTopic: view)
                return MockHTTPResponse.noContent
            }
        }

        func sliceFrom<S: Sequence>(_ sequence: S, start: S.Element, maxLength: Int) -> [S.Element]? where S.Element: Equatable {
            let foo = sequence.drop { $0 != start }
            return .init(foo.prefix(maxLength))
        }

        let webView = app.webViews.firstElement
        waitUntil { webView.orderedLabels()?.contains("m5") == true }
        webView.swipeUp()
        XCTAssert(webView.containsLabelSequence(["m1", "Show more options", "1 like", "Like"]))
        XCTAssert(webView.containsLabelSequence(["m2", "Show more options", "Like"]))
        XCTAssert(webView.containsLabelSequence(["m3", "Show more options", "3 likes", "Like"]))
        XCTAssert(webView.containsLabelSequence(["m5", "Show more options", "1 like", "Like"]))

        webView.rawElement.find(label: "Like").allElements.forEach { $0.tap() }

        waitUntil { webView.containsLabelSequence(["m1", "Show more options", "2 likes", "Like"]) }
        waitUntil { webView.containsLabelSequence(["m2", "Show more options", "1 like", "Like"]) }
        waitUntil { webView.containsLabelSequence(["m3", "Show more options", "2 likes", "Like"]) }
        waitUntil { webView.containsLabelSequence(["m5", "Show more options", "Like"]) }
    }

    func testRepliesMarkedAsReadOnScroll() {
        mockBaseRequests()
        mockCoursePermission()
        let messageIds = (10...15).map(ID.init)
        let discussion = mockDiscussion(
            APIDiscussionTopic.make(id: 42),
            fullTopic: APIDiscussionView.make(
                unread_entries: messageIds,
                view: messageIds.map { APIDiscussionEntry.make(id: $0, message: "reply \($0)") }
            )
        )
        show("/courses/\(course.id)/discussion_topics/\(discussion.id)")
        app.swipeDown()

        app.find(label: "reply 10").waitToExist()

        waitUntil {
            sleep(2)
            app.swipeUp()
            return messageIds.allSatisfy { markedAsRead[$0] == true }
        }
    }
}
