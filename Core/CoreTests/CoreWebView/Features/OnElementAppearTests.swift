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

class OnElementAppearTests: XCTestCase {

    func testCallbackOnElementAppear() {
        // MARK: - GIVEN
        let appearExpectation = expectation(description: "Callback received")
        let testee = CoreWebViewFeature.onAppear(elementId: "testElement") {
            appearExpectation.fulfill()
        }
        let webView = CoreWebView(features: [testee])

        // MARK: - WHEN
        webView.loadHTMLString("<div id=\"testElement\"></div>")

        // MARK: - THEN
        waitForExpectations(timeout: 5)
    }

    func testNoCallbackOnMismatchingElement() {
        // MARK: - GIVEN
        let appearExpectation = expectation(description: "No callback received")
        appearExpectation.isInverted = true
        let testee = CoreWebViewFeature.onAppear(elementId: "testElement") {
            appearExpectation.fulfill()
        }
        let webView = CoreWebView(features: [testee])

        // MARK: - WHEN
        webView.loadHTMLString("<div id=\"noTestElement\"></div>")

        // MARK: - THEN
        waitForExpectations(timeout: 5)
    }
}
