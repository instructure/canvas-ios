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
@testable import Parent
import TestsFoundation

class ComposeReplyViewControllerTests: ParentTestCase {
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
        api.mock(AddMessage(conversationID: conversation.id, body: "").request, value: .make())
        XCTAssertNoThrow(sendButton.target?.perform(sendButton.action))
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
}
