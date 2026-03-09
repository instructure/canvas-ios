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
import TestsFoundation
import XCTest

final class CoursesAndGroupsWidgetSettingsViewModelTests: StudentTestCase {

    private var testee: CoursesAndGroupsWidgetSettingsViewModel!

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    // MARK: - Initialization - showGrades

    func test_init_showGrades_readsFromUserDefaults_true() {
        env.userDefaults?.showGradesOnDashboard = true

        testee = CoursesAndGroupsWidgetSettingsViewModel(env: env)

        XCTAssertEqual(testee.showGrades, true)
    }

    func test_init_showGrades_readsFromUserDefaults_false() {
        env.userDefaults?.showGradesOnDashboard = false

        testee = CoursesAndGroupsWidgetSettingsViewModel(env: env)

        XCTAssertEqual(testee.showGrades, false)
    }

    // MARK: - Initialization - showColorOverlay

    func test_init_showColorOverlay_readsFromCoreData() {
        _ = UserSettings.save(.make(hide_dashcard_color_overlays: true), in: databaseClient)

        testee = CoursesAndGroupsWidgetSettingsViewModel(env: env)

        XCTAssertEqual(testee.showColorOverlay, false)
    }

    // MARK: - setShowGrades

    func test_setShowGrades_persistsToUserDefaults() {
        env.userDefaults?.showGradesOnDashboard = false
        testee = CoursesAndGroupsWidgetSettingsViewModel(env: env)

        testee.showGrades = true

        XCTAssertEqual(env.userDefaults?.showGradesOnDashboard, true)
    }

    // MARK: - setShowColorOverlay

    func test_setShowColorOverlay_makesApiCall() {
        testee = CoursesAndGroupsWidgetSettingsViewModel(env: env)

        let apiExpectation = expectation(description: "PUT users/self/settings called")
        let request = PutUserSettingsRequest(
            manual_mark_as_read: nil,
            collapse_global_nav: nil,
            hide_dashcard_color_overlays: true,
            comment_library_suggestions_enabled: nil
        )
        api.mock(request) { _ in
            apiExpectation.fulfill()
            return (nil, nil, nil)
        }

        testee.showColorOverlay = false

        waitForExpectations(timeout: 1)
    }
}
