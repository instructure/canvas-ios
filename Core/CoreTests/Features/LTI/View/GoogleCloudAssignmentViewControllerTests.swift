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
import UIKit
@testable import Core
@testable import TestsFoundation
import WebKit

class GoogleCloudAssignmentViewControllerTests: CoreTestCase {
    var url = URL(string: "https://google-drive-lti-iad-prod.instructure.com/lti/content-view/cloud-assignment/1")!
    lazy var controller = GoogleCloudAssignmentViewController(url: url)

    func testLayout() throws {
        controller.view.layoutIfNeeded()
        let webView = try XCTUnwrap(controller.view as? WKWebView)
        XCTAssertEqual(webView.customUserAgent, UserAgent.desktopSafari.description)
        XCTAssertEqual(webView.url, url)
    }

    func testShowAuthenticationWindow() throws {
        let webView = try XCTUnwrap(controller.view as? WKWebView)
        let authWindow = webView.uiDelegate?.webView?(
            webView,
            createWebViewWith: webView.configuration,
            for: WKNavigationAction(),
            windowFeatures: WKWindowFeatures()
        )
        XCTAssertNotNil(authWindow)
        XCTAssertEqual(authWindow?.customUserAgent, UserAgent.safari.description)
        XCTAssert(router.presented?.view === authWindow)
    }

    func testAuthenticationWindowDidClose() throws {
        let controller = Mock(url: url)
        let presented = MockPresentedViewController()
        controller.mockPresented = presented
        let action = MockAction()
        action.mockRequest = URLRequest(url: URL(string: "canvas-core://window.close")!)
        let webView = try XCTUnwrap(controller.view as? WKWebView)
        let authWindow = webView.uiDelegate?.webView?(
            webView,
            createWebViewWith: webView.configuration,
            for: WKNavigationAction(),
            windowFeatures: WKWindowFeatures()
        )
        let expectation = XCTestExpectation(description: "decision handler")
        authWindow?.navigationDelegate?.webView?(webView, decidePolicyFor: action) { policy in
            XCTAssertEqual(policy, .cancel)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssert(presented.dismissed)
    }
}

extension GoogleCloudAssignmentViewControllerTests {
    class MockAction: WKNavigationAction {
        var mockRequest: URLRequest!
        override var request: URLRequest { return mockRequest }
    }

    class MockPresentedViewController: UIViewController {
        var dismissed = false
        override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            dismissed = true
            completion?()
        }
    }

    class Mock: GoogleCloudAssignmentViewController {
        var mockPresented: UIViewController?
        override var presentedViewController: UIViewController? { mockPresented }
    }
}
