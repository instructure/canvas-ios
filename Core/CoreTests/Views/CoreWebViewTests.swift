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
import WebKit
@testable import Core

class CoreWebViewTests: CoreTestCase {
    func testSetup() {
        let view = CoreWebView(frame: .zero, configuration: WKWebViewConfiguration())
        XCTAssertEqual(view.customUserAgent, UserAgent.safari.description)
        XCTAssertEqual(view.configuration.userContentController.userScripts.count, 1)
    }

    func testHtml() {
        let view = CoreWebView(frame: .zero, configuration: WKWebViewConfiguration())
        XCTAssert(view.html(for: "<script>$.load()</script>").contains("jquery.min.js"))
        XCTAssert(!view.html(for: "").contains("jquery.min.js"))
        XCTAssert(view.html(for: "").contains("<meta name=\"viewport\""))
    }

    func testCss() {
        let view = CoreWebView(frame: .zero, configuration: WKWebViewConfiguration())
        XCTAssert(view.css.contains(Brand.shared.buttonPrimaryBackground.hexString))
    }

    func testJs() {
        let view = CoreWebView(frame: .zero, configuration: WKWebViewConfiguration())
        XCTAssert(view.js.contains("'Launch External Tool'"))
    }

    func testAutoHeight() {
        let view = CoreWebView(frame: CGRect(x: 0, y: 0, width: 100, height: 1), configuration: WKWebViewConfiguration())
        view.autoresizesHeight = true

        let expectation = XCTestExpectation(description: "constraint is updated")
        let constraint = view.heightAnchor.constraint(equalToConstant: 0)
        view.addConstraint(constraint)
        let observation = constraint.observe(\.constant, options: .new) { _, _ in
            expectation.fulfill()
        }

        view.loadHTMLString("some content")
        wait(for: [expectation], timeout: 5)
        observation.invalidate()
        XCTAssertGreaterThan(constraint.constant, 32)
    }

    func testAutoHeightDisabled() {
        let view = CoreWebView(frame: CGRect(x: 0, y: 0, width: 100, height: 1), configuration: WKWebViewConfiguration())
        view.autoresizesHeight = false

        let constraint = view.heightAnchor.constraint(equalToConstant: 0)
        view.addConstraint(constraint)

        view.loadHTMLString("some content")
        let expectation = XCTestExpectation(description: "script executes")
        view.evaluateJavaScript("document.body.className = 'a'") { _, _ in
            expectation.fulfill()
        }

        XCTAssertEqual(constraint.constant, 0)
    }

    func testNavigateFragment() {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let middle = UIView(frame: CGRect(x: 0, y: 100, width: 100, height: 200))
        let view = CoreWebView(frame: CGRect(x: 0, y: 0, width: 100, height: 200), configuration: WKWebViewConfiguration())
        view.autoresizesHeight = true
        scrollView.addSubview(middle)
        middle.addSubview(view)

        let expectation = XCTestExpectation(description: "offset is updated")
        let observation = scrollView.observe(\.contentOffset, options: .new) { _, _ in
            expectation.fulfill()
        }
        view.loadHTMLString("<a name='t' href='#t'>link</a>", baseURL: URL(string: "#t"))
        wait(for: [expectation], timeout: 5)
        observation.invalidate()
        XCTAssertNotEqual(scrollView.contentOffset.y, 0)
    }

    class MockNavigationAction: WKNavigationAction {
        let mockRequest: URLRequest
        override var request: URLRequest {
            return mockRequest
        }

        let mockType: WKNavigationType
        override var navigationType: WKNavigationType {
            return mockType
        }

        init(url: String, type: WKNavigationType) {
            mockRequest = URLRequest(url: URL(string: url)!)
            mockType = type
            super.init()
        }
    }

    func testDecidePolicyForFragment() {
        let view = CoreWebView(frame: .zero, configuration: WKWebViewConfiguration())
        view.navigation = .deepLink { _ in
            XCTFail("Should not get to navigation")
            return true
        }
        view.loadHTMLString("", baseURL: URL(string: "example.com"))
        view.webView(view, decidePolicyFor: MockNavigationAction(url: "example.com#hash", type: .linkActivated)) { policy in
            XCTAssertEqual(policy, .allow)
        }
    }

    func testDecidePolicyForInternal() {
        let view = CoreWebView(frame: .zero, configuration: WKWebViewConfiguration())
        view.webView(view, decidePolicyFor: MockNavigationAction(url: "example.com", type: .linkActivated)) { policy in
            XCTAssertEqual(policy, .allow)
        }
    }

    func testDecidePolicyForExternal() {
        let view = CoreWebView(frame: .zero, configuration: WKWebViewConfiguration())
        view.navigation = .deepLink { _ in return false }
        view.webView(view, decidePolicyFor: MockNavigationAction(url: "example.com", type: .linkActivated)) { policy in
            XCTAssertEqual(policy, .allow)
        }
        view.navigation = .deepLink { url in
            XCTAssertEqual(url, URL(string: "example.com"))
            return true
        }
        view.webView(view, decidePolicyFor: MockNavigationAction(url: "example.com", type: .linkActivated)) { policy in
            XCTAssertEqual(policy, .cancel)
        }
    }

    func testKeepCookieAlive() {
        api.accessToken = nil
        CoreWebView.keepCookieAlive(for: environment)
        XCTAssertNil(CoreWebView.cookieKeepAliveTimer)

        api.accessToken = "a"
        let value = GetWebSessionRequest.Response(session_url: URL(string: "data:text/html,")!)
        api.mock(GetWebSessionRequest(to: api.baseURL.appendingPathComponent("users/self")), value: value, response: nil, error: nil)
        CoreWebView.keepCookieAlive(for: environment)
        wait(for: [expectation(for: .all, evaluatedWith: api) { CoreWebView.cookieKeepAliveWebView.url != nil }], timeout: 10)
        XCTAssertEqual(CoreWebView.cookieKeepAliveWebView.url, URL(string: "data:text/html,"))
        XCTAssertNotNil(CoreWebView.cookieKeepAliveTimer)

        CoreWebView.stopCookieKeepAlive()
    }
}
