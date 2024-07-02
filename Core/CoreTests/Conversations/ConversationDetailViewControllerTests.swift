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

import AVKit
import XCTest
@testable import Core
import TestsFoundation

class ConversationDetailViewControllerTests: CoreTestCase {
    lazy var controller = ConversationDetailViewController.create(conversationID: "1")

    override func setUp() {
        super.setUp()
        Clock.mockNow(DateComponents(calendar: .current, timeZone: .current, year: 2019, month: 12, day: 25).date!)

        let c = APIConversation.make(
            participants: [
                .make(id: "1", name: "user 1", pronouns: "They/Them"),
                .make(id: "2", name: "user 2"),
                .make(id: "4", name: "user 4", pronouns: "He/Him")
            ],
            messages: [
                APIConversationMessage.make(
                    id: "1",
                    created_at: Clock.now.addDays(-1),
                    body: "hello world",
                    author_id: "2",
                    media_comment: .make(url: URL(string: "data:text/plain,")!),
                    attachments: [
                        .make(id: "1", mime_class: "doc"),
                        .make(id: "2", display_name: "Image", mime_class: "image"),
                        .make(id: "3", url: URL(string: "data:text/plain,")!, mime_class: "video")
                    ],
                    participating_user_ids: [ "1", "2" ]
                ),
                APIConversationMessage.make(
                    id: "2",
                    created_at: Clock.now.addDays(-4),
                    body: "foo bar",
                    author_id: "1",
                    participating_user_ids: [ "1", "4" ]
                )
            ]
        )
        api.mock(controller.conversations, value: c)
    }

    override func tearDown() {
        Clock.reset()
        super.tearDown()
    }

    func testLayout() {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        XCTAssertEqual(controller.replyButton.accessibilityLabel, "Reply")
        controller.replyButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual((router.presented as? ComposeReplyViewController)?.all, false)

        let first = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ConversationDetailCell
        XCTAssertEqual(first?.fromLabel.text, "user 2")
        XCTAssertEqual(first?.toLabel.text, "to me")
        XCTAssertEqual(first?.messageLabel.text, "hello world")
        XCTAssertEqual(first?.dateLabel.text, DateFormatter.localizedString(from: Clock.now.addDays(-1), dateStyle: .medium, timeStyle: .short))
        XCTAssertEqual(first?.attachmentsController.attachments.count, 3)

        var actions = controller.tableView.delegate?.tableView?(
            controller.tableView,
            trailingSwipeActionsConfigurationForRowAt: IndexPath(row: 0, section: 0)
        )?.actions
        XCTAssertEqual(actions?.count, 1)
        actions?[0].handler(actions![0], UIView()) { complete in
            XCTAssertTrue(complete)
        }
        XCTAssertEqual((router.presented as? ComposeReplyViewController)?.all, false)

        let second = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ConversationDetailCell
        XCTAssertEqual(second?.fromLabel.text, "user 1 (They/Them)")
        XCTAssertEqual(second?.toLabel.text, "to user 4 (He/Him)")

        actions = controller.tableView.delegate?.tableView?(
            controller.tableView,
            trailingSwipeActionsConfigurationForRowAt: IndexPath(row: 0, section: 1)
        )?.actions
        XCTAssertEqual(actions?.count, 1)
        actions?[0].handler(actions![0], UIView()) { complete in
            XCTAssertTrue(complete)
        }
        XCTAssertEqual((router.presented as? ComposeReplyViewController)?.all, true)
    }

    func testReplyAll() {
        let c = APIConversation.make(
            participants: [
                .make(id: "1", name: "user 1"),
                .make(id: "2", name: "user 2"),
                .make(id: "3", name: "user 3")
            ],
            messages: [
                APIConversationMessage.make(
                    id: "2",
                  created_at: Clock.now.addDays(-2),
                  body: "older",
                  author_id: "2",
                  participating_user_ids: [ "1", "2", "3" ]
                )
            ]
        )
        api.mock(controller.conversations, value: c)

        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        XCTAssertEqual(controller.replyButton.accessibilityLabel, "Reply All")
        controller.replyButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual((router.presented as? ComposeReplyViewController)?.all, true)

        let actions = controller.tableView.delegate?.tableView?(
            controller.tableView,
            trailingSwipeActionsConfigurationForRowAt: IndexPath(row: 0, section: 0)
        )?.actions
        XCTAssertEqual(actions?.count, 2)
        actions?[0].handler(actions![0], UIView()) { complete in
            XCTAssertTrue(complete)
        }
        XCTAssertEqual((router.presented as? ComposeReplyViewController)?.all, false)
        actions?[1].handler(actions![1], UIView()) { complete in
            XCTAssertTrue(complete)
        }
        XCTAssertEqual((router.presented as? ComposeReplyViewController)?.all, true)
    }
}
