//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Foundation
import TestsFoundation
import Core

class ModulesTests: E2ETestCase {
    func testModules() {
        // MARK: Seed the usual stuff
        let users = seeder.createUsers(1)
        let course = seeder.createCourse()
        let student = users[0]
        seeder.enrollStudent(student, in: course)

        // MARK: Create module
        let module = ModulesHelper.createModule(course: course, name: "Test Module")
        let moduleAssignment = ModulesHelper.createModuleAssignment(course: course, module: module, title: "Test Module Assignment")

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Navigate to Modules
        ModulesHelper.navigateToModules(course: course)
        let moduleNameLabel = ModulesHelper.moduleLabel(moduleIndex: 0).waitToExist()
        let moduleItemButton = ModulesHelper.moduleItem(moduleIndex: 0, itemIndex: 0).waitToExist()
        XCTAssertTrue(moduleNameLabel.isVisible)
        XCTAssertTrue(moduleItemButton.isVisible)
    }
}
