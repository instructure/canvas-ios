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

class ToDoTests: E2ETestCase {
    func testToDo() {
        // MARK: Seed the usual stuff with 3 contents (discussion, assignment, quiz)
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let assignment = AssignmentsHelper.createAssignment(course: course, dueDate: Date.now.addMinutes(30))
        let quiz = QuizzesHelper.createTestQuizWith2Questions(course: course, due_at: Date.now.addMinutes(30))

        // MARK: Get the user logged in and check ToDo tab bar
        logInDSUser(student)
        let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
        XCTAssertTrue(profileButton.isVisible)

        let toDoTab = ToDoHelper.TabBar.todoTab.waitUntil(.visible)
        XCTAssertTrue(toDoTab.isVisible)
        XCTAssertTrue(toDoTab.hasValue(value: "2 items"))

        // MARK: Tap ToDo button and check the 3 items
        toDoTab.hit()
        let assignmentItem = ToDoHelper.cell(id: assignment.id).waitUntil(.visible)
        let quizItem = ToDoHelper.cell(id: quiz.assignment_id!).waitUntil(.visible)
        XCTAssertTrue(assignmentItem.isVisible)
        XCTAssertTrue(quizItem.isVisible)

        let assignmentItemTitle = ToDoHelper.cellItemTitle(cell: assignmentItem).waitUntil(.visible)
        let quizItemTitle = ToDoHelper.cellItemTitle(cell: quizItem).waitUntil(.visible)
        XCTAssertTrue(assignmentItemTitle.isVisible)
        XCTAssertTrue(quizItemTitle.isVisible)
        XCTAssertTrue(assignmentItemTitle.hasLabel(label: assignment.name))
        XCTAssertTrue(quizItemTitle.hasLabel(label: quiz.title))

        // MARK: Tap on each item
        assignmentItem.hit()
        let backButton = ToDoHelper.toDoBackButton.waitUntil(.visible, timeout: 5)
        let assignmentDescription = app.find(label: assignment.description!).waitUntil(.visible)
        XCTAssertTrue(assignmentDescription.isVisible)

        if backButton.isVisible { backButton.hit() }
        backButton.waitUntil(.vanish)
        quizItem.hit()
        let quizDescription = app.find(label: quiz.description).waitUntil(.visible)
        XCTAssertTrue(quizDescription.isVisible)
    }
}
