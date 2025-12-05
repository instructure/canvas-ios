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

final class WidgetRouterGradeListWidgetTests: StudentTestCase {

    private static let testData = (
        originValue: "grade-list-widget",
        courseID: "42"
    )
    private lazy var testData = Self.testData

    private var view: MockAppViewProxy!
    private var widgetRouter: WidgetRouter!

    override func setUp() {
        super.setUp()
        view = MockAppViewProxy()
        widgetRouter = WidgetRouter.createGradeListRouter()
    }

    override func tearDown() {
        view = nil
        widgetRouter = nil
        super.tearDown()
    }

    // MARK: - Route handling

    func test_handling_whenOriginMatches_shouldSelectDashboardTab() {
        let url = testURL(
            path: "/courses/\(testData.courseID)/grades",
            query: ["origin": testData.originValue]
        )

        XCTAssertEqual(widgetRouter.handling(url, using: view), true)
        XCTAssertEqual(view.selectedTabIndex, 0)
    }

    func test_handling_whenOriginDoesNotMatch_shouldNotHandle() {
        let url = testURL(
            path: "/courses/\(testData.courseID)/grades",
            query: ["origin": "some origin"]
        )

        XCTAssertEqual(widgetRouter.handling(url, using: view), false)
        XCTAssertEqual(view.selectedTabIndex, nil)
    }

    func test_handling_whenNoOrigin_shouldNotHandle() {
        let url = testURL(
            path: "/courses/\(testData.courseID)/grades"
        )

        XCTAssertEqual(widgetRouter.handling(url, using: view), false)
        XCTAssertEqual(view.selectedTabIndex, nil)
    }
}
