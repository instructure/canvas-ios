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

        XCTAssertEqual(controller.navigationItem.rightBarButtonItem?.isEnabled, false)
        controller.bodyView.text = " \r\n\t"
        controller.bodyView.delegate?.textViewDidChange?(controller.bodyView)
        XCTAssertEqual(controller.navigationItem.rightBarButtonItem?.isEnabled, false)
        controller.bodyView.text = "Replying"
        controller.bodyView.delegate?.textViewDidChange?(controller.bodyView)
        XCTAssertEqual(controller.navigationItem.rightBarButtonItem?.isEnabled, true)
    }
}
