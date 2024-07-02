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
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Modules
        Helper.navigateToModules(course: course)
        let publishOptionsButton = Helper.publishOptionsButton.waitUntil(.visible)
        let moduleNameLabel = Helper.moduleLabel(moduleIndex: 0).waitUntil(.visible)
        XCTAssertTrue(publishOptionsButton.isVisible)
        XCTAssertTrue(moduleNameLabel.isVisible)
        XCTAssertTrue(moduleNameLabel.hasLabel(label: module.name, strict: false))

        // MARK: Check assignment module item
        let assignmentItem = Helper.moduleItem(moduleIndex: 0, itemIndex: 0).waitUntil(.visible)
        let assignmentTitle = Helper.moduleItemNameLabel(moduleIndex: 0, itemIndex: 0).waitUntil(.visible)
        let assignmentPoints = Helper.moduleItemDueLabel(moduleIndex: 0, itemIndex: 0).waitUntil(.visible)
        XCTAssertTrue(assignmentItem.isVisible)
        XCTAssertTrue(assignmentTitle.isVisible)
        XCTAssertTrue(assignmentTitle.hasLabel(label: moduleAssignment.title))
        XCTAssertTrue(assignmentPoints.isVisible)

        // TODO: Update the below line once the points label bug is fixed
        let pointsString = moduleAssignment.points_possible! == 1 ? "pts" : "pts"
        XCTAssertTrue(assignmentPoints.hasLabel(label: "\(moduleAssignment.points_possible!) \(pointsString)"))

        // MARK: Check discussion module item
        let discussionItem = Helper.moduleItem(moduleIndex: 0, itemIndex: 1).waitUntil(.visible)
        let discussionTitle = Helper.moduleItemNameLabel(moduleIndex: 0, itemIndex: 1).waitUntil(.visible)
        XCTAssertTrue(discussionItem.isVisible)
        XCTAssertTrue(discussionTitle.isVisible)
        XCTAssertTrue(discussionTitle.hasLabel(label: moduleDiscussion.title))

        // MARK: Check page module item
        let pageItem = Helper.moduleItem(moduleIndex: 0, itemIndex: 2).waitUntil(.visible)
        let pageTitle = Helper.moduleItemNameLabel(moduleIndex: 0, itemIndex: 2).waitUntil(.visible)
        XCTAssertTrue(pageItem.isVisible)
        XCTAssertTrue(pageTitle.isVisible)
        XCTAssertTrue(pageTitle.hasLabel(label: modulePage.title))

        // MARK: Check quiz module item
        let quizItem = Helper.moduleItem(moduleIndex: 0, itemIndex: 3).waitUntil(.visible)
        let quizTitle = Helper.moduleItemNameLabel(moduleIndex: 0, itemIndex: 3).waitUntil(.visible)
        XCTAssertTrue(quizItem.isVisible)
        XCTAssertTrue(quizTitle.isVisible)
        XCTAssertTrue(quizTitle.hasLabel(label: moduleQuiz.title))
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
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Modules, check elements
        Helper.navigateToModules(course: course)
        let module1NameLabel = Helper.moduleLabel(moduleIndex: 0).waitUntil(.visible)
        let module1AssignmentItem = Helper.moduleItem(moduleIndex: 0, itemIndex: 0).waitUntil(.visible)
        let module2NameLabel = Helper.moduleLabel(moduleIndex: 1).waitUntil(.visible)
        let module2AssignmentItem = Helper.moduleItem(moduleIndex: 1, itemIndex: 0).waitUntil(.visible)
        let publishOptionsButton = Helper.publishOptionsButton.waitUntil(.visible)
        XCTAssertTrue(module1NameLabel.isVisible)
        XCTAssertTrue(module1NameLabel.hasLabel(label: module1.name, strict: false))
        XCTAssertTrue(module1NameLabel.hasLabel(label: "unpublished", strict: false))
        XCTAssertTrue(module1AssignmentItem.isVisible)
        XCTAssertTrue(module1AssignmentItem.hasLabel(label: module1Assignment.title, strict: false))
        XCTAssertTrue(module1AssignmentItem.hasLabel(label: "unpublished", strict: false))
        XCTAssertTrue(module2NameLabel.isVisible)
        XCTAssertTrue(module2NameLabel.hasLabel(label: module2.name, strict: false))
        XCTAssertTrue(module2NameLabel.hasLabel(label: "unpublished", strict: false))
        XCTAssertTrue(module2AssignmentItem.isVisible)
        XCTAssertTrue(module2AssignmentItem.hasLabel(label: module2Assignment.title, strict: false))
        XCTAssertTrue(module2AssignmentItem.hasLabel(label: "unpublished", strict: false))
        XCTAssertTrue(publishOptionsButton.isVisible)

        // MARK: Open "Publish Options" menu, check elements
        publishOptionsButton.hit()
        let publishAllModulesAndItems = Helper.PublishOptions.publishAllModulesAndItems.waitUntil(.visible)
        let publishModulesOnly = Helper.PublishOptions.publishModulesOnly.waitUntil(.visible)
        let unpublishAllModulesAndItems = Helper.PublishOptions.unpublishAllModulesAndItems.waitUntil(.visible)
        XCTAssertTrue(publishAllModulesAndItems.isVisible)
        XCTAssertTrue(publishModulesOnly.isVisible)
        XCTAssertTrue(unpublishAllModulesAndItems.isVisible)

        // MARK: Select "Publish All Modules And Items", handle alert, check progress screen
        publishAllModulesAndItems.hit()
        let cancelButton = Helper.PublishOptions.Alert.cancel.waitUntil(.visible)
        let publishButton = Helper.PublishOptions.Alert.publish.waitUntil(.visible)
        XCTAssertTrue(cancelButton.isVisible)
        XCTAssertTrue(publishButton.isVisible)

        publishButton.hit()
        let cancelPublishingButton = Helper.PublishOptions.Progress.cancelButton.waitUntil(.visible)
        XCTAssertTrue(cancelPublishingButton.isVisible)

        let dismissButton = Helper.PublishOptions.Progress.dismissButton.waitUntil(.visible)
        let doneButton = Helper.PublishOptions.Progress.doneButton.waitUntil(.visible)
        let progressTitle = Helper.PublishOptions.Progress.progressTitle.waitUntil(.visible)
        let progressIndicator = Helper.PublishOptions.Progress.progressIndicator.waitUntil(.visible)
        XCTAssertTrue(dismissButton.isVisible)
        XCTAssertTrue(doneButton.isVisible)
        XCTAssertTrue(progressTitle.isVisible)
        XCTAssertTrue(progressIndicator.isVisible)
        XCTAssertTrue(progressIndicator.waitUntil(.value(expected: "100%")).hasValue(value: "100%"))

        // MARK: Tap "Done" button, check result
        doneButton.hit()
        XCTAssertTrue(module1NameLabel.waitUntil(.visible).isVisible)
        XCTAssertTrue(module1NameLabel.hasLabel(label: module1.name, strict: false))
        XCTAssertTrue(module1NameLabel.waitUntil(.visible).hasLabel(label: "published", strict: false))
        XCTAssertTrue(module1AssignmentItem.waitUntil(.visible).isVisible)
        XCTAssertTrue(module1AssignmentItem.hasLabel(label: module1Assignment.title, strict: false))
        XCTAssertTrue(module1AssignmentItem.hasLabel(label: "published", strict: false))
        XCTAssertTrue(module2NameLabel.waitUntil(.visible).isVisible)
        XCTAssertTrue(module2NameLabel.hasLabel(label: module2.name, strict: false))
        XCTAssertTrue(module2NameLabel.hasLabel(label: "published", strict: false))
        XCTAssertTrue(module2AssignmentItem.waitUntil(.visible).isVisible)
        XCTAssertTrue(module2AssignmentItem.hasLabel(label: module2Assignment.title, strict: false))
        XCTAssertTrue(module2AssignmentItem.hasLabel(label: "published", strict: false))
        XCTAssertTrue(publishOptionsButton.waitUntil(.visible).isVisible)
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
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Modules, check elements
        Helper.navigateToModules(course: course)
        let module1NameLabel = Helper.moduleLabel(moduleIndex: 0).waitUntil(.visible)
        let module1AssignmentItem = Helper.moduleItem(moduleIndex: 0, itemIndex: 0).waitUntil(.visible)
        let module2NameLabel = Helper.moduleLabel(moduleIndex: 1).waitUntil(.visible)
        let module2AssignmentItem = Helper.moduleItem(moduleIndex: 1, itemIndex: 0).waitUntil(.visible)
        let publishOptionsButton = Helper.publishOptionsButton.waitUntil(.visible)
        XCTAssertTrue(module1NameLabel.isVisible)
        XCTAssertTrue(module1NameLabel.hasLabel(label: module1.name, strict: false))
        XCTAssertTrue(module1NameLabel.hasLabel(label: "unpublished", strict: false))
        XCTAssertTrue(module1AssignmentItem.isVisible)
        XCTAssertTrue(module1AssignmentItem.hasLabel(label: module1Assignment.title, strict: false))
        XCTAssertTrue(module1AssignmentItem.hasLabel(label: "unpublished", strict: false))
        XCTAssertTrue(module2NameLabel.isVisible)
        XCTAssertTrue(module2NameLabel.hasLabel(label: module2.name, strict: false))
        XCTAssertTrue(module2NameLabel.hasLabel(label: "unpublished", strict: false))
        XCTAssertTrue(module2AssignmentItem.isVisible)
        XCTAssertTrue(module2AssignmentItem.hasLabel(label: module2Assignment.title, strict: false))
        XCTAssertTrue(module2AssignmentItem.hasLabel(label: "unpublished", strict: false))
        XCTAssertTrue(publishOptionsButton.isVisible)

        // MARK: Open "Publish Options" menu, check elements
        publishOptionsButton.hit()
        let publishAllModulesAndItems = Helper.PublishOptions.publishAllModulesAndItems.waitUntil(.visible)
        let publishModulesOnly = Helper.PublishOptions.publishModulesOnly.waitUntil(.visible)
        let unpublishAllModulesAndItems = Helper.PublishOptions.unpublishAllModulesAndItems.waitUntil(.visible)
        XCTAssertTrue(publishAllModulesAndItems.isVisible)
        XCTAssertTrue(publishModulesOnly.isVisible)
        XCTAssertTrue(unpublishAllModulesAndItems.isVisible)

        // MARK: Select "Publish Modules Only", handle alert, check progress screen
        publishModulesOnly.hit()
        let cancelButton = Helper.PublishOptions.Alert.cancel.waitUntil(.visible)
        let publishButton = Helper.PublishOptions.Alert.publish.waitUntil(.visible)
        XCTAssertTrue(cancelButton.isVisible)
        XCTAssertTrue(publishButton.isVisible)

        publishButton.hit()
        let dismissButton = Helper.PublishOptions.Progress.dismissButton.waitUntil(.visible)
        let doneButton = Helper.PublishOptions.Progress.doneButton.waitUntil(.visible)
        let progressTitle = Helper.PublishOptions.Progress.progressTitle.waitUntil(.visible)
        let progressIndicator = Helper.PublishOptions.Progress.progressIndicator.waitUntil(.visible)
        XCTAssertTrue(dismissButton.isVisible)
        XCTAssertTrue(doneButton.isVisible)
        XCTAssertTrue(progressTitle.isVisible)
        XCTAssertTrue(progressIndicator.isVisible)
        XCTAssertTrue(progressIndicator.waitUntil(.value(expected: "100%")).hasValue(value: "100%"))

        // MARK: Tap "Done" button, check result
        doneButton.hit()
        XCTAssertTrue(module1NameLabel.waitUntil(.visible).isVisible)
        XCTAssertTrue(module1NameLabel.hasLabel(label: module1.name, strict: false))
        XCTAssertTrue(module1NameLabel.waitUntil(.visible).hasLabel(label: "published", strict: false))
        XCTAssertTrue(module1AssignmentItem.waitUntil(.visible).isVisible)
        XCTAssertTrue(module1AssignmentItem.hasLabel(label: module1Assignment.title, strict: false))
        XCTAssertTrue(module1AssignmentItem.hasLabel(label: "unpublished", strict: false))
        XCTAssertTrue(module2NameLabel.waitUntil(.visible).isVisible)
        XCTAssertTrue(module2NameLabel.hasLabel(label: module2.name, strict: false))
        XCTAssertTrue(module2NameLabel.hasLabel(label: "published", strict: false))
        XCTAssertTrue(module2AssignmentItem.waitUntil(.visible).isVisible)
        XCTAssertTrue(module2AssignmentItem.hasLabel(label: module2Assignment.title, strict: false))
        XCTAssertTrue(module2AssignmentItem.hasLabel(label: "unpublished", strict: false))
        XCTAssertTrue(publishOptionsButton.waitUntil(.visible).isVisible)
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
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Modules, check elements
        Helper.navigateToModules(course: course)
        let module1NameLabel = Helper.moduleLabel(moduleIndex: 0).waitUntil(.visible)
        let module1AssignmentItem = Helper.moduleItem(moduleIndex: 0, itemIndex: 0).waitUntil(.visible)
        let module2NameLabel = Helper.moduleLabel(moduleIndex: 1).waitUntil(.visible)
        let module2AssignmentItem = Helper.moduleItem(moduleIndex: 1, itemIndex: 0).waitUntil(.visible)
        let publishOptionsButton = Helper.publishOptionsButton.waitUntil(.visible)
        XCTAssertTrue(module1NameLabel.isVisible)
        XCTAssertTrue(module1NameLabel.hasLabel(label: module1.name, strict: false))
        XCTAssertTrue(module1NameLabel.hasLabel(label: "published", strict: false))
        XCTAssertTrue(module1AssignmentItem.isVisible)
        XCTAssertTrue(module1AssignmentItem.hasLabel(label: module1Assignment.title, strict: false))
        XCTAssertTrue(module1AssignmentItem.hasLabel(label: "published", strict: false))
        XCTAssertTrue(module2NameLabel.isVisible)
        XCTAssertTrue(module2NameLabel.hasLabel(label: module2.name, strict: false))
        XCTAssertTrue(module2NameLabel.hasLabel(label: "published", strict: false))
        XCTAssertTrue(module2AssignmentItem.isVisible)
        XCTAssertTrue(module2AssignmentItem.hasLabel(label: module2Assignment.title, strict: false))
        XCTAssertTrue(module2AssignmentItem.hasLabel(label: "published", strict: false))
        XCTAssertTrue(publishOptionsButton.isVisible)

        // MARK: Open "Publish Options" menu, check elements
        publishOptionsButton.hit()
        let publishAllModulesAndItems = Helper.PublishOptions.publishAllModulesAndItems.waitUntil(.visible)
        let publishModulesOnly = Helper.PublishOptions.publishModulesOnly.waitUntil(.visible)
        let unpublishAllModulesAndItems = Helper.PublishOptions.unpublishAllModulesAndItems.waitUntil(.visible)
        XCTAssertTrue(publishAllModulesAndItems.isVisible)
        XCTAssertTrue(publishModulesOnly.isVisible)
        XCTAssertTrue(unpublishAllModulesAndItems.isVisible)

        // MARK: Select "Unpublish All Modules And Items", handle alert, check progress screen
        unpublishAllModulesAndItems.hit()
        let cancelButton = Helper.PublishOptions.Alert.cancel.waitUntil(.visible)
        let unpublishButton = Helper.PublishOptions.Alert.unpublish.waitUntil(.visible)
        XCTAssertTrue(cancelButton.isVisible)
        XCTAssertTrue(unpublishButton.isVisible)

        unpublishButton.hit()
        let cancelPublishingButton = Helper.PublishOptions.Progress.cancelButton.waitUntil(.visible)
        XCTAssertTrue(cancelPublishingButton.isVisible)

        let dismissButton = Helper.PublishOptions.Progress.dismissButton.waitUntil(.visible)
        let doneButton = Helper.PublishOptions.Progress.doneButton.waitUntil(.visible)
        let progressTitle = Helper.PublishOptions.Progress.progressTitle.waitUntil(.visible)
        let progressIndicator = Helper.PublishOptions.Progress.progressIndicator.waitUntil(.visible)
        XCTAssertTrue(dismissButton.isVisible)
        XCTAssertTrue(doneButton.isVisible)
        XCTAssertTrue(progressTitle.isVisible)
        XCTAssertTrue(progressIndicator.isVisible)
        XCTAssertTrue(progressIndicator.waitUntil(.value(expected: "100%")).hasValue(value: "100%"))

        // MARK: Tap "Done" button, check result
        doneButton.hit()
        XCTAssertTrue(module1NameLabel.waitUntil(.visible).isVisible)
        XCTAssertTrue(module1NameLabel.hasLabel(label: module1.name, strict: false))
        XCTAssertTrue(module1NameLabel.waitUntil(.visible).hasLabel(label: "unpublished", strict: false))
        XCTAssertTrue(module1AssignmentItem.waitUntil(.visible).isVisible)
        XCTAssertTrue(module1AssignmentItem.hasLabel(label: module1Assignment.title, strict: false))
        XCTAssertTrue(module1AssignmentItem.hasLabel(label: "unpublished", strict: false))
        XCTAssertTrue(module2NameLabel.waitUntil(.visible).isVisible)
        XCTAssertTrue(module2NameLabel.hasLabel(label: module2.name, strict: false))
        XCTAssertTrue(module2NameLabel.hasLabel(label: "unpublished", strict: false))
        XCTAssertTrue(module2AssignmentItem.waitUntil(.visible).isVisible)
        XCTAssertTrue(module2AssignmentItem.hasLabel(label: module2Assignment.title, strict: false))
        XCTAssertTrue(module2AssignmentItem.hasLabel(label: "unpublished", strict: false))
        XCTAssertTrue(publishOptionsButton.waitUntil(.visible).isVisible)
    }
}
