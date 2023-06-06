//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import XCTest

class DashboardSettingsInteractorLiveTests: CoreTestCase {
    private var defaults = SessionDefaults.fallback

    // MARK: - Initial Values

    func testGridLayoutAfterInit() {
        defaults.isDashboardLayoutGrid = true
        let testee = DashboardSettingsInteractorLive(environment: environment, defaults: defaults)
        XCTAssertEqual(testee.layout.value, .grid)
    }

    func testListLayoutAfterInit() {
        defaults.isDashboardLayoutGrid = false
        let testee = DashboardSettingsInteractorLive(environment: environment, defaults: defaults)
        XCTAssertEqual(testee.layout.value, .list)
    }

    func testEmptyGradesValueDefaultsToFalseAfterInit() {
        defaults.showGradesOnDashboard = nil
        let testee = DashboardSettingsInteractorLive(environment: environment, defaults: defaults)
        XCTAssertFalse(testee.showGrades.value)
    }

    func testGradesShownValueAfterInit() {
        defaults.showGradesOnDashboard = true
        let testee = DashboardSettingsInteractorLive(environment: environment, defaults: defaults)
        XCTAssertTrue(testee.showGrades.value)
    }

    func testGradesHiddenValueAfterInit() {
        defaults.showGradesOnDashboard = false
        let testee = DashboardSettingsInteractorLive(environment: environment, defaults: defaults)
        XCTAssertFalse(testee.showGrades.value)
    }

    func testColorOverlayShownValueAfterInit() {
        api.mock(GetUserSettings(userID: "self"), value: .make(hide_dashcard_color_overlays: false))
        let testee = DashboardSettingsInteractorLive(environment: environment, defaults: defaults)
        XCTAssertTrue(testee.colorOverlay.value)
    }

    func testColorOverlayHiddenAfterInit() {
        api.mock(GetUserSettings(userID: "self"), value: .make(hide_dashcard_color_overlays: true))
        let testee = DashboardSettingsInteractorLive(environment: environment, defaults: defaults)
        XCTAssertFalse(testee.colorOverlay.value)
    }

    func testTeacherSwitchVisibility() {
        environment.app = .teacher
        let testee = DashboardSettingsInteractorLive(environment: environment, defaults: defaults)
        XCTAssertFalse(testee.isGradesSwitchVisible)
        XCTAssertTrue(testee.isColorOverlaySwitchVisible)
    }

    func testStudentSwitchVisibility() {
        environment.app = .student
        let testee = DashboardSettingsInteractorLive(environment: environment, defaults: defaults)
        XCTAssertTrue(testee.isGradesSwitchVisible)
        XCTAssertTrue(testee.isColorOverlaySwitchVisible)
    }

    // MARK: - Inputs

    func testSavesGradeSwitchState() {
        defaults.showGradesOnDashboard = false
        let testee = DashboardSettingsInteractorLive(environment: environment, defaults: defaults)
        testee.showGrades.send(true)
        XCTAssertTrue(defaults.showGradesOnDashboard ?? false)
    }

    func testSavesLayoutState() {
        defaults.isDashboardLayoutGrid = false
        let testee = DashboardSettingsInteractorLive(environment: environment, defaults: defaults)
        testee.layout.send(.grid)
        XCTAssertTrue(defaults.isDashboardLayoutGrid)
    }

    func testSavesColorOverlaySate() {
        // GIVEN
        api.mock(GetUserSettings(userID: "self"), value: .make(hide_dashcard_color_overlays: true))
        let testee = DashboardSettingsInteractorLive(environment: environment, defaults: defaults)

        let apiExpectation = expectation(description: "Color overlay was uploaded to API")
        let request = PutUserSettingsRequest(manual_mark_as_read: nil,
                                             collapse_global_nav: nil,
                                             hide_dashcard_color_overlays: false,
                                             comment_library_suggestions_enabled: nil)
        api.mock(request) { _ in
            apiExpectation.fulfill()
            return (nil, nil, nil)
        }

        // WHEN
        testee.colorOverlay.send(true)

        // THEN
        waitForExpectations(timeout: 1)
    }

    func testUpdatesLayoutWhenUserDefaultsChanges() {
        defaults.isDashboardLayoutGrid = true
        let testee = DashboardSettingsInteractorLive(environment: environment, defaults: defaults)
        XCTAssertEqual(testee.layout.value, .grid)
        defaults.isDashboardLayoutGrid = false
        XCTAssertEqual(testee.layout.value, .list)
    }
}
