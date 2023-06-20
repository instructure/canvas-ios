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
import Core
import TestsFoundation
import XCTest

public class ModulesHelper: BaseHelper {
    public static func moduleLabel(moduleIndex: Int) -> Element {
        app.find(id: "ModuleList.\(moduleIndex)")
    }

    public static func moduleItem(moduleIndex: Int, itemIndex: Int) -> Element {
        app.find(id: "ModuleList.\(moduleIndex).\(itemIndex)")
    }

    @discardableResult
    public static func createModule(course: DSCourse, name: String, published: Bool = true) -> DSModule {
        let moduleBody = CreateDSModuleRequest.RequestedDSModule(name: name)
        var module = seeder.createModule(courseId: course.id, moduleBody: moduleBody)
        if published {
            module = seeder.updateModuleWithPublished(courseId: course.id, moduleId: module.id, published: true)
        }
        return module
    }

    @discardableResult
    public static func createModuleAssignment(course: DSCourse, module: DSModule, title: String = "Module Assignment", published: Bool = true) -> DSModuleItem {
        let assignment = AssignmentsHelper.createAssignment(course: course, name: title)
        let moduleItemBody = CreateDSModuleItemRequest.RequestedDSModuleItem(title: title, type: .assignment, content_id: assignment.id)
        var moduleItem = seeder.createModuleItem(courseId: course.id, moduleId: module.id, moduleItemBody: moduleItemBody)
        if published {
            moduleItem = seeder.updateModuleItemWithPublished(courseId: course.id, moduleId: module.id, itemId: moduleItem.id, published: published)
        }
        return moduleItem
    }

    public static func navigateToModules(course: DSCourse) {
        Dashboard.courseCard(id: course.id).tap()
        CourseNavigation.modules.tap()
    }
}
