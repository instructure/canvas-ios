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

import XCTest
@testable import Student

final class DashboardWidgetConfigWeeklySummaryWidgetTests: XCTestCase {

    // MARK: - weeklySummarySettings getter

    func test_settings_returnsDefaultWhenNoSettingsStored() {
        let testee = DashboardWidgetConfig.make(settings: nil)

        XCTAssertNil(testee.weeklySummarySettings.expandedFilterId)
    }

    func test_settings_returnsDefaultWhenSettingsIsInvalidJSON() {
        let testee = DashboardWidgetConfig.make(settings: "not valid json")

        XCTAssertNil(testee.weeklySummarySettings.expandedFilterId)
    }

    // MARK: - weeklySummarySettings setter

    func test_settings_persistsExpandedFilterId() {
        var testee = DashboardWidgetConfig.make()

        testee.weeklySummarySettings = WeeklySummaryWidgetSettings(expandedFilterId: "missing")

        XCTAssertEqual(testee.weeklySummarySettings.expandedFilterId, "missing")
    }

    func test_settings_persistsNilExpandedFilterId() {
        var testee = DashboardWidgetConfig.make()
        testee.weeklySummarySettings = WeeklySummaryWidgetSettings(expandedFilterId: "due")

        testee.weeklySummarySettings = WeeklySummaryWidgetSettings(expandedFilterId: nil)

        XCTAssertNil(testee.weeklySummarySettings.expandedFilterId)
    }

    func test_settings_roundTripsAllFilterIds() {
        var testee = DashboardWidgetConfig.make()

        for filterId in ["missing", "due", "newGrades"] {
            testee.weeklySummarySettings = WeeklySummaryWidgetSettings(expandedFilterId: filterId)
            XCTAssertEqual(testee.weeklySummarySettings.expandedFilterId, filterId)
        }
    }
}
