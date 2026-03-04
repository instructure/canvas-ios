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
        var lhs = DashboardWidgetConfig(id: .helloWidget, order: 5, isVisible: true)
        var rhs = DashboardWidgetConfig(id: .coursesAndGroups, order: 10, isVisible: true)
        // THEN
        XCTAssertEqual(lhs < rhs, true)

        // WHEN lhs.order > rhs.order
        lhs = DashboardWidgetConfig(id: .helloWidget, order: 15, isVisible: true)
        rhs = DashboardWidgetConfig(id: .coursesAndGroups, order: 10, isVisible: true)
        // THEN
        XCTAssertEqual(lhs < rhs, false)

        // WHEN lhs.order == rhs.order
        lhs = DashboardWidgetConfig(id: .helloWidget, order: 10, isVisible: true)
        rhs = DashboardWidgetConfig(id: .coursesAndGroups, order: 10, isVisible: true)
        // THEN
        XCTAssertEqual(lhs < rhs, false)
    }
}
