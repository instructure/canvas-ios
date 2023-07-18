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
    public static func navBar(course: DSCourse) -> Element {
        app.find(id: "Modules, \(course.id)")
    }

    public static func moduleLabel(moduleIndex: Int) -> Element {
        app.find(id: "ModuleList.\(moduleIndex)", type: .button)
    }

    public static func moduleItem(moduleIndex: Int, itemIndex: Int) -> Element {
        app.find(id: "ModuleList.\(moduleIndex).\(itemIndex)", type: .cell)
    }

    public static func moduleItemDueLabel(moduleIndex: Int, itemIndex: Int) -> Element {
        app.find(id: "ModuleList.\(moduleIndex).\(itemIndex).dueLabel")
    }

    public static func moduleItemNameLabel(moduleIndex: Int, itemIndex: Int) -> Element {
        app.find(id: "ModuleList.\(moduleIndex).\(itemIndex).nameLabel")
    }

    @discardableResult
    public static func createModule(course: DSCourse, name: String = "Sample Module", published: Bool = true) -> DSModule {
        let moduleBody = CreateDSModuleRequest.RequestedDSModule(name: name)
        var module = seeder.createModule(courseId: course.id, moduleBody: moduleBody)
        if published {
            module = seeder.updateModuleWithPublished(courseId: course.id, moduleId: module.id, published: true)
        }
        return module
    }

    @discardableResult
    public static func createModuleAssignment(course: DSCourse,
                                              module: DSModule,
                                              title: String = "Module Assignment",
                                              published: Bool = true) -> DSModuleItem {
        let assignment = AssignmentsHelper.createAssignment(course: course, name: title, published: published)
        let moduleItemBody = CreateDSModuleItemRequest.RequestedDSModuleItem(title: title, type: .assignment, content_id: assignment.id)
        var moduleItem = seeder.createModuleItem(courseId: course.id, moduleId: module.id, moduleItemBody: moduleItemBody)
        if published {
            moduleItem = seeder.updateModuleItemWithPublished(courseId: course.id,
                                                              moduleId: module.id,
                                                              itemId: moduleItem.id,
                                                              published: published)
        }
        return moduleItem
    }

    @discardableResult
    public static func createModuleDiscussion(course: DSCourse,
                                              module: DSModule,
                                              title: String = "Module Discussion",
                                              published: Bool = true) -> DSModuleItem {
        let discussion = DiscussionsHelper.createDiscussion(course: course, title: title, published: published)
        let moduleItemBody = CreateDSModuleItemRequest.RequestedDSModuleItem(title: title, type: .discussion, content_id: discussion.id)
        var moduleItem = seeder.createModuleItem(courseId: course.id, moduleId: module.id, moduleItemBody: moduleItemBody)
        if published {
            moduleItem = seeder.updateModuleItemWithPublished(courseId: course.id,
                                                              moduleId: module.id,
                                                              itemId: moduleItem.id,
                                                              published: published)
        }
        return moduleItem
    }

    @discardableResult
    public static func createModulePage(course: DSCourse,
                                        module: DSModule,
                                        title: String = "Module Page",
                                        body: String = "Body of Module Page",
                                        published: Bool = true) -> DSModuleItem {
        let page = PagesHelper.createPage(course: course, title: title, body: body, frontPage: true)
        let moduleItemBody = CreateDSModuleItemRequest.RequestedDSModuleItem(title: title, type: .page, page_url: page.url)
        var moduleItem = seeder.createModuleItem(courseId: course.id, moduleId: module.id, moduleItemBody: moduleItemBody)
        if published {
            moduleItem = seeder.updateModuleItemWithPublished(courseId: course.id,
                                                              moduleId: module.id,
                                                              itemId: moduleItem.id,
                                                              published: published)
        }
        return moduleItem
    }

    @discardableResult
    public static func createModuleQuiz(course: DSCourse,
                                        module: DSModule,
                                        title: String = "Module Quiz",
                                        description: String = "Description of ",
                                        published: Bool = true) -> DSModuleItem {
        var quiz = QuizzesHelper.createQuiz(course: course, title: title, description: description + title, quiz_type: .assignment, published: false)
        QuizzesHelper.createTestQuizQuestions(course: course, quiz: quiz)
        quiz = QuizzesHelper.updateQuiz(course: course, quiz: quiz, published: published)

        let moduleItemBody = CreateDSModuleItemRequest.RequestedDSModuleItem(title: title, type: .quiz, content_id: quiz.id)
        var moduleItem = seeder.createModuleItem(courseId: course.id, moduleId: module.id, moduleItemBody: moduleItemBody)
        if published {
            moduleItem = seeder.updateModuleItemWithPublished(courseId: course.id,
                                                              moduleId: module.id,
                                                              itemId: moduleItem.id,
                                                              published: published)
        }
        return moduleItem
    }

    public static func navigateToModules(course: DSCourse) {
        Dashboard.courseCard(id: course.id).tap()
        CourseNavigation.modules.tap()
    }
}
