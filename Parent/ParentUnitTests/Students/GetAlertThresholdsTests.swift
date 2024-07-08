//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import Parent

class GetAlertThresholdsTests: ParentTestCase {
    let studentID: String = "1"

    func testGetThresholds() {
        let useCase = GetAlertThresholds(studentID: studentID)
        XCTAssertEqual(useCase.cacheKey, "get-alertthresholds-\(studentID)")
        XCTAssertEqual(useCase.scope, Scope.where(#keyPath(AlertThreshold.studentID), equals: studentID))
        XCTAssertEqual(useCase.request.studentID, studentID)

        useCase.write(response: [
            .make(id: "1", observer_id: studentID, alert_type: .courseGradeLow, threshold: 50)
        ], urlResponse: nil, to: databaseClient)
        let alerts: [AlertThreshold] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(alerts.count, 1)
        XCTAssertEqual(alerts[0].type, .courseGradeLow)
        XCTAssertEqual(alerts[0].value, 50)
    }

    func testRemoveAlertThreshold() {
        let alert = APIAlertThreshold.make()
        AlertThreshold.make(from: alert)
        let useCase = RemoveAlertThreshold(thresholdID: alert.id.value)
        XCTAssertEqual(useCase.cacheKey, nil)
        XCTAssertEqual(useCase.scope, Scope.where(#keyPath(AlertThreshold.id), equals: alert.id.value))
        XCTAssertEqual(useCase.request.thresholdID, alert.id.value)

        useCase.reset(context: databaseClient)
        useCase.write(response: alert, urlResponse: nil, to: databaseClient)
        let alerts: [AlertThreshold] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(alerts.count, 0)
    }

    func testCreateAlertThreshold() {
        let useCase = CreateAlertThreshold(userID: studentID, value: 10, alertType: .courseGradeLow)
        XCTAssertEqual(useCase.cacheKey, nil)
        XCTAssertEqual(useCase.request.body?.observer_alert_threshold.user_id, studentID)
        XCTAssertEqual(useCase.request.body?.observer_alert_threshold.alert_type, .courseGradeLow)
        XCTAssertEqual(useCase.request.body?.observer_alert_threshold.threshold, 10)
    }

    func testUpdateAlertThreshold() {
        let useCase = UpdateAlertThreshold(thresholdID: "1", value: 60, alertType: .courseGradeHigh)
        XCTAssertEqual(useCase.cacheKey, nil)
        XCTAssertEqual(useCase.request.body?.alert_type, .courseGradeHigh)
        XCTAssertEqual(useCase.request.body?.threshold, 60)
    }
}
