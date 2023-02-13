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
import WebKit
import XCTest

class PullToRefreshTests: XCTestCase {

    func testRefreshControlAdded() {
        let webView = CoreWebView(features: [.pullToRefresh(color: .red)])

        guard let refreshControl = refreshControl(for: webView) else {
            return XCTFail("No refresh control found")
        }

        XCTAssertEqual(refreshControl.color, .red)
        XCTAssertEqual(webView.scrollView.bounces, true)
    }

    func testReloadsWebView() {
        let mockWebView = MockCoreWebView(features: [.pullToRefresh()])

        guard let refreshControl = refreshControl(for: mockWebView) else {
            return XCTFail("No refresh control found")
        }

        refreshControl.sendActions(for: .valueChanged)
        XCTAssertTrue(mockWebView.reloadCalled)
    }

    func refreshControl(for webView: CoreWebView) -> CircleRefreshControl? {
        for case let refresh as CircleRefreshControl in webView.scrollView.subviews {
            return refresh
        }

        return nil
    }
}

class MockCoreWebView: CoreWebView {
    private(set) var reloadCalled = false

    public override func reload() -> WKNavigation? {
        reloadCalled = true
        return nil
    }
}
