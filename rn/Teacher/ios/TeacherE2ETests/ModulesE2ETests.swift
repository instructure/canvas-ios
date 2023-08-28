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

import TestsFoundation

class ModulesE2ETests: E2ETestCase {
    func testModulesE2E() {
        let teacher = seeder.createUser()
        let course1 = seeder.createCourse()
        let course2 = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course1)
        seeder.enrollTeacher(teacher, in: course2)
        let module = ModulesHelper.createModule(course: course2)
        let moduleAssignment = ModulesHelper.createModuleAssignment(course: course2, module: module)

        logInDSUser(teacher)
        let courseCard1 = DashboardHelper.courseCard(course: course1).waitUntil(.visible)
        courseCard1.hit()
        let modulesButton = CourseDetailsHelper.cell(type: .modules)
        modulesButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable)
        modulesButton.hit()
        app.find(labelContaining: "No Modules").waitUntil(.visible)
        ModulesHelper.backButton.hit()
        ModulesHelper.backButton.hit()
        let courseCard2 = DashboardHelper.courseCard(course: course2).waitUntil(.visible)
        courseCard2.hit()
        modulesButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable)
        modulesButton.hit()
        let moduleElement = ModulesHelper.moduleItem(moduleIndex: 0, itemIndex: 0).waitUntil(.visible)
        XCTAssertTrue(moduleElement.isVisible)
        XCTAssertEqual(ModulesHelper.moduleItemNameLabel(moduleIndex: 0, itemIndex: 0).waitUntil(.visible).label, moduleAssignment.title)

        moduleElement.hit()
        app.find(labelContaining: moduleAssignment.title).waitUntil(.visible)
        ModulesHelper.backButton.hit()
        ModulesHelper.backButton.hit()
        ModulesHelper.backButton.hit()
        XCTAssertTrue(courseCard1.waitUntil(.visible).isVisible)
        XCTAssertTrue(courseCard2.waitUntil(.visible).isVisible)
    }
}
