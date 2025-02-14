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

    func testSelect() {
        var addCalled = false
        controller.addAction(image: .addLine, title: "Add") {
            addCalled = true
        }
        controller.addAction(image: .xLine, title: "Cancel")

        (controller.stackView.arrangedSubviews[1] as? UIButton)?.sendActions(for: .primaryActionTriggered)
        XCTAssertFalse(addCalled)
        (controller.stackView.arrangedSubviews[0] as? UIButton)?.sendActions(for: .primaryActionTriggered)
        XCTAssertTrue(addCalled)
        controller.viewWillLayoutSubviews()
        XCTAssertEqual(controller.view.frame.height, 148)
    }
}
