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

@testable import Core
@testable import Student
import XCTest

final class LearnerDashboardColorInteractorTests: XCTestCase {

    private var testee: LearnerDashboardColorInteractorLive!
    private var userDefaults: SessionDefaults!

    override func setUp() {
        super.setUp()
        userDefaults = SessionDefaults(sessionID: "test-session")
        userDefaults.reset()
    }

    override func tearDown() {
        testee = nil
        userDefaults.reset()
        userDefaults = nil
        super.tearDown()
    }

    // MARK: - Initialization

    func test_init_withNoSavedIndex_defaultsToFirstColor() {
        userDefaults.learnerDashboardColorIndex = nil

        testee = LearnerDashboardColorInteractorLive(defaults: userDefaults)

        let expectedColor = testee.availableColors[0].color
        XCTAssertEqual(testee.dashboardColor.value, expectedColor)
    }

    func test_init_withSavedIndex_restoresColor() {
        userDefaults.learnerDashboardColorIndex = 3

        testee = LearnerDashboardColorInteractorLive(defaults: userDefaults)

        let expectedColor = testee.availableColors[3].color
        XCTAssertEqual(testee.dashboardColor.value, expectedColor)
    }

    func test_init_withOutOfBoundsIndex_defaultsToFirstColor() {
        userDefaults.learnerDashboardColorIndex = 9999

        testee = LearnerDashboardColorInteractorLive(defaults: userDefaults)

        let expectedColor = testee.availableColors[0].color
        XCTAssertEqual(testee.dashboardColor.value, expectedColor)
    }

    // MARK: - Available Colors

    func test_availableColors_containsExpectedCount() {
        testee = LearnerDashboardColorInteractorLive(defaults: userDefaults)

        let courseColorCount = CourseColorsInteractorLive.colors.count
        let additionalColorCount = 2 // white and black
        XCTAssertEqual(testee.availableColors.count, courseColorCount + additionalColorCount)
    }

    // MARK: - selectColor

    func test_selectColor_updatesSubject() {
        testee = LearnerDashboardColorInteractorLive(defaults: userDefaults)
        let colorToSelect = testee.availableColors[2].color

        testee.selectColor(colorToSelect)

        XCTAssertEqual(testee.dashboardColor.value, colorToSelect)
    }

    func test_selectColor_persistsIndexToDefaults() {
        testee = LearnerDashboardColorInteractorLive(defaults: userDefaults)
        let targetIndex = 4
        let colorToSelect = testee.availableColors[targetIndex].color

        testee.selectColor(colorToSelect)

        XCTAssertEqual(userDefaults.learnerDashboardColorIndex, targetIndex)
    }

    func test_selectColor_withUnknownColor_doesNotChange() {
        userDefaults.learnerDashboardColorIndex = 0
        testee = LearnerDashboardColorInteractorLive(defaults: userDefaults)
        let originalColor = testee.dashboardColor.value

        testee.selectColor(.purple)

        XCTAssertEqual(testee.dashboardColor.value, originalColor)
    }
}
