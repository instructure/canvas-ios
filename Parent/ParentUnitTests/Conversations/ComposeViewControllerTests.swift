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
        XCTAssertEqual(controller.navigationItem.rightBarButtonItem?.isEnabled, false)

        controller.bodyView.text = "body"
        controller.bodyView.delegate?.textViewDidChange?(controller.bodyView)
        XCTAssertEqual(controller.navigationItem.rightBarButtonItem?.isEnabled, false)

        controller.subjectField.text = "subject"
        controller.subjectField.sendActions(for: .editingChanged)
        XCTAssertEqual(controller.navigationItem.rightBarButtonItem?.isEnabled, true)

        let sendButton = controller.navigationItem.rightBarButtonItem
        XCTAssertNoThrow(sendButton?.target?.perform(sendButton?.action))

        XCTAssertNotNil(controller.recipientsView.editButton)
        controller.recipientsView.editButton.sendActions(for: .primaryActionTriggered)
        let actionSheet = router.presented as? ActionSheetController
        XCTAssertEqual(actionSheet?.modalPresentationStyle, .custom)
        XCTAssertNotNil(actionSheet?.transitioningDelegate as? ActionSheetTransitioningDelegate)
        XCTAssertNotNil(actionSheet)
        let editRecipients = actionSheet?.viewController as? EditComposeRecipientsViewController
        XCTAssertNotNil(editRecipients)
        XCTAssertEqual(editRecipients?.context?.canvasContextID, controller.context?.canvasContextID)
        XCTAssertEqual(editRecipients?.observeeID, controller.observeeID)
        XCTAssertEqual(editRecipients?.selectedRecipients.count, 1)
        editRecipients?.selectedRecipients = []
        editRecipients?.delegate?.editRecipientsControllerDidFinish(editRecipients!)
        XCTAssertEqual(controller.recipientsView.recipients.count, 0)
        XCTAssertEqual(controller.navigationItem.rightBarButtonItem?.isEnabled, false)
        editRecipients?.selectedRecipients =  [.make(id: "123")]
        editRecipients?.delegate?.editRecipientsControllerDidFinish(editRecipients!)
        XCTAssertEqual(controller.navigationItem.rightBarButtonItem?.isEnabled, true)
        XCTAssertEqual(controller.recipientsView.recipients.count, 1)
        XCTAssertEqual(controller.recipientsView.recipients.first?.id.value, "123")
    }

    func testFetchRecipients() {
        let request = GetConversationRecipientsRequest(search: "", context: "\(controller.context!.canvasContextID)_teachers", includeContexts: false)
        api.mock(request, value: [.make()])
        controller.recipientsView.recipients = []
        loadView()
        drainMainQueue()
        XCTAssertEqual(controller.recipientsView.recipients.count, 1)
    }
}
