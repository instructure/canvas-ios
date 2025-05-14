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
import WebKit
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

    func testBackToolbarButton() {
        let navController = UINavigationController(rootViewController: controller)
        let webView = MockWebView()
        controller.webView = webView
        controller.view.layoutIfNeeded()

        // toolbar should have one item
        controller.setupBackToolbarButton()
        XCTAssertEqual(controller.toolbarItems?.count, 1)

        // back button action should call goBack()
        let backButton = controller.toolbarItems?.first as? UIBarButtonItemWithCompletion
        backButton?.buttonDidTap(sender: .init())
        XCTAssertEqual(webView.goBackCallsCount, 1)

        // when webview can go back should show toolbar
        webView.mockCanGoBack = true
        XCTAssertEqual(navController.isToolbarHidden, false)

        // when webview can't go back should hide toolbar
        webView.mockCanGoBack = false
        XCTAssertEqual(navController.isToolbarHidden, true)
    }
}

private class MockWebView: CoreWebView {
    var mockCanGoBack = false {
        willSet {
            willChangeValue(for: \.canGoBack)
        }
        didSet {
            didChangeValue(for: \.canGoBack)
        }
    }
    override var canGoBack: Bool {
        mockCanGoBack
    }

    var goBackCallsCount: Int = 0
    override func goBack() -> WKNavigation? {
        goBackCallsCount += 1
        return nil
    }

    override func load(_ request: URLRequest) -> WKNavigation? {
        // noop to avoid unnecessary site load
        nil
    }
}
