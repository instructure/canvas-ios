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
    let course = Context(.course, id: "1")
    lazy var controller = DiscussionDetailsViewController.create(context: course, topicID: "1")

    let emptyResponse = HTTPURLResponse(url: URL(string: "/")!, statusCode: 204, httpVersion: nil, headerFields: nil)
    let unread = "class=\"\(DiscussionHTML.Styles.unread)\""

    var baseURL: URL { environment.api.baseURL }
    let webView = MockWebView(features: [])
    class MockWebView: CoreWebView {
        @objc var runningCount = 0
        override func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)? = nil) {
            runningCount += 1
            super.evaluateJavaScript(javaScriptString) { result, error in
                self.runningCount -= 1
                completionHandler?(result, error)
            }
        }
    }

    func waitForWebView() {
        let webView = self.webView
        let exp = expectation(for: NSPredicate(key: #keyPath(MockWebView.runningCount), equals: 0), evaluatedWith: webView) { () -> Bool in
            webView.url != nil && !webView.isLoading
        }
        wait(for: [exp], timeout: 9)
    }

    func getBodyHTML() -> String {
        waitForWebView()
        var html = ""
        let exp = expectation(description: "getBodyHTML")
        webView.evaluateJavaScript("document.body.innerHTML") { result, error in
            if let result = result as? String { html = result }
            XCTAssertNil(error)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 9)
        return html
    }

    override func setUp() {
        super.setUp()
        controller.webView = webView
        api.mock(controller.colors, value: .init(custom_colors: [
            "course_1": "#008",
            "group_1": "#080",
        ]))
        let assignment = APIAssignment.make(points_possible: 95)
        api.mock(GetAssignment(courseID: "1", assignmentID: "1"), value: assignment)
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
                    .make(id: 2, user_id: 3, parent_id: 1, message: "<link rel=\"stylesheet\"><script src=\"foo.js\"></script><p>I disagree.</p>", replies: [
                        .make(id: 3, user_id: 2, parent_id: 2, message: "Why?"),
                    ]),
                ]),
            ],
            new_entries: [
                .make(id: 4, user_id: 4, parent_id: 3, message: "Hot Pockets claim to be sandwiches"),
            ]
        ))
        api.mock(controller.group, value: .make(course_id: 1))
        api.mock(controller.groups, value: [ .make(course_id: 1) ])
        api.mock(controller.permissions, value: .make(post_to_forum: true))
        api.mock(controller.topic, value: .make(
            allow_rating: true,
            assignment: assignment,
            assignment_id: 1,
            attachments: [.make()],
            author: .make(display_name: "Instructor", pronouns: "she/her"),
            html_url: baseURL.appendingPathComponent("courses/1/discussion_topics/1"),
            id: 1,
            is_section_specific: true,
            message: "<p>Is the cube rule of food valid? What's your take?</p>",
            permissions: .make(attach: true, update: true, reply: true, delete: true),
            posted_at: DateComponents(calendar: .current, year: 2020, month: 5, day: 7, hour: 8, minute: 35).date,
            published: true,
            sections: [ .make() ],
            sort_by_rating: true,
            subscribed: true,
            title: "What is a sandwich?"
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
        XCTAssertEqual(controller.courseSectionsLabel.text, "Sections: section")

        XCTAssertEqual(controller.maxDepth, controller.view.traitCollection.horizontalSizeClass == .compact ? 2 : 4)
        let html = getBodyHTML()
        XCTAssert(html.contains("Instructor (she/her)"))
        XCTAssert(html.contains("May 7, 2020 at 8:35 AM"))
        XCTAssert(html.contains("Is the cube rule of food valid?"))
        XCTAssert(html.contains("Bob"))
        XCTAssert(html.contains("Oreos are sandwiches."))
        XCTAssert(html.contains("Ruth"))
        XCTAssert(html.contains("Deleted this reply."))
        XCTAssert(html.contains("I disagree"))
        XCTAssert(html.contains("Why?"))
        XCTAssert(!html.contains("Hot Pockets"))
        XCTAssert(!html.contains("<script"))
        XCTAssert(!html.contains("<link"))

        var link = baseURL.appendingPathComponent("courses/1/assignments/2")
        XCTAssertEqual(webView.linkDelegate?.handleLink(link), true)
        XCTAssert(router.lastRoutedTo(link, withOptions: .push))

        link = baseURL.appendingPathComponent("courses/1/discussion_topics/1/reply")
        XCTAssertEqual(webView.linkDelegate?.handleLink(link), true)
        XCTAssert(router.lastRoutedTo(link, withOptions: .modal(.formSheet, isDismissable: false, embedInNav: true)))

        link = baseURL.appendingPathComponent("courses/1/discussion_topics/1/entries/1/replies")
        XCTAssertEqual(webView.linkDelegate?.handleLink(link), true)
        XCTAssert(router.lastRoutedTo(link, withOptions: .modal(.formSheet, isDismissable: false, embedInNav: true)))

        link = baseURL.appendingPathComponent("courses/1/discussion_topics/1/unknown")
        XCTAssertEqual(webView.linkDelegate?.handleLink(link), true)
        XCTAssert(router.lastRoutedTo(link, withOptions: .push))

        link = baseURL.appendingPathComponent("courses/1/discussion_topics/1/replies/3")
        XCTAssertEqual(webView.linkDelegate?.handleLink(link), true)
        let replies = router.viewControllerCalls.last?.0 as? DiscussionDetailsViewController
        XCTAssertEqual(replies?.showRepliesToEntryID, "3")

        XCTAssert(controller.optionsButton == controller.navigationItem.rightBarButtonItem)
        _ = controller.optionsButton.target?.perform(controller.optionsButton.action)
        var sheet = router.presented as? BottomSheetPickerViewController
        XCTAssertEqual(sheet?.actions.count, 5)

        XCTAssertEqual(sheet?.actions[0].title, "Mark All as Read")
        api.mock(MarkDiscussionEntriesReadRequest(context: course, topicID: "1", isRead: true, isForcedRead: true), response: emptyResponse)
        sheet?.actions[0].action()
        XCTAssert(!getBodyHTML().contains(unread))
        XCTAssertEqual(sheet?.actions[1].title, "Mark All as Unread")
        sheet?.actions[1].action()
        XCTAssert(getBodyHTML().contains(unread))

        XCTAssertEqual(sheet?.actions[2].title, "Unsubscribe")
        api.mock(SubscribeDiscussionTopicRequest(context: course, topicID: "1", method: .delete), response: emptyResponse)
        sheet?.actions[2].action()
        _ = controller.optionsButton.target?.perform(controller.optionsButton.action)
        var sheet2 = router.presented as? BottomSheetPickerViewController
        XCTAssertEqual(sheet2?.actions[1].title, "Subscribe")
        api.mock(SubscribeDiscussionTopicRequest(context: course, topicID: "1", method: .put), response: emptyResponse)
        sheet2?.actions[1].action()
        _ = controller.optionsButton.target?.perform(controller.optionsButton.action)
        sheet2 = router.presented as? BottomSheetPickerViewController
        XCTAssertEqual(sheet2?.actions[1].title, "Unsubscribe")

        XCTAssertEqual(sheet?.actions[3].title, "Edit")
        sheet?.actions[3].action()
        XCTAssert(router.lastRoutedTo(.parse("courses/1/discussion_topics/1/edit")))

        api.mock(DeleteDiscussionTopicRequest(context: course, topicID: "1"), error: NSError.internalError())
        XCTAssertEqual(sheet?.actions[4].title, "Delete")
        sheet?.actions[4].action()
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Internal Error")

        api.mock(RateDiscussionEntry(context: course, topicID: "1", entryID: "1", isLiked: true), response: emptyResponse)
        // Too hard to simulate the webView handler
        controller.like("1", isLiked: true)
        XCTAssert(getBodyHTML().contains("1 like"))

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

    func testShowReplies() {
        controller.showRepliesToEntryID = "3"
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.pointsView.isHidden, true)
        XCTAssertEqual(controller.publishedView.isHidden, true)
        XCTAssertEqual(controller.titleSubtitleView.title, "Discussion Replies")
        let html = getBodyHTML()
        XCTAssert(!html.contains("Is the cube rule of food valid?"))
        XCTAssert(html.contains("Why?"))
        XCTAssert(html.contains("Hot Pockets"))
    }

    func testShowEntry() {
        controller.showEntryID = "4"
        controller.view.layoutIfNeeded()
        waitForWebView()
        XCTAssertEqual((router.last as? DiscussionDetailsViewController)?.showRepliesToEntryID, "4")
    }

    func testAutomaticRead() {
        api.mock(MarkDiscussionEntryReadRequest(context: course, topicID: "1", entryID: "4", isRead: true, isForcedRead: false), response: emptyResponse)
        controller.view.layoutIfNeeded()
        waitForWebView()
        XCTAssertNotNil(controller.readTimer)
        controller.readTimer?.fire()
        waitForWebView()
        XCTAssert(!getBodyHTML().contains(unread))
    }

    func testStudentGroupTopic() {
        environment.app = .student
        let course = controller.context
        let group = Context(.group, id: "1")
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
            assignment_id: 1,
            group_category_id: 7,
            group_topic_children: [ .make(id: "2", group_id: "1") ],
            id: 1,
            title: "What is a sandwich?"
        ))
        api.mock(GetDiscussionTopic(context: group, topicID: "2"), value: .make(
            assignment_id: 1,
            html_url: baseURL.appendingPathComponent("groups/1/discussion_topics/2"),
            id: 2,
            message: "<p>Is the cube rule of food valid? What's your take?</p>",
            title: "What is a sandwich? - Group One"
        ))
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.context.canvasContextID, group.canvasContextID)
        XCTAssertEqual(controller.groupsContext, .currentUser)
        XCTAssertEqual(controller.topicID, "2")
        let html = getBodyHTML()
        XCTAssert(html.contains("Is the cube rule of food valid?"))
        XCTAssert(html.contains("Bob"))
        XCTAssert(html.contains("Oreos are sandwiches."))
    }

    func testStudentGroupTopicWhenUserNotInAGroup() {
        environment.app = .student
        api.mock(controller.groups, value: [])
        let course = controller.context
        api.mock(controller.entries, value: .make(
            participants: [],
            unread_entries: [],
            forced_entries: [],
            view: [
                .make(id: 1, user_id: 2, message: """
                <p>Cube rule all the way.</p>
                <p>Oreos are sandwiches.</p>
                """),
            ]
        ))
        api.mock(controller.topic, value: .make(
            assignment_id: 1,
            group_category_id: 7,
            group_topic_children: [ .make(id: "2", group_id: "1") ],
            id: 1,
            message: "<p>Is the cube rule of food valid? What's your take?</p>",
            title: "What is a sandwich?"
        ))
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.context.canvasContextID, course.canvasContextID)
        XCTAssertEqual(controller.topicID, "1")
        let html = getBodyHTML()
        XCTAssert(html.contains("Is the cube rule of food valid?"))
        XCTAssert(html.contains("Bob"))
        XCTAssert(html.contains("Oreos are sandwiches."))
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
            assignment: .make(),
            assignment_id: 1,
            group_category_id: 7,
            group_topic_children: [ .make(id: "2", group_id: "1") ],
            id: 1,
            title: "What is a sandwich?"
        ))
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.context.canvasContextID, "course_1")
        XCTAssertEqual(controller.groupsContext, .course("1"))
        XCTAssertEqual(controller.topicID, "1")
        let html = getBodyHTML()
        XCTAssert(html.contains("each group has its own conversation"))
        XCTAssert(html.contains("Group One"))
        XCTAssert(html.contains("/groups/1/discussion_topics/2"))
        XCTAssertEqual(controller.dueSection.isHidden, false)
        XCTAssertEqual(controller.submissionsSection.isHidden, true)
    }

    func testEditAndDeleteOwnPostsDisabled() {
        let userID = environment.currentSession!.userID
        api.mock(controller.entries, value: .make(
            participants: [
                .make(id: 2, display_name: "Bob"),
                .make(id: 3, display_name: "Ruth"),
            ],
            unread_entries: [],
            forced_entries: [2],
            view: [
                .make(id: 1, user_id: 2, message: """
                <p>Cube rule all the way.</p>
                <p>Oreos are sandwiches.</p>
                """, replies: [
                    .make(id: 2, user_id: ID(userID), parent_id: 1, message: "<p>I disagree.</p>", replies: [
                        .make(id: 3, user_id: 2, parent_id: 2, message: "Why?"),
                    ]),
                ]),
            ],
            new_entries: []
        ))
        api.mock(controller.topic, value: .make(
            assignment_id: 1,
            id: 1,
            permissions: .make(attach: true, update: false, reply: true, delete: false),
            title: "What is a sandwich?"
        ))
        controller.view.layoutIfNeeded()
        controller.showMoreOptions(for: "2")
        let sheet = router.presented as? BottomSheetPickerViewController
        XCTAssertEqual(sheet?.actions.count, 1)
        XCTAssertEqual(sheet?.actions.first?.title, "Mark as Unread")
    }

    func testDeletedAfterShown() throws {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        databaseClient.delete(controller.topic.all)
        try databaseClient.save()

        XCTAssert(router.dismissed == controller)
    }

    func testDetectsNewReplyFromUser() {
        controller.view.layoutIfNeeded()

        let newDiscussionNotification = expectation(description: "New discussion detected")
        controller.entries.eventHandler = { [weak self] in
            XCTAssertEqual(self?.controller.findNewReplyIDFromCurrentUser(), "5")
            newDiscussionNotification.fulfill()
        }

        // Simulate reply to thread, this will generate a context change of 1 insert and 1 update
        databaseClient.performAndWait {
            let newAPIEntry = APIDiscussionEntry.make(id: 5, user_id: 1, parent_id: 1, created_at: Date(), message: "New reply from the current user")

            let parentEntry: DiscussionEntry = databaseClient.first(where: #keyPath(DiscussionEntry.id), equals: "1")!
            let newEntry = DiscussionEntry.save(newAPIEntry, topicID: "1", parent: parentEntry, unreadIDs: nil, forcedIDs: nil, entryRatings: nil, in: databaseClient)
            parentEntry.replies.append(newEntry)
        }

        wait(for: [newDiscussionNotification], timeout: 1)
    }

    func testDoesntDetectOldReplyFromUser() {
        controller.view.layoutIfNeeded()

        let newDiscussionNotification = expectation(description: "New discussion detected")
        controller.entries.eventHandler = { [weak self] in
            XCTAssertNil(self?.controller.findNewReplyIDFromCurrentUser())
            newDiscussionNotification.fulfill()
        }

        // Simulate reply to thread, this will generate a context change of 1 insert and 1 update
        databaseClient.performAndWait {
            let newAPIEntry = APIDiscussionEntry.make(id: 5, user_id: 1, parent_id: 1, created_at: Date().addSeconds(-6), message: "Old reply from the current user")

            let parentEntry: DiscussionEntry = databaseClient.first(where: #keyPath(DiscussionEntry.id), equals: "1")!
            let newEntry = DiscussionEntry.save(newAPIEntry, topicID: "1", parent: parentEntry, unreadIDs: nil, forcedIDs: nil, entryRatings: nil, in: databaseClient)
            parentEntry.replies.append(newEntry)
        }

        wait(for: [newDiscussionNotification], timeout: 1)
    }

    func testPointsLabelWhenQuantitativeDataEnabled() {
        // Given
        mockCourseAndAssignmentWith(restrict_quantitative_data: true)

        // When
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        // Then
        XCTAssertEqual(controller.pointsView.isHidden, true)
        XCTAssertEqual(controller.pointsLabel.text, "95 pts")
    }

    func testPointsLabelWhenQuantitativeDataDisabled() {
        // Given
        mockCourseAndAssignmentWith(restrict_quantitative_data: false)

        // When
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        // Then
        XCTAssertEqual(controller.pointsView.isHidden, false)
        XCTAssertEqual(controller.pointsLabel.text, "95 pts")
    }

    func testPointsLabelWhenQuantitativeDataNotSpecified() {
        // Given
        mockCourseAndAssignmentWith(restrict_quantitative_data: nil)

        // When
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        // Then
        XCTAssertEqual(controller.pointsView.isHidden, false)
        XCTAssertEqual(controller.pointsLabel.text, "95 pts")
    }

    private func mockCourseAndAssignmentWith(restrict_quantitative_data: Bool?) {
        api.mock(
            GetCourse(courseID: "1"),
            value: .make(
                settings: APICourseSettings(
                    usage_rights_required: nil,
                    syllabus_course_summary: nil,
                    restrict_quantitative_data: restrict_quantitative_data
                )
            )
        )

        api.mock(
            GetAssignment(courseID: "1", assignmentID: "1"),
            value: .make(points_possible: 95)
        )
    }
}
