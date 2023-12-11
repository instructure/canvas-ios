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
        let module = Helper.createModule(course: course, name: "Test Module")
        let moduleAssignment = Helper.createModuleAssignment(course: course, module: module, title: "Test Module Assignment")
        let moduleDiscussion = Helper.createModuleDiscussion(course: course, module: module, title: "Test Module Discussion")
        let modulePage = Helper.createModulePage(course: course, module: module, title: "Test Module Page")
        let moduleQuiz = Helper.createModuleQuiz(course: course, module: module, title: "Test Module Quiz")

        // MARK: Get the user logged in
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Modules
        Helper.navigateToModules(course: course)
        let moduleNameLabel = Helper.moduleLabel(moduleIndex: 0).waitUntil(.visible)
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
}
