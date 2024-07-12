//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

@testable import Core
import WebKit
import XCTest

class WKWebViewExtensionsTests: CoreTestCase {
    class TestContentController: WKUserContentController {
        var handlers: [String: WKScriptMessageHandler] = [:]
        override func add(_ scriptMessageHandler: WKScriptMessageHandler, name: String) {
            handlers[name] = scriptMessageHandler
        }
    }

    class TestConfiguration: WKWebViewConfiguration {
        var _userContentController = TestContentController()
        override var userContentController: WKUserContentController {
            get { return _userContentController }
            set { _userContentController = newValue as! TestContentController }
        }
    }

    func testAddScript() {
        let js = "window.name = 'awesome'"
        let webView = WKWebView(frame: .zero)
        webView.configuration.userContentController.removeAllUserScripts()
        webView.addScript(js)
        XCTAssertEqual(webView.configuration.userContentController.userScripts.count, 1)
        XCTAssertEqual(webView.configuration.userContentController.userScripts.first?.source, js)
    }

    func testHandle() {
        let configuration = TestConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        let expectation = XCTestExpectation(description: "handler")
        webView.handle("test") { _ in
            expectation.fulfill()
        }
        let handler = configuration._userContentController.handlers["test"]
        XCTAssertNotNil(handler)
        let message = WKScriptMessage()
        handler?.userContentController(configuration.userContentController, didReceive: message)
        wait(for: [expectation], timeout: 0.1)
    }

    func testEvaluateJavaScript() {
        let webView = WKWebView(frame: .zero)
        webView.loadHTMLString("<!DOCTYPE html><html><head><title>Test Title</title></head><body></body></html>", baseURL: URL(string: "https://instructure.com")!)
        XCTAssertFinish(
            webView.waitUntilLoadFinishes(checkInterval: 2),
            timeout: 10
        )

        XCTAssertFirstValueAndCompletion(
            webView.evaluateJavaScript(js: "document.title"),
            timeout: 5
        ) { result in
            XCTAssertEqual(result as? String, "Test Title")
        }
    }
}
