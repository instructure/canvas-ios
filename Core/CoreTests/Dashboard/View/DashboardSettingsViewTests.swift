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
import TestsFoundation

class DashboardSettingsViewTests: CoreTestCase {

    // MARK: - Options Switches

    func testBothSwitchesVisible() {
        let interactor = DashboardSettingsInteractorPreview(isGradesSwitchVisible: true,
                                                            isColorOverlaySwitchVisible: true)
        let tree = createView(interactor: interactor)
        XCTAssertNotNil(tree.find(id: "DashboardSettings.Switch.Grades"))
        XCTAssertNotNil(tree.find(id: "DashboardSettings.Switch.ColorOverlay"))
    }

    func testOnlyGradeSwitchVisible() {
        let interactor = DashboardSettingsInteractorPreview(isGradesSwitchVisible: true,
                                                            isColorOverlaySwitchVisible: false)
        let tree = createView(interactor: interactor)
        XCTAssertNotNil(tree.find(id: "DashboardSettings.Switch.Grades"))
        XCTAssertNil(tree.find(id: "DashboardSettings.Switch.ColorOverlay"))
    }

    func testOnlyColorOverlaySwitchVisible() {
        let interactor = DashboardSettingsInteractorPreview(isGradesSwitchVisible: false,
                                                            isColorOverlaySwitchVisible: true)
        let tree = createView(interactor: interactor)
        XCTAssertNil(tree.find(id: "DashboardSettings.Switch.Grades"))
        XCTAssertNotNil(tree.find(id: "DashboardSettings.Switch.ColorOverlay"))
    }

    func testSwitchesInitialStatesWhenSwitchesAreVisible() {
        let interactor = DashboardSettingsInteractorPreview(isGradesSwitchVisible: true,
                                                            isColorOverlaySwitchVisible: true)
        interactor.showGrades.send(true)
        interactor.colorOverlay.send(true)
        let tree = createView(interactor: interactor)
        XCTAssertEqual(tree.find(id: "DashboardSettings.Switch.Grades")?.info("selected"),
                       true)
        XCTAssertEqual(tree.find(id: "DashboardSettings.Switch.ColorOverlay")?.info("selected"),
                       true)
    }

    func testSwitchesInitialStatesWhenSwitchesAreNotVisible() {
        let interactor = DashboardSettingsInteractorPreview(isGradesSwitchVisible: true,
                                                            isColorOverlaySwitchVisible: true)
        interactor.showGrades.send(false)
        interactor.colorOverlay.send(false)
        let tree = createView(interactor: interactor)
        XCTAssertEqual(tree.find(id: "DashboardSettings.Switch.Grades")?.info("selected"),
                       false)
        XCTAssertEqual(tree.find(id: "DashboardSettings.Switch.ColorOverlay")?.info("selected"),
                       false)
    }

    private func createView(interactor: DashboardSettingsInteractor) -> TestTree {
        let viewModel = DashboardSettingsViewModel(interactor: interactor)
        let view = DashboardSettingsView(viewModel: viewModel)
        return hostSwiftUIController(view).testTree!
    }
}
