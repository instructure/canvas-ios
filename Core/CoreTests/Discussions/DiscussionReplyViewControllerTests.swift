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
import QuickLook
@testable import Core
import TestsFoundation

class DiscussionReplyViewControllerTests: CoreTestCase {
    var context = Context(.course, id: "1")
    lazy var controller = DiscussionReplyViewController.create(context: context, topicID: "1")

    var baseURL: URL { environment.api.baseURL }
    let webView = MockWebView(features: [])
    class MockWebView: CoreWebView {
        var html: String = ""
        open override func loadHTMLString(_ string: String, baseURL: URL? = AppEnvironment.shared.currentSession?.baseURL) -> WKNavigation? {
            html = string
            return nil
        }
        open override func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)? = nil) {
            completionHandler?(nil, nil)
        }
    }

    override func setUp() {
        super.setUp()
        controller.editor.webView = MockWebView(features: [])
        controller.webView = webView
        api.mock(controller.course, value: .make())
        api.mock(GetDiscussionEntry(context: context, topicID: "1", entryID: "1"), value: .make(
            participants: [ .make(id: 2, display_name: "Bob") ],
            unread_entries: [],
            forced_entries: [],
            view: [
                .make(id: 1, user_id: 2, message: """
                <p>Cube rule all the way.</p>
                <p>Oreos are sandwiches.</p>
                """, replies: []),
            ],
            new_entries: []
        ))
        api.mock(controller.group, value: .make())
        api.mock(controller.topic, value: .make(
            allow_rating: true,
            assignment_id: 1,
            author: .make(display_name: "Instructor", pronouns: "she/her"),
            html_url: baseURL.appendingPathComponent("courses/1/discussion_topics/1"),
            id: 1,
            message: "<p>Is the cube rule of food valid? What's your take?</p>",
            permissions: .make(reply: true),
            posted_at: DateComponents(calendar: .current, year: 2020, month: 5, day: 7, hour: 8, minute: 35).date,
            published: true,
            sort_by_rating: true,
            title: "What is a sandwich?"
        ))
    }

    func testLayout() {
        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(nav.navigationBar.barTintColor, .backgroundLightest)
        XCTAssertEqual(controller.titleSubtitleView.title, "Reply")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Course One")
        XCTAssert(webView.html.contains("Is the cube rule of food valid? What's your take?"))

        XCTAssertEqual(controller.viewMoreButton.isHidden, true)
        controller.contentHeight.constant = 500
        XCTAssertEqual(controller.viewMoreButton.isHidden, false)
        XCTAssertEqual(controller.viewMoreButton.title(for: .normal), "View More")
        controller.viewMoreButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.viewMoreButton.title(for: .normal), "View Less")

        controller.editor.delegate?.rce(controller.editor, didError: NSError.internalError())
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Internal Error")
        XCTAssertEqual(controller.sendButton.isEnabled, false)
        controller.editor.delegate?.rce(controller.editor, canSubmit: true)
        XCTAssertEqual(controller.sendButton.isEnabled, true)
        controller.editor.delegate?.rce(controller.editor, canSubmit: false)

        XCTAssertEqual(controller.attachBadge.isHidden, true)
        (controller.attachButton.customView as? UIButton)?.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.presented is BottomSheetPickerViewController)
        XCTAssertNoThrow(controller.filePicker.delegate?.filePicker(didRetry: .make()))
        let attachment = URL(fileURLWithPath: "/attachment.png")
        controller.filePicker.delegate?.filePicker(didPick: attachment)
        XCTAssertEqual(controller.attachBadge.isHidden, false)
        XCTAssertEqual(controller.sendButton.isEnabled, true)
        XCTAssertEqual(controller.attachmentURL, attachment)

        (controller.attachButton.customView as? UIButton)?.sendActions(for: .primaryActionTriggered)
        let sheet = router.presented as? BottomSheetPickerViewController
        XCTAssertEqual(sheet?.actions.count, 2)
        XCTAssertEqual(sheet?.actions.first?.title, "View")
        sheet?.actions.first?.action()
        let preview = router.presented as? QLPreviewController
        XCTAssert(preview?.dataSource === controller)
        XCTAssertEqual(preview?.dataSource?.numberOfPreviewItems(in: preview!), 1)
        XCTAssertNotNil(preview?.dataSource?.previewController(preview!, previewItemAt: 0))

        XCTAssertEqual(sheet?.actions.last?.title, "Delete")
        sheet?.actions.last?.action()
        XCTAssertEqual(controller.attachBadge.isHidden, true)
        XCTAssertEqual(controller.sendButton.isEnabled, false)
        XCTAssertEqual(controller.attachmentURL, nil)
        XCTAssertEqual(preview?.dataSource?.numberOfPreviewItems(in: preview!), 0)

        api.mock(CreateDiscussionReply(context: context, topicID: "1", message: ""), error: NSError.internalError())
        _ = controller.sendButton.target?.perform(controller.sendButton.action)
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Internal Error")
        XCTAssertEqual(controller.sendButton.customView, nil)
        api.mock(CreateDiscussionReply(context: context, topicID: "1", message: ""), value: .make())
        _ = controller.sendButton.target?.perform(controller.sendButton.action)
    }

    func testReplyTo() {
        controller.webView = CoreWebView() // unlink prev controller
        context = Context(.group, id: "1")
        controller = DiscussionReplyViewController.create(context: context, topicID: "1", replyToEntryID: "1")
        setUp()
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.titleSubtitleView.title, "Reply")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Group One")
        XCTAssert(webView.html.contains("Oreos are sandwiches."))
    }

    func testEdit() {
        controller = DiscussionReplyViewController.create(context: context, topicID: "1", editEntryID: "1")
        setUp()
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.titleSubtitleView.title, "Edit")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Course One")
        XCTAssert(webView.html.contains("Is the cube rule of food valid? What's your take?"))

        api.mock(UpdateDiscussionReply(context: context, topicID: "1", entryID: "1", message: ""), error: NSError.internalError())
        _ = controller.sendButton.target?.perform(controller.sendButton.action)
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Internal Error")
        XCTAssertEqual(controller.sendButton.customView, nil)
        api.mock(UpdateDiscussionReply(context: context, topicID: "1", entryID: "1", message: ""), value: .make())
        _ = controller.sendButton.target?.perform(controller.sendButton.action)
    }
}
