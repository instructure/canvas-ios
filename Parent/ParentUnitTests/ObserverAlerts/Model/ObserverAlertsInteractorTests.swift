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

    private enum TestConstants {
        static let studentID = "some student id"
        static let alertID = "some alert id"
    }

    private var courseSettingsInteractor: MockCourseSettingsInteractor!
    private var testee: ObserverAlertsInteractor!

    override func setUp() {
        super.setUp()
        courseSettingsInteractor = .init()
        testee = .init(
            studentID: TestConstants.studentID,
            courseSettingsInteractor: courseSettingsInteractor
        )
    }

    override func tearDown() {
        courseSettingsInteractor = nil
        testee = nil
        super.tearDown()
    }

    func testLoadsAlertsWhereQuantitativeDataIsNotEnabled() {
        api.mock(GetObserverAlerts(studentID: TestConstants.studentID), value: [
            .make(alert_type: .courseGradeLow, context_id: "c1", id: "a1", user_id: TestConstants.studentID),
            .make(alert_type: .courseGradeLow, context_id: "c2", id: "a2", user_id: TestConstants.studentID)
        ])
        api.mock(GetAlertThresholds(studentID: TestConstants.studentID), value: [])
        // course c2 has restrict quantitative data enabled
        courseSettingsInteractor.mockedCourseIDsResponse = ["c2"]

        // WHEN
        let resultPublisher = testee.refresh()

        // THEN
        XCTAssertFirstValueAndCompletion(resultPublisher, timeout: 1) { (alerts, thresholds) in
            XCTAssertEqual(alerts.count, 1)
            XCTAssertEqual(alerts.first?.id, "a1")
            XCTAssertEqual(thresholds.isEmpty, true)
        }
        XCTAssertEqual(courseSettingsInteractor.receivedSettingsKey, \.restrictQuantitativeData)
        XCTAssertEqual(courseSettingsInteractor.receivedExpectedValue, true)
        XCTAssertEqual(Set(courseSettingsInteractor.receivedCourseIDs ?? []), Set(["c1", "c2"]))
    }

    func testMarkAlertAsRead() {
        let useCase = MarkObserverAlertAsRead(id: TestConstants.alertID)
        let expectation = XCTestExpectation(description: "Request was sent")
        api.mock(useCase, expectation: expectation)

        let publisher = testee.markAlertAsRead(id: TestConstants.alertID)
        XCTAssertFinish(publisher)

        wait(for: [expectation], timeout: 1)
    }

    func testDismissObserverAlert() {
        let useCase = DismissObserverAlert(id: TestConstants.alertID)
        let expectation = XCTestExpectation(description: "Request was sent")
        api.mock(useCase, expectation: expectation)

        let publisher = testee.dismissAlert(id: TestConstants.alertID)
        XCTAssertFinish(publisher)

        wait(for: [expectation], timeout: 1)
    }
}

private final class MockCourseSettingsInteractor: CourseSettingsInteractor {

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
