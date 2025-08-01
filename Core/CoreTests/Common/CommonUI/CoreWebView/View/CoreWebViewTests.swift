//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import WebKit
@testable import Core
import TestsFoundation

class CoreWebViewTests: CoreTestCase {
    class LinkDelegate: CoreWebViewLinkDelegate {
        let handle: (URL) -> Bool
        init(_ handle: @escaping (URL) -> Bool = { _ in return false }) {
            self.handle = handle
        }
        func handleLink(_ url: URL) -> Bool {
            return handle(url)
        }
        let routeLinksFrom = UIViewController()

        var navigationStartHandler: ((CoreWebView) -> Void)?
        func coreWebView(_ webView: CoreWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            navigationStartHandler?(webView)
        }
    }

    func testSetup() {
        let view = CoreWebView(frame: .zero, configuration: WKWebViewConfiguration())
        XCTAssertEqual(view.customUserAgent, UserAgent.safari.description)
        XCTAssertEqual(view.configuration.userContentController.userScripts.count, 1)
    }

    func testCustomUserAgentName() {
        let customeUserAgentName = "customUserAgent"
        let view = CoreWebView(features: [.userAgent(customeUserAgentName)])
        XCTAssertEqual(view.configuration.applicationNameForUserAgent, customeUserAgentName)
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
        let observation = constraint.observe(\.constant, options: .new) { _, _ in
            expectation.fulfill()
        }

        view.addConstraint(constraint)

        view.loadHTMLString("some content")
        wait(for: [expectation], timeout: 30)
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
        wait(for: [expectation], timeout: 30)
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

    class MockNavigationResponse: WKNavigationResponse {
        let mockResponse: URLResponse
        override var response: URLResponse { mockResponse }

        init(response: URLResponse) {
            mockResponse = response
            super.init()
        }
    }

    func testDecidePolicyForFragment() {
        let view = CoreWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let linkDelegate = LinkDelegate { _ in
            XCTFail("Should not get to navigation")
            return true
        }
        view.linkDelegate = linkDelegate
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
        view.isLinkNavigationEnabled = false
        view.webView(view, decidePolicyFor: MockNavigationAction(url: "example.com", type: .linkActivated)) { policy in
            XCTAssertEqual(policy, .cancel)
        }
    }

    func testDecidePolicyForExternal() {
        let view = CoreWebView(frame: .zero, configuration: WKWebViewConfiguration())
        var linkDelegate = LinkDelegate { _ in return false }
        view.linkDelegate = linkDelegate
        view.webView(view, decidePolicyFor: MockNavigationAction(url: "example.com", type: .linkActivated)) { policy in
            XCTAssertEqual(policy, .allow)
        }
        let expectation = XCTestExpectation(description: "link delegate was called")
        expectation.assertForOverFulfill = true
        linkDelegate = LinkDelegate { url in
            XCTAssertEqual(url, URL(string: "example.com"))
            expectation.fulfill()
            return true
        }
        view.linkDelegate = linkDelegate
        view.webView(view, decidePolicyFor: MockNavigationAction(url: "example.com", type: .linkActivated)) { policy in
            XCTAssertEqual(policy, .cancel)
        }
        wait(for: [expectation], timeout: 1)
        view.isLinkNavigationEnabled = false
        view.webView(view, decidePolicyFor: MockNavigationAction(url: "example.com", type: .linkActivated)) { policy in
            XCTAssertEqual(policy, .cancel)
        }
    }

    func testDecidePolicyForCourseLink() {
        let view = CoreWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let linkDelegate = CoreWebViewController()
        view.linkDelegate = linkDelegate
        let controller = CoreWebViewController()
        controller.webView = view.webView(view, createWebViewWith: WKWebViewConfiguration(),
                                          for: MockNavigationAction(url: "https://canvas.instructure.com/courses/1/assignments/2", type: .other),
                                          windowFeatures: WKWindowFeatures()) as! CoreWebView
        controller.webView.linkDelegate = linkDelegate
        linkDelegate.present(controller, animated: false) {
            controller.webView.webView(view, decidePolicyFor: MockNavigationAction(url: "https://canvas.instructure.com/courses/1/assignments/2", type: .other)) { policy in
                XCTAssertEqual(policy, .cancel)
            }
        }
    }

    func testKeepCookieAlive() {
        environment.api = API(.make(accessToken: nil))
        CoreWebView.keepCookieAlive(for: environment)
        XCTAssertNil(CoreWebView.cookieKeepAliveTimer)

        environment.api = API(.make(accessToken: "a"))
        let value = GetWebSessionRequest.Response(session_url: URL(string: "data:text/html,")!, requires_terms_acceptance: false)
        api.mock(GetWebSessionRequest(to: nil), value: value)
        CoreWebView.keepCookieAlive(for: environment)
        wait(for: [expectation(for: .all, evaluatedWith: api) { CoreWebView.cookieKeepAliveWebView.url != nil }], timeout: 10)
        XCTAssertEqual(CoreWebView.cookieKeepAliveWebView.url, URL(string: "data:text/html,"))
        XCTAssertNotNil(CoreWebView.cookieKeepAliveTimer)

        CoreWebView.stopCookieKeepAlive()
    }

    func testJsString() {
        XCTAssertEqual(CoreWebView.jsString(nil), "null")
        XCTAssertEqual(CoreWebView.jsString(""), "''")
        XCTAssertEqual(CoreWebView.jsString("javascript"), "'javascript'")
        XCTAssertEqual(CoreWebView.jsString("\\'\r\n\u{2028}\u{2029}"), #"'\\\'\r\n\u2028\u2029'"#)
    }

    func testHtmlString() {
        XCTAssertEqual(CoreWebView.htmlString(nil), "")
        XCTAssertEqual(CoreWebView.htmlString(""), "")
        XCTAssertEqual(CoreWebView.htmlString("html"), "html")
        XCTAssertEqual(CoreWebView.htmlString("&'\"<>"), "&amp;&#39;&quot;&lt;&gt;")
    }

    func testCreateWebViewWithConfigurationForNavigationAction() {
        let view = CoreWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let linkDelegate = LinkDelegate()
        view.linkDelegate = linkDelegate
        let webView = view.webView(
            view,
            createWebViewWith: WKWebViewConfiguration(),
            for: MockNavigationAction(url: "/", type: .other),
            windowFeatures: WKWindowFeatures()
        )
        XCTAssertNotNil(webView)
        XCTAssert(router.presented is CoreWebViewController)
    }

    func testEmptyInitializerCallsSetup() {
        let testee = CoreWebView()
        XCTAssertEqual(testee.customUserAgent, UserAgent.safari.description)
    }

    func testDidStartProvisionalNavigationCallback() {
        let view = CoreWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let navigationStartExpectation = expectation(description: "Navigation callback invoked")
        let delegate = LinkDelegate()
        delegate.navigationStartHandler = { webView in
            navigationStartExpectation.fulfill()
            XCTAssertEqual(webView.url, URL(string: "https://instructure.com/")!)
        }
        view.linkDelegate = delegate

        view.load(URLRequest(url: URL(string: "https://instructure.com/")!))

        waitForExpectations(timeout: 10)
    }

    func test_routesNatively_whenOpeningURLInNewTab() {
        let testURL = "https://instructure.com/speedgrader"
        let viewControllerCreatedByRouter = UIViewController()
        let view = CoreWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let delegate = LinkDelegate()
        view.linkDelegate = delegate
        router.mock("/speedgrader") {
            viewControllerCreatedByRouter
        }

        // WHEN
        let createdWebView = view.uiDelegate?.webView?(
            view,
            createWebViewWith: view.configuration,
            for: MockNavigationAction(url: testURL, type: .linkActivated),
            windowFeatures: .init()
        )

        // THEN
        XCTAssertNil(createdWebView)

        let lastRoute = router.calls.last
        XCTAssertEqual(lastRoute!.0, URLComponents(string: testURL))
        XCTAssertEqual(lastRoute!.1, delegate.routeLinksFrom)
        XCTAssertEqual(lastRoute!.2, .modal(
            .fullScreen,
            isDismissable: false,
            embedInNav: true,
            addDoneButton: true,
            animated: true
        ))
    }

    func test_addsDynamicFontFeature_whenLoaded() {
        var testee = CoreWebView(features: [])
        XCTAssertEqual(testee.features.count, 1)
        XCTAssertTrue(testee.features.first is DynamicFontSize)

        testee = CoreWebView()
        XCTAssertEqual(testee.features.count, 0)

        testee = CoreWebView(frame: .zero)
        XCTAssertEqual(testee.features.count, 0)
    }

    func test_modalPresentationMessage_invokesAccessibilityHelper() {
        let testee = CoreWebView(frame: .zero, configuration: WKWebViewConfiguration())
        var mockHelper = MockA11yHelper()
        testee.a11yHelper = mockHelper
        let hostVC = UIViewController()
        hostVC.view.addSubview(testee)

        // WHEN
        var js = "window.webkit.messageHandlers.modalPresentation.postMessage({open: true});"
        let jsCompletedExpectation = expectation(description: "JS message handled")
        testee.evaluateJavaScript(js) { _, _ in
            jsCompletedExpectation.fulfill()
        }
        wait(for: [jsCompletedExpectation], timeout: 10)

        // THEN
        XCTAssertTrue(mockHelper.called)
        XCTAssertEqual(mockHelper.receivedIsExclusive, true)
        XCTAssertEqual(mockHelper.receivedView, testee)
        XCTAssertEqual(mockHelper.receivedViewController, hostVC)

        // GIVEN
        mockHelper = MockA11yHelper()
        testee.a11yHelper = mockHelper

        // WHEN
        js = "window.webkit.messageHandlers.modalPresentation.postMessage({open: false});"
        let jsCompletedExpectation2 = expectation(description: "JS message handled")
        testee.evaluateJavaScript(js) { _, _ in
            jsCompletedExpectation2.fulfill()
        }
        wait(for: [jsCompletedExpectation2], timeout: 10)

        // THEN
        XCTAssertTrue(mockHelper.called)
        XCTAssertEqual(mockHelper.receivedIsExclusive, false)
        XCTAssertEqual(mockHelper.receivedView, testee)
        XCTAssertEqual(mockHelper.receivedViewController, hostVC)
    }
}

private class MockA11yHelper: CoreWebViewAccessibilityHelper {
    var called = false
    var receivedIsExclusive: Bool?
    var receivedView: UIView?
    var receivedViewController: UIViewController?

    override func setExclusiveAccessibility(for view: UIView, isExclusive: Bool, viewController: UIViewController?) {
        called = true
        receivedIsExclusive = isExclusive
        receivedView = view
        receivedViewController = viewController
    }
}
