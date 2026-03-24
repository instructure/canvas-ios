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

    func test_init_withNoSavedId_defaultsToFirstColor() {
        userDefaults.learnerDashboardColorId = nil

        testee = LearnerDashboardColorInteractorLive(defaults: userDefaults)

        let expectedColor = testee.availableColors[0].color.asColor
        XCTAssertEqual(testee.dashboardColor.value, expectedColor)
    }

    func test_init_withSavedId_restoresColor() {
        let targetColor = LearnerDashboardColorInteractorLive(defaults: userDefaults).availableColors[3]
        userDefaults.learnerDashboardColorId = targetColor.persistentId

        testee = LearnerDashboardColorInteractorLive(defaults: userDefaults)

        XCTAssertEqual(testee.dashboardColor.value, targetColor.color.asColor)
    }

    func test_init_withUnknownId_defaultsToFirstColor() {
        userDefaults.learnerDashboardColorId = "not-a-real-color-id"

        testee = LearnerDashboardColorInteractorLive(defaults: userDefaults)

        let expectedColor = testee.availableColors[0].color.asColor
        XCTAssertEqual(testee.dashboardColor.value, expectedColor)
    }

    // MARK: - Available Colors

    func test_availableColors_containsExpectedCount() {
        testee = LearnerDashboardColorInteractorLive(defaults: userDefaults)

        let courseColorCount = CourseColorData.all.count
        let additionalColorCount = 1 // black
        XCTAssertEqual(testee.availableColors.count, courseColorCount + additionalColorCount)
    }

    // MARK: - selectColor

    func test_selectColor_updatesSubject() {
        testee = LearnerDashboardColorInteractorLive(defaults: userDefaults)
        let colorToSelect = testee.availableColors[2].color.asColor

        testee.selectColor(colorToSelect)

        XCTAssertEqual(testee.dashboardColor.value, colorToSelect)
    }

    func test_selectColor_persistsIdToDefaults() {
        testee = LearnerDashboardColorInteractorLive(defaults: userDefaults)
        let targetColor = testee.availableColors[4]

        testee.selectColor(targetColor.color.asColor)

        XCTAssertEqual(userDefaults.learnerDashboardColorId, targetColor.persistentId)
    }

    func test_selectColor_withUnknownColor_doesNotChange() {
        userDefaults.learnerDashboardColorId = testee?.availableColors[0].persistentId
        testee = LearnerDashboardColorInteractorLive(defaults: userDefaults)
        let originalColor = testee.dashboardColor.value

        testee.selectColor(.purple)

        XCTAssertEqual(testee.dashboardColor.value, originalColor)
    }
}
