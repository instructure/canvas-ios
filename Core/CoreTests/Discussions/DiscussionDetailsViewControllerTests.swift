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

import XCTest
import WebKit
@testable import Core
import TestsFoundation

class DiscussionDetailsViewControllerTests: CoreTestCase {
    let course = ContextModel(.course, id: "1")
    lazy var controller = DiscussionDetailsViewController.create(context: course, topicID: "1")

    let emptyResponse = HTTPURLResponse(url: URL(string: "/")!, statusCode: 204, httpVersion: nil, headerFields: nil)

    var baseURL: URL { environment.api.baseURL }
    let webView = MockWebView()
    class MockWebView: CoreWebView {
        var html: String = ""
        override func loadHTMLString(_ string: String, baseURL: URL? = AppEnvironment.shared.currentSession?.baseURL) -> WKNavigation? {
            html = string
            return super.loadHTMLString(string, baseURL: baseURL)
        }

        var jsResult: Any?
        var jsError: Error?
        override func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)? = nil) {
            completionHandler?(jsResult, jsError)
        }
    }

    override func setUp() {
        super.setUp()
        environment.mockStore = false
        controller.webView = webView
        api.mock(controller.colors, value: .init(custom_colors: [
            "course_1": "#008",
            "group_1": "#080",
        ]))
        api.mock(GetAssignment(courseID: "1", assignmentID: "1"), value: .make(points_possible: 95))
        api.mock(controller.course, value: .make())
        api.mock(controller.entries, value: .make(
            participants: [
                .make(id: 2, display_name: "Bob"),
                .make(id: 3, display_name: "Ruth"),
                .make(id: 4, display_name: "Dale"),
            ],
            unread_entries: [4],
            forced_entries: [2],
            view: [
                .make(id: 1, user_id: 2, message: """
                <p>Cube rule all the way.</p>
                <p>Oreos are sandwiches.</p>
                """, replies: [
                    .make(id: 100, user_id: 3, parent_id: 1, deleted: true),
                    .make(id: 2, user_id: 3, parent_id: 1, message: "I disagree.", replies: [
                        .make(id: 3, user_id: 2, parent_id: 2, message: "Why?"),
                    ]),
                ]),
            ],
            new_entries: [
                .make(id: 4, user_id: 4, parent_id: 3, message: "Hot Pockets claim to be sandwiches"),
            ]
        ))
        api.mock(controller.group, value: .make(course_id: 1))
        api.mock(GetGroups(context: controller.context), value: [ .make(course_id: 1) ])
        api.mock(controller.permissions, value: .make(post_to_forum: true))
        api.mock(controller.topic, value: .make(
            id: 1,
            assignment_id: 1,
            title: "What is a sandwich?",
            message: "<p>Is the cube rule of food valid? What's your take?</p>",
            html_url: baseURL.appendingPathComponent("courses/1/discussion_topics/1"),
            posted_at: DateComponents(calendar: .current, year: 2020, month: 5, day: 7, hour: 8, minute: 35).date,
            published: true,
            attachments: [.make()],
            author: .make(display_name: "Instructor", pronouns: "she/her"),
            permissions: .make(attach: true, update: true, reply: true, delete: true),
            allow_rating: true,
            sort_by_rating: true
        ))
    }

    func testLayout() {
        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(nav.navigationBar.barTintColor?.hexString, "#000088")
        XCTAssertEqual(controller.titleSubtitleView.title, "Discussion Details")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Course One")
        XCTAssertEqual(controller.titleLabel.text, "What is a sandwich?")
        XCTAssertEqual(controller.pointsLabel.text, "95 pts")
        XCTAssertEqual(controller.pointsView.isHidden, false)
        XCTAssertEqual(controller.publishedView.isHidden, true)

        XCTAssertEqual(controller.maxDepth, controller.view.traitCollection.horizontalSizeClass == .compact ? 2 : 4)
        XCTAssert(webView.html.contains("Instructor (she/her)"))
        XCTAssert(webView.html.contains("May 7, 2020 at 8:35 AM"))
        XCTAssert(webView.html.contains("Is the cube rule of food valid?"))
        XCTAssert(webView.html.contains("Bob"))
        XCTAssert(webView.html.contains("Oreos are sandwiches."))
        XCTAssert(webView.html.contains("Ruth"))
        XCTAssert(webView.html.contains("Deleted this reply."))
        XCTAssert(webView.html.contains("I disagree"))
        XCTAssert(webView.html.contains("Why?"))
        XCTAssert(webView.html.contains("View more replies"))

        var link = baseURL.appendingPathComponent("courses/1/assignments/2")
        XCTAssertEqual(webView.linkDelegate?.handleLink(link), true)
        XCTAssert(router.lastRoutedTo(link, withOptions: .noOptions))

        link = baseURL.appendingPathComponent("courses/1/discussion_topics/1/reply")
        XCTAssertEqual(webView.linkDelegate?.handleLink(link), true)
        XCTAssert(router.lastRoutedTo(link, withOptions: .modal(.formSheet, isDismissable: false, embedInNav: true)))

        link = baseURL.appendingPathComponent("courses/1/discussion_topics/1/entries/1/replies")
        XCTAssertEqual(webView.linkDelegate?.handleLink(link), true)
        XCTAssert(router.lastRoutedTo(link, withOptions: .modal(.formSheet, isDismissable: false, embedInNav: true)))

        link = baseURL.appendingPathComponent("courses/1/discussion_topics/1/unknown")
        XCTAssertEqual(webView.linkDelegate?.handleLink(link), true)
        XCTAssert(router.lastRoutedTo(link, withOptions: .noOptions))

        link = baseURL.appendingPathComponent("courses/1/discussion_topics/1/replies/3")
        XCTAssertEqual(webView.linkDelegate?.handleLink(link), true)
        let web = router.viewControllerCalls.last?.0 as? CoreWebViewController
        let titleView = web?.navigationItem.titleView as? TitleSubtitleView
        XCTAssert(web?.webView.linkDelegate === controller)
        XCTAssertEqual(titleView?.title, "Discussion Replies")
        XCTAssertEqual(titleView?.subtitle, "Course One")

        XCTAssert(controller.optionsButton == controller.navigationItem.rightBarButtonItem)
        _ = controller.optionsButton.target?.perform(controller.optionsButton.action)
        var sheet = router.presented as? BottomSheetPickerViewController
        XCTAssertEqual(sheet?.actions.count, 4)

        XCTAssertEqual(sheet?.actions[0].title, "Mark All as Read")
        api.mock(MarkDiscussionEntriesReadRequest(context: course, topicID: "1", isRead: true, isForcedRead: true), response: emptyResponse)
        sheet?.actions[0].action()
        XCTAssert(!webView.html.contains("Unread"))
        XCTAssertEqual(sheet?.actions[1].title, "Mark All as Unread")
        sheet?.actions[1].action()
        XCTAssert(webView.html.contains("Unread"))

        XCTAssertEqual(sheet?.actions[2].title, "Edit")
        sheet?.actions[2].action()
        XCTAssert(router.lastRoutedTo(.parse("courses/1/discussion_topics/1/edit")))

        api.mock(DeleteDiscussionTopicRequest(context: course, topicID: "1"), error: NSError.internalError())
        XCTAssertEqual(sheet?.actions[3].title, "Delete")
        sheet?.actions[3].action()
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Internal Error")

        api.mock(RateDiscussionEntry(context: course, topicID: "1", entryID: "1", isLiked: true), response: emptyResponse)
        // Too hard to simulate the webView handler
        controller.like("1", isLiked: true)
        XCTAssert(webView.html.contains("1 like"))

        environment.app = .teacher // to make sure we get all the options
        controller.showMoreOptions(for: "1")
        sheet = router.presented as? BottomSheetPickerViewController
        XCTAssertEqual(sheet?.actions.count, 3)

        api.mock(MarkDiscussionEntryReadRequest(context: course, topicID: "1", entryID: "1", isRead: true, isForcedRead: true), response: emptyResponse)
        XCTAssertEqual(sheet?.actions[0].title, "Mark as Read")
        XCTAssertNoThrow(sheet?.actions[0].action())

        controller.showMoreOptions(for: "1")
        sheet = router.presented as? BottomSheetPickerViewController
        XCTAssertEqual(sheet?.actions[0].title, "Mark as Unread")
        XCTAssertNoThrow(sheet?.actions[0].action())

        XCTAssertEqual(sheet?.actions[1].title, "Edit")
        sheet?.actions[1].action()
        XCTAssert(router.presented is DiscussionReplyViewController)

        api.mock(DeleteDiscussionEntryRequest(context: course, topicID: "1", entryID: "1"), error: NSError.internalError())
        XCTAssertEqual(sheet?.actions[2].title, "Delete")
        sheet?.actions[2].action()
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Internal Error")

        controller.scrollView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.refreshControl.isRefreshing, false)

        XCTAssertNoThrow(controller.viewWillDisappear(false))
    }

    func testAutomaticRead() {
        controller.view.layoutIfNeeded()
        api.mock(MarkDiscussionEntryReadRequest(context: course, topicID: "1", entryID: "4", isRead: true, isForcedRead: false), response: emptyResponse)
        controller.loaded()
        XCTAssertNotNil(controller.readTimer)
        webView.jsResult = [ "2", "4" ]
        controller.readTimer?.fire()
        XCTAssert(!webView.html.contains("Unread"))
    }

    func testStudentGroupTopic() {
        environment.app = .student
        let course = controller.context
        let group = ContextModel(.group, id: "1")
        api.mock(GetDiscussionView(context: course, topicID: "1"), value: .make(
            participants: [],
            unread_entries: [],
            forced_entries: [],
            view: []
        ))
        api.mock(GetDiscussionView(context: group, topicID: "2"), value: .make(
            participants: [
                .make(id: 2, display_name: "Bob"),
            ],
            unread_entries: [4],
            forced_entries: [2],
            view: [
                .make(id: 1, user_id: 2, message: """
                <p>Cube rule all the way.</p>
                <p>Oreos are sandwiches.</p>
                """),
            ]
        ))
        api.mock(GetContextPermissions(context: group, permissions: [ .postToForum ]), value: .make(post_to_forum: true))
        api.mock(GetDiscussionTopic(context: course, topicID: "1"), value: .make(
            id: 1,
            assignment_id: 1,
            title: "What is a sandwich?",
            group_category_id: 7,
            group_topic_children: [ .make(id: "2", group_id: "1") ]
        ))
        api.mock(GetDiscussionTopic(context: group, topicID: "2"), value: .make(
            id: 2,
            assignment_id: 1,
            title: "What is a sandwich? - Group One",
            message: "<p>Is the cube rule of food valid? What's your take?</p>",
            html_url: baseURL.appendingPathComponent("groups/1/discussion_topics/2")
        ))
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.context.canvasContextID, group.canvasContextID)
        XCTAssertEqual(controller.topicID, "2")
        XCTAssert(webView.html.contains("Is the cube rule of food valid?"))
        XCTAssert(webView.html.contains("Bob"))
        XCTAssert(webView.html.contains("Oreos are sandwiches."))
    }

    func testTeacherGroupTopic() {
        environment.app = .teacher
        api.mock(controller.entries, value: .make(
            participants: [],
            unread_entries: [],
            forced_entries: [],
            view: []
        ))
        api.mock(controller.topic, value: .make(
            id: 1,
            assignment_id: 1,
            title: "What is a sandwich?",
            group_category_id: 7,
            group_topic_children: [ .make(id: "2", group_id: "1") ]
        ))
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.context.canvasContextID, "course_1")
        XCTAssertEqual(controller.topicID, "1")
        XCTAssert(webView.html.contains("each group has its own conversation"))
        XCTAssert(webView.html.contains("Group One"))
        XCTAssert(webView.html.contains("/groups/1/discussion_topics/2"))
    }
}
