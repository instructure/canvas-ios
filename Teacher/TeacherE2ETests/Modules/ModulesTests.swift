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

import TestsFoundation
import XCTest

class ModulesTests: E2ETestCase {
    typealias Helper = ModulesHelper

    func testModuleItems() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Create module with assignment, discussion, page, quiz items
        let module = Helper.createModule(course: course, name: "DS Module")
        let moduleAssignment = Helper.createModuleAssignment(course: course, module: module, title: "Assignment of DS Module")
        let moduleDiscussion = Helper.createModuleDiscussion(course: course, module: module, title: "Discussion of DS Module")
        let modulePage = Helper.createModulePage(course: course, module: module, title: "Page of DS Module")
        let moduleQuiz = Helper.createModuleQuiz(course: course, module: module, title: "Quiz of DS Module")

        // MARK: Get the user logged in
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)

        // MARK: Navigate to Modules
        Helper.navigateToModules(course: course)
        let publishOptionsButton = Helper.publishOptionsButton.waitUntil(.visible)
        let moduleNameLabel = Helper.moduleLabel(moduleIndex: 0).waitUntil(.visible)
        XCTAssertVisible(publishOptionsButton)
        XCTAssertVisible(moduleNameLabel)
        XCTAssertContains(moduleNameLabel.label, module.name)

        // MARK: Check assignment module item
        let assignmentItem = Helper.moduleItem(moduleIndex: 0, itemIndex: 0).waitUntil(.visible)
        let assignmentTitle = Helper.moduleItemNameLabel(moduleIndex: 0, itemIndex: 0).waitUntil(.visible)
        let assignmentPoints = Helper.moduleItemDueLabel(moduleIndex: 0, itemIndex: 0).waitUntil(.visible)
        XCTAssertVisible(assignmentItem)
        XCTAssertVisible(assignmentTitle)
        XCTAssertEqual(assignmentTitle.label, moduleAssignment.title)
        XCTAssertVisible(assignmentPoints)

        // TODO: Update the below line once the points label bug is fixed
        let pointsString = moduleAssignment.points_possible! == 1 ? "pts" : "pts"
        XCTAssertEqual(assignmentPoints.label, "\(moduleAssignment.points_possible!) \(pointsString)")

        // MARK: Check discussion module item
        let discussionItem = Helper.moduleItem(moduleIndex: 0, itemIndex: 1).waitUntil(.visible)
        let discussionTitle = Helper.moduleItemNameLabel(moduleIndex: 0, itemIndex: 1).waitUntil(.visible)
        XCTAssertVisible(discussionItem)
        XCTAssertVisible(discussionTitle)
        XCTAssertEqual(discussionTitle.label, moduleDiscussion.title)

        // MARK: Check page module item
        let pageItem = Helper.moduleItem(moduleIndex: 0, itemIndex: 2).waitUntil(.visible)
        let pageTitle = Helper.moduleItemNameLabel(moduleIndex: 0, itemIndex: 2).waitUntil(.visible)
        XCTAssertVisible(pageItem)
        XCTAssertVisible(pageTitle)
        XCTAssertEqual(pageTitle.label, modulePage.title)

        // MARK: Check quiz module item
        let quizItem = Helper.moduleItem(moduleIndex: 0, itemIndex: 3).waitUntil(.visible)
        let quizTitle = Helper.moduleItemNameLabel(moduleIndex: 0, itemIndex: 3).waitUntil(.visible)
        XCTAssertVisible(quizItem)
        XCTAssertVisible(quizTitle)
        XCTAssertEqual(quizTitle.label, moduleQuiz.title)
    }

    func testBulkPublishAllModulesAndItems() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Create modules with assignments
        let module1 = Helper.createModule(course: course, name: "DS Module 1", published: false)
        let module1Assignment = Helper.createModuleAssignment(
            course: course,
            module: module1,
            title: "Assignment of DS Module 1",
            published: false
        )
        let module2 = Helper.createModule(course: course, name: "DS Module 2", published: false)
        let module2Assignment = Helper.createModuleAssignment(
            course: course,
            module: module2,
            title: "Assignment of DS Module 2",
            published: false
        )

        // MARK: Get the user logged in
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)

        // MARK: Navigate to Modules, check elements
        Helper.navigateToModules(course: course)
        let module1NameLabel = Helper.moduleLabel(moduleIndex: 0).waitUntil(.visible)
        let module1AssignmentItem = Helper.moduleItem(moduleIndex: 0, itemIndex: 0).waitUntil(.visible)
        let module2NameLabel = Helper.moduleLabel(moduleIndex: 1).waitUntil(.visible)
        let module2AssignmentItem = Helper.moduleItem(moduleIndex: 1, itemIndex: 0).waitUntil(.visible)
        let publishOptionsButton = Helper.publishOptionsButton.waitUntil(.visible)
        XCTAssertVisible(module1NameLabel)
        XCTAssertContains(module1NameLabel.label, module1.name)
        XCTAssertContains(module1NameLabel.label, "unpublished")
        XCTAssertVisible(module1AssignmentItem)
        XCTAssertContains(module1AssignmentItem.label, module1Assignment.title)
        XCTAssertContains(module1AssignmentItem.label, "unpublished")
        XCTAssertVisible(module2NameLabel)
        XCTAssertContains(module2NameLabel.label, module2.name)
        XCTAssertContains(module2NameLabel.label, "unpublished")
        XCTAssertVisible(module2AssignmentItem)
        XCTAssertContains(module2AssignmentItem.label, module2Assignment.title)
        XCTAssertContains(module2AssignmentItem.label, "unpublished")
        XCTAssertVisible(publishOptionsButton)

        // MARK: Open "Publish Options" menu, check elements
        publishOptionsButton.hit()
        let publishAllModulesAndItems = Helper.PublishOptions.publishAllModulesAndItems.waitUntil(.visible)
        let publishModulesOnly = Helper.PublishOptions.publishModulesOnly.waitUntil(.visible)
        let unpublishAllModulesAndItems = Helper.PublishOptions.unpublishAllModulesAndItems.waitUntil(.visible)
        XCTAssertVisible(publishAllModulesAndItems)
        XCTAssertVisible(publishModulesOnly)
        XCTAssertVisible(unpublishAllModulesAndItems)

        // MARK: Select "Publish All Modules And Items", handle alert, check progress screen
        publishAllModulesAndItems.hit()
        let cancelButton = Helper.PublishOptions.Alert.cancel.waitUntil(.visible)
        let publishButton = Helper.PublishOptions.Alert.publish.waitUntil(.visible)
        XCTAssertVisible(cancelButton)
        XCTAssertVisible(publishButton)

        publishButton.hit()
        let cancelPublishingButton = Helper.PublishOptions.Progress.cancelButton.waitUntil(.visible)
        XCTAssertVisible(cancelPublishingButton)

        let dismissButton = Helper.PublishOptions.Progress.dismissButton.waitUntil(.visible)
        let doneButton = Helper.PublishOptions.Progress.doneButton.waitUntil(.visible)
        let progressTitle = Helper.PublishOptions.Progress.progressTitle.waitUntil(.visible)
        let progressIndicator = Helper.PublishOptions.Progress.progressIndicator.waitUntil(.visible)
        XCTAssertVisible(dismissButton)
        XCTAssertVisible(doneButton)
        XCTAssertVisible(progressTitle)
        XCTAssertVisible(progressIndicator)
        XCTAssertEqual(progressIndicator.waitUntil(.value(expected: "100%")).stringValue, "100%")

        // MARK: Tap "Done" button, check result
        doneButton.hit()
        XCTAssertVisible(module1NameLabel.waitUntil(.visible))
        XCTAssertContains(module1NameLabel.label, module1.name)
        XCTAssertContains(module1NameLabel.waitUntil(.visible).label, "published")
        XCTAssertVisible(module1AssignmentItem.waitUntil(.visible))
        XCTAssertContains(module1AssignmentItem.label, module1Assignment.title)
        XCTAssertContains(module1AssignmentItem.label, "published")
        XCTAssertVisible(module2NameLabel.waitUntil(.visible))
        XCTAssertContains(module2NameLabel.label, module2.name)
        XCTAssertContains(module2NameLabel.label, "published")
        XCTAssertVisible(module2AssignmentItem.waitUntil(.visible))
        XCTAssertContains(module2AssignmentItem.label, module2Assignment.title)
        XCTAssertContains(module2AssignmentItem.label, "published")
        XCTAssertVisible(publishOptionsButton.waitUntil(.visible))
    }

    func testBulkPublishModulesOnly() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Create modules with assignments
        let module1 = Helper.createModule(course: course, name: "DS Module 1", published: false)
        let module1Assignment = Helper.createModuleAssignment(
            course: course,
            module: module1,
            title: "Assignment of DS Module 1",
            published: false
        )
        let module2 = Helper.createModule(course: course, name: "DS Module 2", published: false)
        let module2Assignment = Helper.createModuleAssignment(
            course: course,
            module: module2,
            title: "Assignment of DS Module 2",
            published: false
        )

        // MARK: Get the user logged in
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)

        // MARK: Navigate to Modules, check elements
        Helper.navigateToModules(course: course)
        let module1NameLabel = Helper.moduleLabel(moduleIndex: 0).waitUntil(.visible)
        let module1AssignmentItem = Helper.moduleItem(moduleIndex: 0, itemIndex: 0).waitUntil(.visible)
        let module2NameLabel = Helper.moduleLabel(moduleIndex: 1).waitUntil(.visible)
        let module2AssignmentItem = Helper.moduleItem(moduleIndex: 1, itemIndex: 0).waitUntil(.visible)
        let publishOptionsButton = Helper.publishOptionsButton.waitUntil(.visible)
        XCTAssertVisible(module1NameLabel)
        XCTAssertContains(module1NameLabel.label, module1.name)
        XCTAssertContains(module1NameLabel.label, "unpublished")
        XCTAssertVisible(module1AssignmentItem)
        XCTAssertContains(module1AssignmentItem.label, module1Assignment.title)
        XCTAssertContains(module1AssignmentItem.label, "unpublished")
        XCTAssertVisible(module2NameLabel)
        XCTAssertContains(module2NameLabel.label, module2.name)
        XCTAssertContains(module2NameLabel.label, "unpublished")
        XCTAssertVisible(module2AssignmentItem)
        XCTAssertContains(module2AssignmentItem.label, module2Assignment.title)
        XCTAssertContains(module2AssignmentItem.label, "unpublished")
        XCTAssertVisible(publishOptionsButton)

        // MARK: Open "Publish Options" menu, check elements
        publishOptionsButton.hit()
        let publishAllModulesAndItems = Helper.PublishOptions.publishAllModulesAndItems.waitUntil(.visible)
        let publishModulesOnly = Helper.PublishOptions.publishModulesOnly.waitUntil(.visible)
        let unpublishAllModulesAndItems = Helper.PublishOptions.unpublishAllModulesAndItems.waitUntil(.visible)
        XCTAssertVisible(publishAllModulesAndItems)
        XCTAssertVisible(publishModulesOnly)
        XCTAssertVisible(unpublishAllModulesAndItems)

        // MARK: Select "Publish Modules Only", handle alert, check progress screen
        publishModulesOnly.hit()
        let cancelButton = Helper.PublishOptions.Alert.cancel.waitUntil(.visible)
        let publishButton = Helper.PublishOptions.Alert.publish.waitUntil(.visible)
        XCTAssertVisible(cancelButton)
        XCTAssertVisible(publishButton)

        publishButton.hit()
        let dismissButton = Helper.PublishOptions.Progress.dismissButton.waitUntil(.visible)
        let doneButton = Helper.PublishOptions.Progress.doneButton.waitUntil(.visible)
        let progressTitle = Helper.PublishOptions.Progress.progressTitle.waitUntil(.visible)
        let progressIndicator = Helper.PublishOptions.Progress.progressIndicator.waitUntil(.visible)
        XCTAssertVisible(dismissButton)
        XCTAssertVisible(doneButton)
        XCTAssertVisible(progressTitle)
        XCTAssertVisible(progressIndicator)
        XCTAssertEqual(progressIndicator.waitUntil(.value(expected: "100%")).stringValue, "100%")

        // MARK: Tap "Done" button, check result
        doneButton.hit()
        XCTAssertVisible(module1NameLabel.waitUntil(.visible))
        XCTAssertContains(module1NameLabel.label, module1.name)
        XCTAssertContains(module1NameLabel.waitUntil(.visible).label, "published")
        XCTAssertVisible(module1AssignmentItem.waitUntil(.visible))
        XCTAssertContains(module1AssignmentItem.label, module1Assignment.title)
        XCTAssertContains(module1AssignmentItem.label, "unpublished")
        XCTAssertVisible(module2NameLabel.waitUntil(.visible))
        XCTAssertContains(module2NameLabel.label, module2.name)
        XCTAssertContains(module2NameLabel.label, "published")
        XCTAssertVisible(module2AssignmentItem.waitUntil(.visible))
        XCTAssertContains(module2AssignmentItem.label, module2Assignment.title)
        XCTAssertContains(module2AssignmentItem.label, "unpublished")
        XCTAssertVisible(publishOptionsButton.waitUntil(.visible))
    }

    func testBulkUnpublishAllModulesAndItems() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Create modules with assignments
        let module1 = Helper.createModule(course: course, name: "DS Module 1", published: true)
        let module1Assignment = Helper.createModuleAssignment(
            course: course,
            module: module1,
            title: "Assignment of DS Module 1",
            published: true
        )
        let module2 = Helper.createModule(course: course, name: "DS Module 2", published: true)
        let module2Assignment = Helper.createModuleAssignment(
            course: course,
            module: module2,
            title: "Assignment of DS Module 2",
            published: true
        )

        // MARK: Get the user logged in
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)

        // MARK: Navigate to Modules, check elements
        Helper.navigateToModules(course: course)
        let module1NameLabel = Helper.moduleLabel(moduleIndex: 0).waitUntil(.visible)
        let module1AssignmentItem = Helper.moduleItem(moduleIndex: 0, itemIndex: 0).waitUntil(.visible)
        let module2NameLabel = Helper.moduleLabel(moduleIndex: 1).waitUntil(.visible)
        let module2AssignmentItem = Helper.moduleItem(moduleIndex: 1, itemIndex: 0).waitUntil(.visible)
        let publishOptionsButton = Helper.publishOptionsButton.waitUntil(.visible)
        XCTAssertVisible(module1NameLabel)
        XCTAssertContains(module1NameLabel.label, module1.name)
        XCTAssertContains(module1NameLabel.label, "published")
        XCTAssertVisible(module1AssignmentItem)
        XCTAssertContains(module1AssignmentItem.label, module1Assignment.title)
        XCTAssertContains(module1AssignmentItem.label, "published")
        XCTAssertVisible(module2NameLabel)
        XCTAssertContains(module2NameLabel.label, module2.name)
        XCTAssertContains(module2NameLabel.label, "published")
        XCTAssertVisible(module2AssignmentItem)
        XCTAssertContains(module2AssignmentItem.label, module2Assignment.title)
        XCTAssertContains(module2AssignmentItem.label, "published")
        XCTAssertVisible(publishOptionsButton)

        // MARK: Open "Publish Options" menu, check elements
        publishOptionsButton.hit()
        let publishAllModulesAndItems = Helper.PublishOptions.publishAllModulesAndItems.waitUntil(.visible)
        let publishModulesOnly = Helper.PublishOptions.publishModulesOnly.waitUntil(.visible)
        let unpublishAllModulesAndItems = Helper.PublishOptions.unpublishAllModulesAndItems.waitUntil(.visible)
        XCTAssertVisible(publishAllModulesAndItems)
        XCTAssertVisible(publishModulesOnly)
        XCTAssertVisible(unpublishAllModulesAndItems)

        // MARK: Select "Unpublish All Modules And Items", handle alert, check progress screen
        unpublishAllModulesAndItems.hit()
        let cancelButton = Helper.PublishOptions.Alert.cancel.waitUntil(.visible)
        let unpublishButton = Helper.PublishOptions.Alert.unpublish.waitUntil(.visible)
        XCTAssertVisible(cancelButton)
        XCTAssertVisible(unpublishButton)

        unpublishButton.hit()
        let cancelPublishingButton = Helper.PublishOptions.Progress.cancelButton.waitUntil(.visible)
        XCTAssertVisible(cancelPublishingButton)

        let dismissButton = Helper.PublishOptions.Progress.dismissButton.waitUntil(.visible)
        let doneButton = Helper.PublishOptions.Progress.doneButton.waitUntil(.visible)
        let progressTitle = Helper.PublishOptions.Progress.progressTitle.waitUntil(.visible)
        let progressIndicator = Helper.PublishOptions.Progress.progressIndicator.waitUntil(.visible)
        XCTAssertVisible(dismissButton)
        XCTAssertVisible(doneButton)
        XCTAssertVisible(progressTitle)
        XCTAssertVisible(progressIndicator)
        XCTAssertEqual(progressIndicator.waitUntil(.value(expected: "100%")).stringValue, "100%")

        // MARK: Tap "Done" button, check result
        doneButton.hit()
        XCTAssertVisible(module1NameLabel.waitUntil(.visible))
        XCTAssertContains(module1NameLabel.label, module1.name)
        XCTAssertContains(module1NameLabel.waitUntil(.visible).label, "unpublished")
        XCTAssertVisible(module1AssignmentItem.waitUntil(.visible))
        XCTAssertContains(module1AssignmentItem.label, module1Assignment.title)
        XCTAssertContains(module1AssignmentItem.label, "unpublished")
        XCTAssertVisible(module2NameLabel.waitUntil(.visible))
        XCTAssertContains(module2NameLabel.label, module2.name)
        XCTAssertContains(module2NameLabel.label, "unpublished")
        XCTAssertVisible(module2AssignmentItem.waitUntil(.visible))
        XCTAssertContains(module2AssignmentItem.label, module2Assignment.title)
        XCTAssertContains(module2AssignmentItem.label, "unpublished")
        XCTAssertVisible(publishOptionsButton.waitUntil(.visible))
    }
}
