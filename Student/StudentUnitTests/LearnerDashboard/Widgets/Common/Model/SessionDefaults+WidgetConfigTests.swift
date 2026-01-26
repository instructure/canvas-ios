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

final class SessionDefaultsWidgetConfigTests: XCTestCase {

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
        testee["learnerDashboardWidgetConfigs"] = Data("invalid json".utf8)

        XCTAssertEqual(testee.learnerDashboardWidgetConfigs, nil)
    }

    func test_getter_whenValidDataStored_shouldDecodeAndReturnConfigs() {
        let configs = [
            WidgetConfig(id: .widget1, order: 7, isVisible: true, settings: "some settings"),
            WidgetConfig(id: .widget2, order: 42, isVisible: false, settings: nil)
        ]
        let data = try! JSONEncoder().encode(configs)
        testee["learnerDashboardWidgetConfigs"] = data

        let result = testee.learnerDashboardWidgetConfigs

        XCTAssertEqual(result?.count, 2)
        XCTAssertEqual(result?[0].id, .widget1)
        XCTAssertEqual(result?[0].order, 7)
        XCTAssertEqual(result?[0].isVisible, true)
        XCTAssertEqual(result?[0].settings, "some settings")
        XCTAssertEqual(result?[1].id, .widget2)
        XCTAssertEqual(result?[1].order, 42)
        XCTAssertEqual(result?[1].isVisible, false)
        XCTAssertEqual(result?[1].settings, nil)
    }

    // MARK: - Set

    func test_setter_withValidConfigs_shouldEncodeAndStore() {
        let configs = [
            WidgetConfig(id: .widget1, order: 7, isVisible: true, settings: "some settings"),
            WidgetConfig(id: .widget3, order: 100, isVisible: false, settings: nil)
        ]

        testee.learnerDashboardWidgetConfigs = configs

        let storedData = testee["learnerDashboardWidgetConfigs"] as? Data
        XCTAssertNotEqual(storedData, nil)

        let decoded = try! JSONDecoder().decode([WidgetConfig].self, from: storedData!)
        XCTAssertEqual(decoded.count, 2)
        XCTAssertEqual(decoded[0].id, .widget1)
        XCTAssertEqual(decoded[0].order, 7)
        XCTAssertEqual(decoded[1].id, .widget3)
        XCTAssertEqual(decoded[1].order, 100)
    }

    func test_setter_withNil_shouldRemoveStoredData() {
        let configs = [WidgetConfig(id: .widget1, order: 7, isVisible: true)]
        testee.learnerDashboardWidgetConfigs = configs
        XCTAssertNotNil(testee["learnerDashboardWidgetConfigs"])

        testee.learnerDashboardWidgetConfigs = nil

        XCTAssertNil(testee["learnerDashboardWidgetConfigs"])
    }
}
