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

@testable import Core
import WebKit
import XCTest

class ForceDisableHorizontalScrollTests: XCTestCase {

    func testContentOffsetXOverride() {
        // GIVEN
        let webView = CoreWebView()
        webView.scrollView.contentOffset = CGPoint(x: 100, y: 100)
        XCTAssertNil(webView.scrollView.delegate)
        let testee = CoreWebViewFeature.forceDisableHorizontalScroll
        testee.apply(on: webView)
        XCTAssertNotNil(webView.scrollView.delegate)
        XCTAssertEqual(webView.scrollView.contentOffset, CGPoint(x: 100, y: 100))

        // WHEN
        webView.scrollView.delegate?.scrollViewDidScroll?(webView.scrollView)

        // THEN
        XCTAssertEqual(webView.scrollView.contentOffset, CGPoint(x: 0, y: 100))
    }
}
