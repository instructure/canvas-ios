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
import UIKit
@testable import Core
@testable import Parent
import TestsFoundation

class ComposeViewControllerTests: ParentTestCase {
    lazy var controller = ComposeViewController.create(
        body: "body",
        context: ContextModel(.course, id: "1"),
        observeeID: "2",
        recipients: [ .make() ],
        subject: "subject",
        hiddenMessage: "hidden"
    )

    func loadView() {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
    }

    func testLayout() {
        let navigation = UINavigationController(rootViewController: controller)
        loadView()
        XCTAssertEqual(navigation.navigationBar.barTintColor, .named(.backgroundLightest))

        XCTAssertEqual(controller.navigationItem.rightBarButtonItem?.isEnabled, true)

        controller.subjectField.text = " \n"
        controller.bodyView.text = "\t\r"
        controller.bodyView.delegate?.textViewDidChange?(controller.bodyView)
        XCTAssertEqual(controller.sendButton.isEnabled, false)

        controller.bodyView.text = "body"
        controller.bodyView.delegate?.textViewDidChange?(controller.bodyView)
        XCTAssertEqual(controller.sendButton.isEnabled, false)

        controller.subjectField.text = "subject"
        controller.subjectField.sendActions(for: .editingChanged)
        XCTAssertEqual(controller.sendButton.isEnabled, true)

        XCTAssertNotNil(controller.recipientsView.editButton)
        XCTAssertTrue(controller.recipientsView.placeholder.isHidden)
        controller.recipientsView.editButton.sendActions(for: .primaryActionTriggered)
        let editRecipients = router.presented as? EditComposeRecipientsViewController
        XCTAssertNotNil(editRecipients)
        XCTAssertEqual(editRecipients?.modalPresentationStyle, .custom)
        XCTAssertNotNil(editRecipients?.transitioningDelegate as? BottomSheetTransitioningDelegate)
        XCTAssertEqual(editRecipients?.context?.canvasContextID, controller.context?.canvasContextID)
        XCTAssertEqual(editRecipients?.observeeID, controller.observeeID)
        XCTAssertEqual(editRecipients?.selectedRecipients.count, 1)
        editRecipients?.selectedRecipients = []
        editRecipients?.delegate?.editRecipientsControllerDidFinish(editRecipients!)
        XCTAssertEqual(controller.recipientsView.recipients.count, 0)
        XCTAssertEqual(controller.sendButton.isEnabled, false)
        XCTAssertFalse(controller.recipientsView.placeholder.isHidden)
        editRecipients?.selectedRecipients =  [.make(id: "123")]
        editRecipients?.delegate?.editRecipientsControllerDidFinish(editRecipients!)
        XCTAssertEqual(controller.sendButton.isEnabled, true)
        XCTAssertEqual(controller.recipientsView.recipients.count, 1)
        XCTAssertEqual(controller.recipientsView.recipients.first?.id.value, "123")
        XCTAssertTrue(controller.recipientsView.placeholder.isHidden)

        let task = api.mock(PostConversationRequest(body: PostConversationRequest.Body(
            subject: "subject",
            body: controller.body(),
            recipients: [ APIConversationRecipient.make().id.value ],
            context_code: controller.context!.canvasContextID)
            ), value: [ APIConversation.make() ]
        )
        task.paused = true
        let sendButton = controller.sendButton
        XCTAssertNoThrow(sendButton.target?.perform(sendButton.action))
        XCTAssert(controller.sendButton.customView is UIActivityIndicatorView)
        task.resume()
    }

    func testCreateConversationError() {
        loadView()

        api.mock(PostConversationRequest(body: PostConversationRequest.Body(
            subject: "subject",
            body: controller.body(),
            recipients: [ APIConversationRecipient.make().id.value ],
            context_code: controller.context!.canvasContextID)
            ), error: NSError.instructureError("Error")
        )
        let sendButton = controller.sendButton
        XCTAssertNoThrow(sendButton.target?.perform(sendButton.action))
        XCTAssert(router.presented is UIAlertController)
    }

    func testFetchRecipients() {
        let request = GetConversationRecipientsRequest(search: "", context: "\(controller.context!.canvasContextID)_teachers", includeContexts: false)
        api.mock(request, value: [.make()])
        controller.recipientsView.recipients = []
        loadView()
        drainMainQueue()
        XCTAssertEqual(controller.recipientsView.recipients.count, 1)
    }

    func testAdditionalRecipients() {
        loadView()

        XCTAssertTrue(controller.recipientsView.additionalRecipients.isHidden)

        controller.recipientsView.recipients = [.make(), .make()]
        XCTAssertFalse(controller.recipientsView.additionalRecipients.isHidden)
        XCTAssertEqual(controller.recipientsView.pills.count, 1)

        controller.recipientsView.toggleIsExpanded(sender: UITapGestureRecognizer())
        XCTAssertTrue(controller.recipientsView.additionalRecipients.isHidden)
        XCTAssertEqual(controller.recipientsView.pills.count, 2)
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
