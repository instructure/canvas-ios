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
import TestsFoundation
import XCTest

class CoreWebViewControllerTests: CoreTestCase {
    lazy var controller = CoreWebViewController()

    func testLimitedInteraction() {
        controller.isInteractionLimited = true
        controller.view.layoutIfNeeded()
        weak var limitedView = controller.limitedInteractionView
        XCTAssert(limitedView?.isDescendant(of: controller.view) == true)
        controller.limitedInteractionView?.dismiss.sendActions(for: .primaryActionTriggered)
        XCTAssert(limitedView?.isDescendant(of: controller.view) == false)
    }
}
