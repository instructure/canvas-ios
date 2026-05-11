//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

class UIApplicationDelegateExtensionsTests: XCTestCase {

    private class SpyViewController: UIViewController {
        var presentedVC: UIViewController?
        override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
            presentedVC = viewControllerToPresent
            completion?()
        }
    }

    func testUpdateInterfaceStyle() {
        guard let appDelegate = UIApplication.shared.delegate else { return XCTFail() }
        AppEnvironment.shared.userDefaults?.interfaceStyle = .dark
        appDelegate.updateInterfaceStyle(for: appDelegate.window!)
        XCTAssertEqual(appDelegate.window!?.overrideUserInterfaceStyle, .dark)
        AppEnvironment.shared.userDefaults?.interfaceStyle = .light
        appDelegate.updateInterfaceStyle(for: appDelegate.window!)
        XCTAssertEqual(appDelegate.window!?.overrideUserInterfaceStyle, .light)
        AppEnvironment.shared.userDefaults?.interfaceStyle = .unspecified
        appDelegate.updateInterfaceStyle(for: appDelegate.window!)
        XCTAssertEqual(appDelegate.window!?.overrideUserInterfaceStyle, .unspecified)
    }

    // MARK: - showForceUpdateModal

    func test_showForceUpdateModal_shouldPresentForceUpdateViewOverFullScreen() {
        guard let appDelegate = UIApplication.shared.delegate else { return XCTFail() }
        let controller = SpyViewController()

        appDelegate.showForceUpdateModal(of: .student, on: controller)

        XCTAssertNotNil(controller.presentedVC as? CoreHostingController<ForceUpdateView>)
        XCTAssertEqual(controller.presentedVC?.modalPresentationStyle, .overFullScreen)
    }

    // MARK: - setForceUpdateView

    func test_setForceUpdateView_whenWindowIsNil_shouldNotCallCompletion() {
        guard let appDelegate = UIApplication.shared.delegate else { return XCTFail() }
        var completionCalled = false

        appDelegate.setForceUpdateView(window: nil) {
            completionCalled = true
        }

        XCTAssertEqual(completionCalled, false)
    }

    func test_setForceUpdateView_whenWindowIsProvided_shouldSetRootViewControllerAndCallCompletion() {
        guard let appDelegate = UIApplication.shared.delegate else { return XCTFail() }
        let window = UIWindow()
        let completionExpectation = expectation(description: "completion called")

        appDelegate.setForceUpdateView(window: window) {
            completionExpectation.fulfill()
        }

        waitForExpectations(timeout: 2)
        XCTAssertNotNil(window.rootViewController as? CoreHostingController<ForceUpdateView>)
    }
}
