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

class BottomSheetPickerViewControllerTests: CoreTestCase {
    lazy var controller = BottomSheetPickerViewController.create()
    private var addCalled = false
    private var cancelCalled = false

    private func actionAdd() {
        addCalled = true
        cancelCalled = false
    }

    private func actionCancel() {
        addCalled = false
        cancelCalled = true
    }

    func testActionsAndSubviewAdditions() {
        controller.addAction(image: .addLine, title: "Add", action: actionAdd)
        controller.addAction(image: .xLine, title: "Cancel", action: actionCancel)
        XCTAssertEqual(controller.actions.count, 2)
        XCTAssertEqual(controller.actions.first?.title, "Add")
        XCTAssertEqual(controller.actions.last?.title, "Cancel")
        XCTAssertEqual(controller.actions.first?.image, .addLine)
        XCTAssertEqual(controller.actions.last?.image, .xLine)

        (controller.buttonStackView.arrangedSubviews[1] as? UIButton)?.sendActions(for: .primaryActionTriggered)
        XCTAssertTrue(cancelCalled)
        XCTAssertFalse(addCalled)

        (controller.buttonStackView.arrangedSubviews[0] as? UIButton)?.sendActions(for: .primaryActionTriggered)
        XCTAssertTrue(addCalled)
        XCTAssertFalse(cancelCalled)

        controller.viewDidLoad()
        controller.viewWillLayoutSubviews()
        XCTAssertEqual(controller.view.subviews.first?.subviews.count, 1)

        controller.title = "Test"
        controller.viewDidLoad()
        controller.viewWillLayoutSubviews()
        XCTAssertEqual(controller.view.subviews.first?.subviews.count, 2)
    }
}
