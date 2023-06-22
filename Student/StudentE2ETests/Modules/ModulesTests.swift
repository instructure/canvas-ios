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
        let moduleNameLabel = ModulesHelper.moduleLabel(moduleIndex: 0).waitToExist()
        XCTAssertTrue(moduleNameLabel.isVisible)
        XCTAssertTrue(moduleNameLabel.label().contains(module.name))

        // MARK: Check assignment module item
        let assignmentItem = ModulesHelper.moduleItem(moduleIndex: 0, itemIndex: 0).waitToExist()
        let assignmentTitle = ModulesHelper.moduleItemNameLabel(moduleIndex: 0, itemIndex: 0).waitToExist()
        let assignmentPoints = ModulesHelper.moduleItemDueLabel(moduleIndex: 0, itemIndex: 0).waitToExist()
        XCTAssertTrue(assignmentItem.isVisible)
        XCTAssertTrue(assignmentTitle.isVisible)
        XCTAssertEqual(assignmentTitle.label(), moduleAssignment.title)
        XCTAssertTrue(assignmentPoints.isVisible)
        XCTAssertEqual(assignmentPoints.label(), "0 pts")

        // MARK: Check discussion module item
        let discussionItem = ModulesHelper.moduleItem(moduleIndex: 0, itemIndex: 1).waitToExist()
        let discussionTitle = ModulesHelper.moduleItemNameLabel(moduleIndex: 0, itemIndex: 1).waitToExist()
        XCTAssertTrue(discussionItem.isVisible)
        XCTAssertTrue(discussionTitle.isVisible)
        XCTAssertEqual(discussionTitle.label(), moduleDiscussion.title)

        // MARK: Check page module item
        let pageItem = ModulesHelper.moduleItem(moduleIndex: 0, itemIndex: 2).waitToExist()
        let pageTitle = ModulesHelper.moduleItemNameLabel(moduleIndex: 0, itemIndex: 2).waitToExist()
        XCTAssertTrue(pageItem.isVisible)
        XCTAssertTrue(pageTitle.isVisible)
        XCTAssertEqual(pageTitle.label(), modulePage.title)

        // MARK: Check quiz module item
        let quizItem = ModulesHelper.moduleItem(moduleIndex: 0, itemIndex: 3).waitToExist()
        let quizTitle = ModulesHelper.moduleItemNameLabel(moduleIndex: 0, itemIndex: 3).waitToExist()
        XCTAssertTrue(quizItem.isVisible)
        XCTAssertTrue(quizTitle.isVisible)
        XCTAssertEqual(quizTitle.label(), moduleQuiz.title)
    }
}
