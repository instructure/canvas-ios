//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Core
import XCTest

class InvertColorsInDarkModeTests: XCTestCase {

    func testCSSInjection() {
        let mockLinkDelegate = MockCoreWebViewLinkDelegate()
        let webView = CoreWebView(features: [.invertColorsInDarkMode])
        webView.linkDelegate = mockLinkDelegate
        webView.loadHTMLString("<div>Test</div>")
        wait(for: [mockLinkDelegate.navigationFinishedExpectation], timeout: 10)

        let jsEvaluated = expectation(description: "JS evaluated")
        webView.evaluateJavaScript("document.head.querySelectorAll(\"style\")[2].innerHTML") { result, error in
            XCTAssertTrue((result as! String).contains("filter: invert(100%) hue-rotate(180deg);"))
            XCTAssertNil(error)
            jsEvaluated.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}
