//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
import UIKit
@testable import Core

class UIViewControllerExtensionsTests: XCTestCase {
    class MockController: UIViewController {
        var dismissAnimated: Bool?
        override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            dismissAnimated = flag
        }
    }

    func testAddCancelButton() {
        let controller = UIViewController()
        controller.addCancelButton()
        XCTAssertEqual(controller.navigationItem.rightBarButtonItems?.first?.action, #selector(controller.dismissDoneButton))
    }

    func testAddDoneButton() {
        let controller = UIViewController()
        controller.addDoneButton(side: .left)
        XCTAssertEqual(controller.navigationItem.leftBarButtonItems?.first?.action, #selector(controller.dismissDoneButton))
    }

    func testDismissDoneButton() {
        let controller = MockController()
        controller.dismissDoneButton()
        XCTAssertEqual(controller.dismissAnimated, true)
    }
}
