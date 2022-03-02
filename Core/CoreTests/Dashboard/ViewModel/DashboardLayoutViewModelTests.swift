//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

class DashboardLayoutViewModelTests: CoreTestCase {

    func testInitialButtonStateForGridLayout() {
        environment.userDefaults?.isDashboardLayoutGrid = true
        let testee = DashboardLayoutViewModel()
        XCTAssertEqual(testee.buttonImage, .dashboardLayoutList)
        XCTAssertEqual(testee.buttonA11yLabel, NSLocalizedString("Change dashboard layout to list", comment: ""))
    }

    func testInitialButtonStateForListLayout() {
        environment.userDefaults?.isDashboardLayoutGrid = false
        let testee = DashboardLayoutViewModel()
        XCTAssertEqual(testee.buttonImage, .dashboardLayoutGrid)
        XCTAssertEqual(testee.buttonA11yLabel, NSLocalizedString("Change dashboard layout to grid", comment: ""))
    }

    func testToggleChangesButtonImage() {
        let buttonChangeEvent = expectation(description: "UI update received")
        buttonChangeEvent.expectedFulfillmentCount = 2 // initial state, change
        var listButtonImageReceived = false
        var gridButtonImageReceived = false
        let testee = DashboardLayoutViewModel()
        let subscription = testee.$buttonImage.sink { image in
            buttonChangeEvent.fulfill()

            if image == .dashboardLayoutList {
                listButtonImageReceived = true
            } else if image == .dashboardLayoutGrid {
                gridButtonImageReceived = true
            }
        }

        testee.toggle()
        wait(for: [buttonChangeEvent], timeout: 0.1)
        XCTAssertTrue(listButtonImageReceived)
        XCTAssertTrue(gridButtonImageReceived)

        subscription.cancel()
    }

    func testTogglePersistsState() {
        let initialState = environment.userDefaults!.isDashboardLayoutGrid
        let testee = DashboardLayoutViewModel()

        testee.toggle()

        let newState = environment.userDefaults!.isDashboardLayoutGrid
        XCTAssertNotEqual(initialState, newState)
    }

    func testGridLayoutCalculation() {
        environment.userDefaults?.isDashboardLayoutGrid = true
        let testee = DashboardLayoutViewModel()

        let smallLayout = testee.layoutInfo(for: 600)
        XCTAssertEqual(smallLayout.columns, 2)
        let largeLayout = testee.layoutInfo(for: 650)
        XCTAssertEqual(largeLayout.columns, 4)
    }

    func testListLayoutCalculation() {
        environment.userDefaults?.isDashboardLayoutGrid = false
        let testee = DashboardLayoutViewModel()

        let smallLayout = testee.layoutInfo(for: 600)
        XCTAssertEqual(smallLayout.columns, 1)
        let largeLayout = testee.layoutInfo(for: 650)
        XCTAssertEqual(largeLayout.columns, 1)
    }

    func testAnalyticsReportforGridLayout() {
        environment.userDefaults?.isDashboardLayoutGrid = true
        _ = DashboardLayoutViewModel()

        guard
              analytics.events.count == 1,
              let eventName = analytics.events.last?.name,
              let params = analytics.events.last?.parameters
        else {
            XCTFail("Unexpected event or parameter count")
            return
        }

        XCTAssertEqual(eventName, "dashboard_layout")
        XCTAssertEqual(params as? [String: String], ["type": "grid"])
    }

    func testAnalyticsReportforListLayout() {
        environment.userDefaults?.isDashboardLayoutGrid = false
        _ = DashboardLayoutViewModel()

        guard
              analytics.events.count == 1,
              let eventName = analytics.events.last?.name,
              let params = analytics.events.last?.parameters
        else {
            XCTFail("Unexpected event or parameter count")
            return
        }

        XCTAssertEqual(eventName, "dashboard_layout")
        XCTAssertEqual(params as? [String: String], ["type": "list"])
    }
}
