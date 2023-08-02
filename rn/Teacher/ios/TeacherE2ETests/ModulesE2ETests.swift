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

class ModulesE2ETests: CoreUITestCase {
    func testModulesE2E() {
        DashboardHelper.courseCard(courseId: "5586").hit()
        let modulesButton = CourseDetailsHelper.cell(type: .modules)
        modulesButton.actionUntilElementCondition(action: .swipeUp, condition: .hittable)
        modulesButton.hit()
        app.find(labelContaining: "No Modules").waitUntil(condition: .visible)
        ModulesHelper.backButton.hit()
        ModulesHelper.backButton.hit()
        DashboardHelper.courseCard(courseId: "263").hit()
        modulesButton.actionUntilElementCondition(action: .swipeUp, condition: .hittable)
        modulesButton.hit()
        XCTAssertEqual(ModulesHelper.moduleItem(moduleIndex: 0, itemIndex: 0).waitUntil(condition: .visible).label,
                       "assignment, Assignment One, published")

        ModulesHelper.moduleItem(moduleIndex: 0, itemIndex: 0).hit()
        app.find(labelContaining: "This is assignment one.").waitUntil(condition: .visible)
        ModulesHelper.backButton.hit()
        ModulesHelper.backButton.hit()
        ModulesHelper.backButton.hit()
        XCTAssertTrue(DashboardHelper.courseCard(courseId: "263").waitUntil(condition: .visible).isVisible)
    }
}
