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
import Combine
@testable import Parent
import XCTest

class ObserverAlertsInteractorTests: ParentTestCase {

    func testLoadsAlertsWhereQuantitativeDataIsNotEnabled() {
        api.mock(GetObserverAlerts(studentID: "testStudent"), value: [
            .make(alert_type: .courseGradeLow, context_id: "c1", id: "a1", user_id: "testStudent"),
            .make(alert_type: .courseGradeLow, context_id: "c2", id: "a2", user_id: "testStudent"),
        ])
        api.mock(GetAlertThresholds(studentID: "testStudent"), value: [])
        let mockSettingsInteractor = MockCourseSettingsInteractor()
        // course c2 has restrict quantitative data enabled
        mockSettingsInteractor.mockedCourseIDsResponse = ["c2"]
        let testee = ObserverAlertsInteractor(
            studentID: "testStudent",
            courseSettingsInteractor: mockSettingsInteractor
        )

        // WHEN
        let resultPubliser = testee.refresh()

        // THEN
        XCTAssertFirstValueAndCompletion(resultPubliser, timeout: 1) { (alerts, thresholds) in
            XCTAssertEqual(alerts.count, 1)
            XCTAssertEqual(alerts.first?.id, "a1")
            XCTAssertEqual(thresholds.isEmpty, true)
        }
        XCTAssertEqual(mockSettingsInteractor.receivedSettingsKey, \.restrictQuantitativeData)
        XCTAssertEqual(mockSettingsInteractor.receivedExpectedValue, true)
        XCTAssertEqual(Set(mockSettingsInteractor.receivedCourseIDs ?? []), Set(["c1", "c2"]))
    }
}

class MockCourseSettingsInteractor: CourseSettingsInteractor {

    var mockedCourseIDsResponse: [String] = []
    var receivedSettingsKey: KeyPath<CourseSettings, Bool>?
    var receivedExpectedValue: Bool?
    var receivedCourseIDs: [String]?

    public override func courseIDs(
        where settingKey: KeyPath<CourseSettings, Bool>,
        equals expectedValue: Bool,
        fromCourseIDs courseIDs: [String],
        ignoreCache: Bool = false
    ) -> AnyPublisher<[String], Error> {
        receivedSettingsKey = settingKey
        receivedExpectedValue = expectedValue
        receivedCourseIDs = courseIDs

        return Just(mockedCourseIDsResponse)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
