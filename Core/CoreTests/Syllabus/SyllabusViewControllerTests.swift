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

    var vc: SyllabusViewController!

    override func setUp() {
        super.setUp()
        vc = SyllabusViewController.create(courseID: "1")
    }

    func loadView() {
        vc.view.frame = CGRect(x: 0, y: 0, width: 300, height: 800)
        vc.view.layoutIfNeeded()
    }

    func testRender() {
        //  given
        let html = "<body>hello world</body>"
        let webView = MockWebView()

        environment.mockStore = false
        api.mock(vc.presenter.courses, value: APICourse.make(syllabus_body: html))

        //  when
        loadView()
        vc.webView = webView

        vc.viewDidLoad()

        //  then
        XCTAssertEqual(webView.html, html)
    }
}
