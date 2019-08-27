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

    let course1 = APICourse.make(id: "1",
        enrollments: [.make(type: "StudentEnrollment")], permissions: .init(
            create_announcement: true,
            create_discussion_topic: true
    ))
    let noReplyCourse = APICourse.make(id: "2", name: "noReplyCourse", course_code: "C2", enrollments: [.make(type: "TeacherEnrollment")], permissions: .init(
            create_announcement: false,
            create_discussion_topic: false
    ))

    func discussion1(_ course: APICourse) -> APIDiscussionTopic {
        return .make(
                id: "1",
                message: "top message",
                html_url: URL(string: "/courses/\(course.id)/discussion_topics/1")
        )
    }

    override func setUp() {
        super.setUp()
        mockBaseRequests(courseIDs: [course1.id, noReplyCourse.id])

        mockData(GetContextPermissionsRequest(context: ContextModel(.course, id: course1.id.value)), value: .make(post_to_forum: true))
        mockData(GetContextPermissionsRequest(context: ContextModel(.course, id: noReplyCourse.id.value)), value: .make())

        for course in [course1, noReplyCourse] {
            mockData(GetEnabledFeatureFlagsRequest(context: ContextModel(.course, id: course.id.value)), value: [])
            let discussion = discussion1(course)
            let discussId = discussion.id.value
            mockData(GetCourseRequest(courseID: course.id), value: course)
            mockData(ListDiscussionTopicsRequest(context: course), value: [discussion])
            mockData(GetTopicRequests(context: course, topicID: discussId), value: discussion)
            let fullTopic = APIDiscussionFullTopic.make()
            mockData(GetFullTopicRequests(context: course, topicID: discussId), value: fullTopic)
            mockData(ListDiscussionEntriesRequest(context: course, topicID: discussId), value: fullTopic.view)
            fullTopic.unread_entries.forEach {
                let url = URL(string: "https://canvas.instructure.com/api/v1/courses/\(course.id)/discussion_topics/\(discussId)/entries/\($0)/read")!
                mockDataRequest(URLRequest(url: url), response: HTTPURLResponse(url: url, statusCode: 204, httpVersion: nil, headerFields: [:]))
            }
        }

        logIn()
    }

    func xtestViewReplies() {
        for course in [noReplyCourse, course1] {
            logIn()
            show("/courses/\(course.id)/discussion_topics/1")
            app.find(label: discussion1(course).message!).waitToExist()

            let messageLabels = ["m1", "m2", "m3", "m5"]
            var xs: [String: CGFloat] = [:]
            messageLabels.forEach {
                xs[$0] = app.find(label: $0).frame.minX
            }

            XCTAssertLessThan(xs["m1"]!, xs["m2"]!)
            XCTAssertLessThan(xs["m2"]!, xs["m3"]!)
            XCTAssertEqual(xs["m1"]!, xs["m5"]!)

            // BUG: These are failing in very weird ways... probably a bug
            continueAfterFailure = true
            XCTAssertTrue(DiscussionReply.replyUnread(id: "1").waitToExist(3).exists)
            XCTAssertFalse(DiscussionReply.replyUnread(id: "2").exists)
            XCTAssertTrue(DiscussionReply.replyUnread(id: "3").exists)
            XCTAssertTrue(DiscussionReply.replyUnread(id: "5").exists)
            continueAfterFailure = false

            XCTAssertFalse(app.find(label: "m4 (deep)").exists)
            DiscussionReply.moreReplies.tap()
            app.find(label: "m4 (deep)").waitToExist()
            app.find(label: "Back to replies").tap()
            app.find(label: "m4 (deep)").waitToVanish()

            // BUG: These fails if noReplyCourse is run before course1... probably a bug
            continueAfterFailure = true
            let expectReplyButtons = (course != noReplyCourse)
            XCTAssertEqual(DiscussionReply.topReplyButton.exists, expectReplyButtons)
            XCTAssertEqual(DiscussionReply.replyButton(id: "1").exists, expectReplyButtons)
            XCTAssertEqual(DiscussionReply.replyButton(id: "2").exists, expectReplyButtons)
            continueAfterFailure = false
        }
    }

    func testReplyingWithoutAttachment() {
        mockEncodableRequest("courses/\(course1.id)/settings", value: ["allow_student_forum_attachments": false])
        logIn()
        show("/courses/\(course1.id)/discussion_topics/1")
        app.find(label: discussion1(course1).message!).waitToExist()

        mockData(PostDiscussionEntryRequest(context: course1, topicID: 1, body: nil), value: .make())
        mockData(PostDiscussionEntryRequest(context: course1, topicID: 1, body: nil, entryID: 2), value: .make())

        let undoButton = app.find(id: "rich-text-toolbar-item-undo")

        DiscussionReply.topReplyButton.tap()
        undoButton.waitToExist()
        XCTAssertFalse(DiscussionEdit.attachmentButton.exists)
        NavBar.dismissButton.tap()
        undoButton.waitToVanish()

        DiscussionReply.topReplyButton.tap()
        undoButton.waitToExist()
        DiscussionReply.replyDone.tap()
        undoButton.waitToVanish()

        DiscussionReply.replyButton(id: "2").tap()
        undoButton.waitToExist()
        XCTAssertFalse(DiscussionEdit.attachmentButton.exists)
        DiscussionReply.replyDone.tap()
        undoButton.waitToVanish()
    }

    func xtestReplyingWithAttachment() {
        mockEncodableRequest("courses/\(course1.id)/settings", value: ["allow_student_forum_attachments": true])
        logIn()
        show("/courses/1/discussion_topics/1")
        app.find(label: discussion1(course1).message!).waitToExist()

        mockData(PostDiscussionEntryRequest(context: course1, topicID: 1, body: nil), value: .make())
        DiscussionReply.topReplyButton.tap()
        // BUG: Why isn't it requesting courses/1/settings?
        DiscussionEdit.attachmentButton.tap()

        sleep(100)
    }
}
