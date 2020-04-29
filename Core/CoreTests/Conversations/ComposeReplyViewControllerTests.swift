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
@testable import Core
import TestsFoundation

class ComposeReplyViewControllerTests: CoreTestCase {
    lazy var conversation = Conversation.make(from: .make(messages: [ .make() ]))

    lazy var controller = ComposeReplyViewController.create(conversation: conversation, message: conversation.messages.first, all: true)

    func testLayout() {
        let navigation = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        XCTAssertEqual(navigation.navigationBar.barTintColor, .named(.backgroundLightest))
        XCTAssertEqual(controller.bodyMinHeight.constant, -controller.bodyView.frame.minY)
        XCTAssertEqual(controller.title, "Reply All")

        controller.all = false
        controller.update()
        XCTAssertEqual(controller.title, "Reply")

        XCTAssertEqual(controller.sendButton.isEnabled, false)
        controller.bodyView.text = " \r\n\t"
        controller.bodyView.delegate?.textViewDidChange?(controller.bodyView)
        XCTAssertEqual(controller.sendButton.isEnabled, false)
        controller.bodyView.text = "Replying"
        controller.bodyView.delegate?.textViewDidChange?(controller.bodyView)
        XCTAssertEqual(controller.sendButton.isEnabled, true)

        api.mock(AddMessage(conversationID: conversation.id, body: "").request, error: NSError.instructureError("Oops"))
        let sendButton = controller.sendButton
        XCTAssertNoThrow(sendButton.target?.perform(sendButton.action))
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Oops")

        controller.all = true
        let task = api.mock(AddMessage(conversationID: conversation.id, body: "").request, value: .make())
        task.paused = true
        XCTAssertNoThrow(sendButton.target?.perform(sendButton.action))
        XCTAssert(sendButton.customView is CircleProgressView)
        task.resume()
    }

    func testAttachments() {
        controller.view.layoutIfNeeded()
        XCTAssertNoThrow(controller.attachButton.target?.perform(controller.attachButton.action))
        XCTAssert(router.presented is BottomSheetPickerViewController)

        controller.filePicker.delegate?.filePicker(didPick: URL(string: "picked")!)
        XCTAssertEqual((UploadManager.shared as? MockUploadManager)?.uploadWasCalled, true)
        (UploadManager.shared as? MockUploadManager)?.uploadWasCalled = false

        controller.attachmentsController.showOptions?(File.make())
        XCTAssert(router.presented is BottomSheetPickerViewController)

        controller.filePicker.delegate?.filePicker(didRetry: File.make())
        XCTAssertEqual((UploadManager.shared as? MockUploadManager)?.uploadWasCalled, true)

        File.make(from: .make(id: "1"), batchID: controller.batchID, session: currentSession)
        File.make(from: .make(id: "2"), batchID: controller.batchID, session: currentSession)
        XCTAssertEqual(controller.bodyMinHeight.isActive, false)
        XCTAssertEqual(controller.attachmentsContainer.isHidden, false)
        XCTAssertEqual(controller.attachmentsController.attachments.count, 2)
    }

    func testPronouns() {
        conversation = Conversation.make(from: .make(
            participants: [
                .make(id: "1", name: "user 1", pronouns: "He/Him"),
                .make(id: "2", name: "user 2", pronouns: "She/Her"),
            ],
            messages: [
                .make(id: "1", author_id: "1", participating_user_ids: ["1", "2"]),
            ]
        ))
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.toLabel.text, "to user 2 (She/Her)")
        XCTAssertEqual(controller.fromLabel.text, "user 1 (He/Him)")
    }
}
