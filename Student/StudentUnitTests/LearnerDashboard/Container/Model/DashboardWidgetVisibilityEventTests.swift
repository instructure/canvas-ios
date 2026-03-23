//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

final class DashboardWidgetVisibilityEventTests: XCTestCase {

    func test_params_allVisible_assignsPositionsByOrder() {
        let configs = [
            DashboardWidgetConfig(id: .helloWidget, order: 0, isVisible: true),
            DashboardWidgetConfig(id: .coursesAndGroups, order: 1, isVisible: true),
            DashboardWidgetConfig(id: .weeklySummary, order: 2, isVisible: true)
        ]
        let params = DashboardWidgetVisibilityEvent(configs: configs).params

        XCTAssertEqual(params["welcome"] as? String, "0")
        XCTAssertEqual(params["courses"] as? String, "1")
        XCTAssertEqual(params["forecast"] as? String, "2")
    }

    func test_params_hiddenWidget_isReportedAsMinusOne() {
        let configs = [
            DashboardWidgetConfig(id: .helloWidget, order: 0, isVisible: false),
            DashboardWidgetConfig(id: .coursesAndGroups, order: 1, isVisible: true),
            DashboardWidgetConfig(id: .weeklySummary, order: 2, isVisible: true)
        ]
        let params = DashboardWidgetVisibilityEvent(configs: configs).params

        XCTAssertEqual(params["welcome"] as? String, "-1")
        XCTAssertEqual(params["courses"] as? String, "0")
        XCTAssertEqual(params["forecast"] as? String, "1")
    }

    func test_params_customOrder_positionsReflectSortedOrder() {
        let configs = [
            DashboardWidgetConfig(id: .helloWidget, order: 20, isVisible: true),
            DashboardWidgetConfig(id: .coursesAndGroups, order: 5, isVisible: true),
            DashboardWidgetConfig(id: .weeklySummary, order: 10, isVisible: true)
        ]
        let params = DashboardWidgetVisibilityEvent(configs: configs).params

        XCTAssertEqual(params["courses"] as? String, "0")
        XCTAssertEqual(params["forecast"] as? String, "1")
        XCTAssertEqual(params["welcome"] as? String, "2")
    }

    func test_params_allHidden_allReportedAsMinusOne() {
        let configs = [
            DashboardWidgetConfig(id: .helloWidget, order: 0, isVisible: false),
            DashboardWidgetConfig(id: .coursesAndGroups, order: 1, isVisible: false),
            DashboardWidgetConfig(id: .weeklySummary, order: 2, isVisible: false)
        ]
        let params = DashboardWidgetVisibilityEvent(configs: configs).params

        XCTAssertEqual(params["welcome"] as? String, "-1")
        XCTAssertEqual(params["courses"] as? String, "-1")
        XCTAssertEqual(params["forecast"] as? String, "-1")
    }

    func test_analyticsEventName() {
        let event = DashboardWidgetVisibilityEvent(configs: [])
        XCTAssertEqual(event.analyticsEventName, "dashboard_widget_visibility")
    }
}
