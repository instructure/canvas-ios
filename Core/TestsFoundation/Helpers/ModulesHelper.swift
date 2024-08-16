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

public class ModulesHelper: BaseHelper {
    public static var publishOptionsButton: XCUIElement { app.find(id: "ModuleList.publishOptions") }

    public static func navBar(course: DSCourse) -> XCUIElement {
        return app.find(id: "Modules, \(course.id)")
    }

    public static func moduleLabel(moduleIndex: Int) -> XCUIElement {
        return app.find(id: "ModuleList.\(moduleIndex)", type: .button)
    }

    public static func moduleItem(moduleIndex: Int, itemIndex: Int) -> XCUIElement {
        return app.find(id: "ModuleList.\(moduleIndex).\(itemIndex)", type: .cell)
    }

    public static func moduleItemDueLabel(moduleIndex: Int, itemIndex: Int) -> XCUIElement {
        return app.find(id: "ModuleList.\(moduleIndex).\(itemIndex).dueLabel")
    }

    public static func moduleItemNameLabel(moduleIndex: Int, itemIndex: Int) -> XCUIElement {
        return app.find(id: "ModuleList.\(moduleIndex).\(itemIndex).nameLabel")
    }

    public static func navigateToModules(course: DSCourse) {
        DashboardHelper.courseCard(course: course).hit()
        CourseDetailsHelper.cell(type: .modules).hit()
    }

    public struct PublishOptions {
        public static var publishAllModulesAndItems: XCUIElement { app.find(id: "PublishAllModulesAndItems") }
        public static var publishModulesOnly: XCUIElement { app.find(id: "PublishModulesOnly") }
        public static var unpublishAllModulesAndItems: XCUIElement { app.find(id: "UnpublishAllModulesAndItems") }

        public struct Alert {
            public static var cancel: XCUIElement { app.find(label: "Cancel", type: .button) }
            public static var publish: XCUIElement { app.find(label: "Publish", type: .button) }
            public static var unpublish: XCUIElement { app.find(label: "Unpublish", type: .button) }
        }

        public struct Progress {
            public static var progressTitle: XCUIElement { app.find(id: "ModulePublish.progressTitle") }
            public static var progressIndicator: XCUIElement { app.find(id: "ModulePublish.progressIndicator") }
            public static var cancelButton: XCUIElement { app.find(id: "ModulePublish.cancelButton") }
            public static var dismissButton: XCUIElement { app.find(id: "ModulePublish.dismissButton") }
            public static var doneButton: XCUIElement { app.find(id: "ModulePublish.doneButton") }
        }
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
        moduleItem.points_possible = assignment.points_possible!
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
        moduleItem.points_possible = quiz.points_possible!
        return moduleItem
    }
}
