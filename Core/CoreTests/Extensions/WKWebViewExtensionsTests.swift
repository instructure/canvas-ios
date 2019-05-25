//
// Copyright (C) 2019-present Instructure, Inc.
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
}
