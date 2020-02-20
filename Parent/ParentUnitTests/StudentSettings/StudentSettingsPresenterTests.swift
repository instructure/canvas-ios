//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
@testable import Parent
@testable import Core
import TestsFoundation

class StudentSettingsPresenterTests: ParentTestCase {
    var resultingError: NSError?
    var presenter: StudentSettingsPresenter!
    var expectation = XCTestExpectation(description: "expectation")
    var updateExpectation = XCTestExpectation(description: "expectation")
    var removeExpectation = XCTestExpectation(description: "expectation")
    let userID = "1"

    override func setUp() {
        super.setUp()
        expectation = XCTestExpectation(description: "expectation")
        updateExpectation = XCTestExpectation(description: "expectation")
        presenter = StudentSettingsPresenter(environment: env, view: self, studentID: userID)
    }

    func testUseCaseFetchesData() {
        api.mock(GetAlertThresholdRequest(studentID: userID), value: [.make()])

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 0.4)

        XCTAssertEqual(presenter.thresholds.first?.type, AlertThresholdType.assignmentGradeHigh)
        XCTAssertNotNil(presenter.thresholdForType(.assignmentGradeHigh))
    }

    func testCreateAlert() {
        let value = "50"
        let req1 = PostAlertThresholdRequest(userID: userID, alertType: .assignmentGradeLow, value: value)
        let alert = APIAlertThreshold.make(id: "2", observer_id: "5", user_id: userID, alert_type: AlertThresholdType.assignmentGradeLow.rawValue, threshold: value)
        api.mock(req1, value: alert)

        //   when
        presenter.createAlert(value: "50", alertType: .assignmentGradeLow)

        wait(for: [expectation], timeout: 0.4)

        XCTAssertEqual(presenter.thresholds.first?.type, AlertThresholdType.assignmentGradeLow)
        XCTAssertEqual(presenter.thresholds.first?.threshold, "50")
    }

    func testUpdateAlert() {
        let a = APIAlertThreshold.make(threshold: "100")
        api.mock(GetAlertThresholdRequest(studentID: userID), value: [a])
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 5)

        let value = "50"
        let req1 = PutAlertThresholdRequest(thresholdID: a.id, alertType: AlertThresholdType(rawValue: a.alert_type)!, value: value)
        let alert = APIAlertThreshold.make(id: "2", observer_id: "5", user_id: userID, alert_type: AlertThresholdType.assignmentGradeHigh.rawValue, threshold: value)
        api.mock(req1, value: alert)

        //   when
        presenter.updateAlert(value: value, alertType: .assignmentGradeHigh, thresholdID: a.id)

        wait(for: [updateExpectation], timeout: 5)

        XCTAssertEqual(presenter.thresholds.first?.type, AlertThresholdType.assignmentGradeHigh)
        XCTAssertEqual(presenter.thresholds.first?.threshold, "50")
    }

    func testDeleteAlert() {
        removeExpectation.expectedFulfillmentCount = 4
        api.mock(GetAlertThresholdRequest(studentID: userID), value: [.make(id: "1")])

        let req1 = DeleteAlertThresholdRequest(thresholdID: "1")
        api.mock(req1, value: nil)

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 5)

        presenter.removeAlert(alertID: "1")
        wait(for: [removeExpectation], timeout: 5)
        XCTAssertNil(presenter.thresholds.first)
    }
}

extension StudentSettingsPresenterTests: StudentSettingsViewProtocol {
    func showAlert(title: String?, message: String?) {}

    func didUpdateAlert() {
        updateExpectation.fulfill()
    }

    func update() {
        if presenter.thresholds.pending == false {
            expectation.fulfill()
        }
        removeExpectation.fulfill()
    }
}
