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
    func testModuleItems() {
        // MARK: Seed the usual stuff
        let users = seeder.createUsers(1)
        let course = seeder.createCourse()
        let student = users[0]
        seeder.enrollStudent(student, in: course)

        // MARK: Create module with assignment, discussion, page, quiz items
        let module = ModulesHelper.createModule(course: course, name: "Test Module")
        let moduleAssignment = ModulesHelper.createModuleAssignment(course: course, module: module, title: "Test Module Assignment")
        let moduleDiscussion = ModulesHelper.createModuleDiscussion(course: course, module: module, title: "Test Module Discussion")
        let modulePage = ModulesHelper.createModulePage(course: course, module: module, title: "Test Module Page")
        let moduleQuiz = ModulesHelper.createModuleQuiz(course: course, module: module, title: "Test Module Quiz")

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Navigate to Modules
        ModulesHelper.navigateToModules(course: course)
        let moduleNameLabel = ModulesHelper.moduleLabel(moduleIndex: 0).waitUntil(.visible)
        XCTAssertTrue(moduleNameLabel.isVisible)
        XCTAssertTrue(moduleNameLabel.hasLabel(label: module.name, strict: false))

        // MARK: Check assignment module item
        let assignmentItem = ModulesHelper.moduleItem(moduleIndex: 0, itemIndex: 0).waitUntil(.visible)
        let assignmentTitle = ModulesHelper.moduleItemNameLabel(moduleIndex: 0, itemIndex: 0).waitUntil(.visible)
        let assignmentPoints = ModulesHelper.moduleItemDueLabel(moduleIndex: 0, itemIndex: 0).waitUntil(.visible)
        XCTAssertTrue(assignmentItem.isVisible)
        XCTAssertTrue(assignmentTitle.isVisible)
        XCTAssertTrue(assignmentTitle.hasLabel(label: moduleAssignment.title))
        XCTAssertTrue(assignmentPoints.isVisible)

        // TODO: Update the below line once the points label bug is fixed
        let pointsString = moduleAssignment.points_possible! == 1 ? "pts" : "pts"

        XCTAssertTrue(assignmentPoints.hasLabel(label: "\(moduleAssignment.points_possible!) \(pointsString)"))

        // MARK: Check discussion module item
        let discussionItem = ModulesHelper.moduleItem(moduleIndex: 0, itemIndex: 1).waitUntil(.visible)
        let discussionTitle = ModulesHelper.moduleItemNameLabel(moduleIndex: 0, itemIndex: 1).waitUntil(.visible)
        XCTAssertTrue(discussionItem.isVisible)
        XCTAssertTrue(discussionTitle.isVisible)
        XCTAssertTrue(discussionTitle.hasLabel(label: moduleDiscussion.title))

        // MARK: Check page module item
        let pageItem = ModulesHelper.moduleItem(moduleIndex: 0, itemIndex: 2).waitUntil(.visible)
        let pageTitle = ModulesHelper.moduleItemNameLabel(moduleIndex: 0, itemIndex: 2).waitUntil(.visible)
        XCTAssertTrue(pageItem.isVisible)
        XCTAssertTrue(pageTitle.isVisible)
        XCTAssertTrue(pageTitle.hasLabel(label: modulePage.title))

        // MARK: Check quiz module item
        let quizItem = ModulesHelper.moduleItem(moduleIndex: 0, itemIndex: 3).waitUntil(.visible)
        let quizTitle = ModulesHelper.moduleItemNameLabel(moduleIndex: 0, itemIndex: 3).waitUntil(.visible)
        XCTAssertTrue(quizItem.isVisible)
        XCTAssertTrue(quizTitle.isVisible)
        XCTAssertTrue(quizTitle.hasLabel(label: moduleQuiz.title))
    }
}
