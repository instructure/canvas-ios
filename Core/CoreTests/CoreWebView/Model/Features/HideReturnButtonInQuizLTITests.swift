//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import Core

class HideReturnButtonInQuizLTITests: XCTestCase {

    func testDisplayStyleSetToNone() {
        let mockLinkDelegate = MockCoreWebViewLinkDelegate()
        let webView = CoreWebView(features: [.hideReturnButtonInQuizLTI])
        webView.linkDelegate = mockLinkDelegate
        webView.loadHTMLString(
            """
            <a data-automation="sdk-return-button" href="/courses/42" class="test-return-button">
              <span class="css-z2mgls-baseButton__content">
                <span class="css-11xkk0o-baseButton__children">Return</span>
              </span>
            </a>
            """
        )
        wait(for: [mockLinkDelegate.navigationFinishedExpectation], timeout: 10)

        let jsEvaluated = expectation(description: "JS evaluated")
        webView.evaluateJavaScript(
            """
            const returnButton = document.getElementsByClassName('test-return-button')[0];
            const computedStyle = window.getComputedStyle(returnButton);
            computedStyle.getPropertyValue('display');
            """
        ) { result, error in
            XCTAssertEqual(result as? String, "none")
            XCTAssertNil(error)
            jsEvaluated.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}
