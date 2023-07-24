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

import XCTest
@testable import Core
import WebKit

class SyllabusViewControllerTests: CoreTestCase {
    class MockWebView: CoreWebView {
        var html: String = ""
        open override func loadHTMLString(_ string: String, baseURL: URL? = AppEnvironment.shared.currentSession?.baseURL) -> WKNavigation? {
            html = string
            return super.loadHTMLString(string, baseURL: baseURL)
        }
    }

    lazy var controller = SyllabusViewController.create(courseID: "1")

    func testLayout() {
        let html = "<body>hello world</body>"
        let webView = MockWebView(features: [])
        api.mock(controller.courses, value: .make(syllabus_body: html))

        controller.webView = webView
        controller.view.layoutIfNeeded()
        XCTAssertEqual(webView.html, html)

        api.mock(controller.courses, value: .make(syllabus_body: "syllabus"))
        controller.webView.scrollView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(webView.html, "syllabus")
    }
}
