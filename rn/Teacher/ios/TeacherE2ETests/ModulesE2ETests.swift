//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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
import TestsFoundation

class ModulesE2ETests: CoreUITestCase {
    func testModulesE2E() {
        Dashboard.courseCard(id: "5586").waitToExist()
        Dashboard.courseCard(id: "5586").tap()
        CourseNavigation.modules.tap()
        app.find(labelContaining: "No Modules").waitToExist()
        NavBar.backButton.tap()
        NavBar.backButton.tap()
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.modules.tap()
        XCTAssertEqual(ModuleList.item(section: 0, row: 0).label(), "assignment, Assignment One, published")
        ModuleList.item(section: 0, row: 0).tap()
        AssignmentDetails.description("This is assignment one.").waitToExist()
        NavBar.backButton.tap()
        NavBar.backButton.tap()
        NavBar.backButton.tap()
        XCTAssertTrue(Dashboard.courseCard(id: "263").exists())
    }
}
