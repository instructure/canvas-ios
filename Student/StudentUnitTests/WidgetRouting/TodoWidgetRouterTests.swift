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

class TodoWidgetRouterTests: StudentTestCase {

    private let testWidgetName = "todo-widget"
    private var view: MockAppViewProxy!
    private var widgetRouter: WidgetRouter!

    override func setUp() {
        super.setUp()

        view = MockAppViewProxy()
        widgetRouter = .createTodoRouter()
    }

    func testPossibleRoutes() {

        let testPaths = [
            "/todo-widget/planner-notes",
            "/todo-widget/calendar/\(Date.now.formatted(.queryDayDateStyle))",
            "/todo-widget/calendar/\(Date.distantFuture.formatted(.queryDayDateStyle))",
            "/todo-widget/planner-notes/new",
            "/todo-widget/planner-notes/7438438",
            "/todo-widget/calendar_events/839283",
            "/courses/9834755/assignments/58458",
            "/courses/6847323/assignments/124343/submissions/904958"
        ]

        for path in testPaths {
            let url = testURL(path: path, query: ["origin": testWidgetName])

            XCTAssertTrue(widgetRouter.handling(url, using: view))
            XCTAssertNotNil(view.selectedTabIndex)

            // Reset
            view.selectedTabIndex = nil
        }
    }
}
