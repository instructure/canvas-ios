//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import TestsFoundation
import XCTest

final class LearnerDashboardSettingsViewModelTests: StudentTestCase {

    private var testee: LearnerDashboardSettingsViewModel!
    private var testDefaults: SessionDefaults!

    override func setUp() {
        super.setUp()
        testDefaults = SessionDefaults(sessionID: "test-session")
        testDefaults.reset()
    }

    override func tearDown() {
        testee = nil
        testDefaults = nil
        super.tearDown()
    }

    // MARK: - Initialization

    func test_init_shouldSetUseNewLearnerDashboardFromDefaults() {
        testDefaults.preferNewLearnerDashboard = true

        testee = LearnerDashboardSettingsViewModel(defaults: testDefaults)

        XCTAssertEqual(testee.useNewLearnerDashboard, true)
    }

    func test_init_withFalseDefault_shouldSetUseNewLearnerDashboardToFalse() {
        testDefaults.preferNewLearnerDashboard = false

        testee = LearnerDashboardSettingsViewModel(defaults: testDefaults)

        XCTAssertEqual(testee.useNewLearnerDashboard, false)
    }

    // MARK: - Switch to Classic Dashboard

    func test_switchToClassicDashboard_shouldUpdateDefaults() {
        testDefaults.preferNewLearnerDashboard = true
        testee = LearnerDashboardSettingsViewModel(defaults: testDefaults)

        let viewController = UIViewController()
        testee.switchToClassicDashboard(viewController: viewController)

        XCTAssertEqual(testDefaults.preferNewLearnerDashboard, false)
    }

    func test_switchToClassicDashboard_shouldUpdateLocalState() {
        testDefaults.preferNewLearnerDashboard = true
        testee = LearnerDashboardSettingsViewModel(defaults: testDefaults)

        let viewController = UIViewController()
        testee.switchToClassicDashboard(viewController: viewController)

        XCTAssertEqual(testee.useNewLearnerDashboard, false)
    }

    func test_switchToClassicDashboard_shouldDismissViewController() {
        testee = LearnerDashboardSettingsViewModel(defaults: testDefaults)

        let expectation = expectation(description: "dismiss called")
        let mockViewController = MockViewController()
        mockViewController.dismissExpectation = expectation

        testee.switchToClassicDashboard(viewController: mockViewController)

        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(mockViewController.dismissCalled)
    }

    func test_switchToClassicDashboard_shouldPostNotificationAfterDismiss() {
        testee = LearnerDashboardSettingsViewModel(defaults: testDefaults, environment: env)

        let expectation = expectation(forNotification: .dashboardPreferenceChanged, object: nil)
        let mockViewController = MockViewController()
        mockViewController.dismissExpectation = expectation

        testee.switchToClassicDashboard(viewController: mockViewController)

        wait(for: [expectation], timeout: 1)
    }

    func test_switchToClassicDashboard_shouldSetFeedbackFlag() {
        testDefaults.preferNewLearnerDashboard = true
        testDefaults.shouldShowDashboardFeedback = false
        testee = LearnerDashboardSettingsViewModel(defaults: testDefaults)

        let viewController = UIViewController()
        testee.switchToClassicDashboard(viewController: viewController)

        XCTAssertEqual(testDefaults.shouldShowDashboardFeedback, true)
    }
}

private final class MockViewController: UIViewController {
    var dismissCalled = false
    var dismissExpectation: XCTestExpectation?

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissCalled = true
        dismissExpectation?.fulfill()
        completion?()
    }
}
