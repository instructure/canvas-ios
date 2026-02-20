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

@testable import Core
@testable import Student
import XCTest

final class SessionDefaultsDashboardWidgetConfigTests: XCTestCase {

    private var testee: SessionDefaults!

    override func setUp() {
        super.setUp()
        testee = SessionDefaults(sessionID: "test-session")
    }

    override func tearDown() {
        testee.reset()
        testee = nil
        super.tearDown()
    }

    // MARK: - Get

    func test_getter_whenNoDataStored_shouldReturnNil() {
        XCTAssertEqual(testee.learnerDashboardWidgetConfigs, nil)
    }

    func test_getter_whenInvalidDataStored_shouldReturnNil() {
        testee["dashboardWidgetConfigs"] = Data("invalid json".utf8)

        XCTAssertEqual(testee.learnerDashboardWidgetConfigs, nil)
    }

    func test_getter_whenValidDataStored_shouldDecodeAndReturnConfigs() {
        let configs = [
            DashboardWidgetConfig(id: .helloWidget, order: 7, isVisible: true, settings: "some settings"),
            DashboardWidgetConfig(id: .coursesAndGroups, order: 42, isVisible: false, settings: nil)
        ]
        let data = try! JSONEncoder().encode(configs)
        testee["dashboardWidgetConfigs"] = data

        let result = testee.learnerDashboardWidgetConfigs

        XCTAssertEqual(result?.count, 2)
        XCTAssertEqual(result?[0].id, .helloWidget)
        XCTAssertEqual(result?[0].order, 7)
        XCTAssertEqual(result?[0].isVisible, true)
        XCTAssertEqual(result?[0].settings, "some settings")
        XCTAssertEqual(result?[1].id, .coursesAndGroups)
        XCTAssertEqual(result?[1].order, 42)
        XCTAssertEqual(result?[1].isVisible, false)
        XCTAssertEqual(result?[1].settings, nil)
    }

    // MARK: - Set

    func test_setter_withValidConfigs_shouldEncodeAndStore() {
        let configs = [
            DashboardWidgetConfig(id: .helloWidget, order: 7, isVisible: true, settings: "some settings"),
            DashboardWidgetConfig(id: .coursesAndGroups, order: 100, isVisible: false, settings: nil)
        ]

        testee.learnerDashboardWidgetConfigs = configs

        let storedData = testee["dashboardWidgetConfigs"] as? Data
        XCTAssertNotEqual(storedData, nil)

        let decoded = try! JSONDecoder().decode([DashboardWidgetConfig].self, from: storedData!)
        XCTAssertEqual(decoded.count, 2)
        XCTAssertEqual(decoded[0].id, .helloWidget)
        XCTAssertEqual(decoded[0].order, 7)
        XCTAssertEqual(decoded[1].id, .coursesAndGroups)
        XCTAssertEqual(decoded[1].order, 100)
    }

    func test_setter_withNil_shouldRemoveStoredData() {
        let configs = [DashboardWidgetConfig(id: .helloWidget, order: 7, isVisible: true)]
        testee.learnerDashboardWidgetConfigs = configs
        XCTAssertNotNil(testee["dashboardWidgetConfigs"])

        testee.learnerDashboardWidgetConfigs = nil

        XCTAssertNil(testee["dashboardWidgetConfigs"])
    }
}
