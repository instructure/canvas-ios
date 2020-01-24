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

import Foundation
@testable import Core
@testable import TestsFoundation
import XCTest
import SafariServices

class LTIViewControllerTests: CoreTestCase {
    func testLayout() {
        let tools = LTITools(id: "1")
        let controller = LTIViewController(tools: tools)
        let task = api.mock(tools.request, value: .make())
        task.paused = true

        controller.view.layoutIfNeeded()
        XCTAssertFalse(controller.button.isHidden)
        XCTAssertFalse(controller.spinner.isAnimating)
        XCTAssertEqual(controller.button.title(for: .normal), "Launch External Tool")

        controller.button.sendActions(for: .primaryActionTriggered)
        XCTAssertTrue(controller.button.isHidden)
        XCTAssertTrue(controller.spinner.isAnimating)
        task.paused = false
        XCTAssertNotNil(router.presented as? SFSafariViewController)
        XCTAssertFalse(controller.button.isHidden)
        XCTAssertFalse(controller.spinner.isAnimating)
    }
}
