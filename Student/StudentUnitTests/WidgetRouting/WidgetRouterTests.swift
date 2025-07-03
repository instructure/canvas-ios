//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
@testable import Student
import TestsFoundation

class WidgetRouterTests: StudentTestCase {

    private let testWidgetName = "random-widget"
    private var view: MockAppViewProxy!
    private var widgetRouter: WidgetRouter!
    private var urlsHandled: [String] = []

    override func setUp() {
        super.setUp()

        urlsHandled.removeAll()
        view = MockAppViewProxy()
        widgetRouter = WidgetRouter(originValue: testWidgetName, handlers: [
            .init("/section/page", action: { [weak self] url, _, proxy in
                proxy.selectTab(at: 2)
                self?.urlsHandled.append(url.path)
            }),
            .init("/another-section/:page", action: { [weak self] url, _, proxy in
                proxy.selectTab(at: 4)
                self?.urlsHandled.append(url.path)
            })
        ])
    }

    func testWidgetRouteOrigin() {
        var url = testURL(path: "/section/page", query: ["origin": "another-widget"])

        XCTAssertFalse(widgetRouter.handling(url, using: view))
        XCTAssertTrue(urlsHandled.isEmpty)

        url = testURL(path: "/section/page")

        XCTAssertFalse(widgetRouter.handling(url, using: view))
        XCTAssertTrue(urlsHandled.isEmpty)

        url = testURL(path: "/section/page", query: ["origin": testWidgetName])

        XCTAssertTrue(widgetRouter.handling(url, using: view))
        XCTAssertEqual(urlsHandled.last, "/section/page")
    }

    func testWidgetRouteViewProxy() {

        var url = testURL(path: "/section/page", query: ["origin": testWidgetName])

        XCTAssertTrue(widgetRouter.handling(url, using: view))
        XCTAssertEqual(urlsHandled.last, "/section/page")
        XCTAssertEqual(view.selectedTabIndex, 2)

        url = testURL(path: "/another-section/example", query: ["origin": testWidgetName])

        XCTAssertTrue(widgetRouter.handling(url, using: view))
        XCTAssertEqual(urlsHandled.last, "/another-section/example")
        XCTAssertEqual(view.selectedTabIndex, 4)

        url = testURL(path: "/another-section/another-example", query: ["origin": testWidgetName])

        XCTAssertTrue(widgetRouter.handling(url, using: view))
        XCTAssertEqual(urlsHandled.last, "/another-section/another-example")
        XCTAssertEqual(view.selectedTabIndex, 4)
    }
}
