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

@testable import Student
import XCTest

final class DashboardWidgetConfigTests: XCTestCase {

    // MARK: - Comparable

    func test_comparable_shouldCompareByOrder() {
        // WHEN lhs.order < rhs.order
        var lhs = DashboardWidgetConfig(id: .widget1, order: 5, isVisible: true)
        var rhs = DashboardWidgetConfig(id: .widget2, order: 10, isVisible: true)
        // THEN
        XCTAssertEqual(lhs < rhs, true)

        // WHEN lhs.order > rhs.order
        lhs = DashboardWidgetConfig(id: .widget1, order: 15, isVisible: true)
        rhs = DashboardWidgetConfig(id: .widget2, order: 10, isVisible: true)
        // THEN
        XCTAssertEqual(lhs < rhs, false)

        // WHEN lhs.order == rhs.order
        lhs = DashboardWidgetConfig(id: .widget1, order: 10, isVisible: true)
        rhs = DashboardWidgetConfig(id: .widget2, order: 10, isVisible: true)
        // THEN
        XCTAssertEqual(lhs < rhs, false)
    }

    // MARK: - Array extension

    func test_partitionedByLayout_shouldSeparateAndSortWidgets() {
        let widgets = [
            DashboardWidgetConfig(id: .widget1, order: 20, isVisible: true),
            DashboardWidgetConfig(id: .fullWidthWidget, order: 5, isVisible: true),
            DashboardWidgetConfig(id: .widget2, order: 10, isVisible: true),
            DashboardWidgetConfig(id: .widget3, order: 30, isVisible: true)
        ]

        let result = widgets.partitionedByLayout { config in
            config.id == .fullWidthWidget
        }

        XCTAssertEqual(result.fullWidth.count, 1)
        XCTAssertEqual(result.fullWidth.first?.id, .fullWidthWidget)
        XCTAssertEqual(result.grid.count, 3)
        XCTAssertEqual(result.grid[0].id, .widget2)
        XCTAssertEqual(result.grid[1].id, .widget1)
        XCTAssertEqual(result.grid[2].id, .widget3)
    }

    func test_partitionedByLayout_withAllFullWidth_shouldReturnAllInFullWidthArray() {
        let widgets = [
            DashboardWidgetConfig(id: .widget1, order: 20, isVisible: true),
            DashboardWidgetConfig(id: .widget2, order: 10, isVisible: true)
        ]

        let result = widgets.partitionedByLayout { _ in true }

        XCTAssertEqual(result.fullWidth.count, 2)
        XCTAssertEqual(result.fullWidth[0].id, .widget2)
        XCTAssertEqual(result.fullWidth[1].id, .widget1)
        XCTAssertEqual(result.grid.count, 0)
    }

    func test_partitionedByLayout_withAllGrid_shouldReturnAllInGridArray() {
        let widgets = [
            DashboardWidgetConfig(id: .widget1, order: 20, isVisible: true),
            DashboardWidgetConfig(id: .widget2, order: 10, isVisible: true)
        ]

        let result = widgets.partitionedByLayout { _ in false }

        XCTAssertEqual(result.fullWidth.count, 0)
        XCTAssertEqual(result.grid.count, 2)
        XCTAssertEqual(result.grid[0].id, .widget2)
        XCTAssertEqual(result.grid[1].id, .widget1)
    }

    func test_partitionedByLayout_withEmptyArray_shouldReturnEmptyArrays() {
        let widgets: [DashboardWidgetConfig] = []

        let result = widgets.partitionedByLayout { _ in true }

        XCTAssertEqual(result.fullWidth.count, 0)
        XCTAssertEqual(result.grid.count, 0)
    }
}
