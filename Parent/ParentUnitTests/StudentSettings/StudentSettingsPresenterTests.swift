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
    let userID = "1"

    override func setUp() {
        super.setUp()
        expectation = XCTestExpectation(description: "expectation")
        updateExpectation = XCTestExpectation(description: "expectation")
        presenter = StudentSettingsPresenter(environment: env, view: self, studentID: userID)
    }

    func testUseCaseFetchesData() {
        //  given
        AlertThreshold.make()

        //   when
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 0.4)

        //  then
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
        expectation.expectedFulfillmentCount = 3

        let a = AlertThreshold.make(from: .make( threshold: "100"))
        presenter.viewIsReady()

        let value = "50"
        let req1 = PutAlertThresholdRequest(thresholdID: a.id, alertType: a.type!, value: value)
        let alert = APIAlertThreshold.make(id: "2", observer_id: "5", user_id: userID, alert_type: AlertThresholdType.assignmentGradeHigh.rawValue, threshold: value)
        api.mock(req1, value: alert)

        //   when
        presenter.updateAlert(value: value, alertType: .assignmentGradeHigh, thresholdID: a.id)

        wait(for: [expectation, updateExpectation], timeout: 0.4)

        XCTAssertEqual(presenter.thresholds.first?.type, AlertThresholdType.assignmentGradeHigh)
        XCTAssertEqual(presenter.thresholds.first?.threshold, "50")
    }


    func testDeleteAlert() {
        expectation.expectedFulfillmentCount = 4
        let a = AlertThreshold.make()

        let req1 = DeleteAlertThresholdRequest(thresholdID: a.id)
        api.mock(req1, value: nil)

        //   when
        presenter.viewIsReady()
        presenter.removeAlert(alertID: a.id)
        wait(for: [expectation], timeout: 0.4)
        //  then
        XCTAssertNil(presenter.thresholds.first)
    }
}

extension StudentSettingsPresenterTests: StudentSettingsViewProtocol {
    var navigationController: UINavigationController? {
        return nil
    }

    func didUpdateAlert() {
        updateExpectation.fulfill()
    }

    func update() {
        expectation.fulfill()
    }
}
