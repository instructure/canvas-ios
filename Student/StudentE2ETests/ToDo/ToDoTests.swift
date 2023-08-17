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

class ToDoTests: E2ETestCase {
    func testToDo() {
        // MARK: Seed the usual stuff with 3 contents (discussion, assignment, quiz)
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let discussion = DiscussionsHelper.createDiscussion(course: course, isAssignment: true, dueDate: Date.now.addMinutes(30))
        let assignment = AssignmentsHelper.createAssignment(course: course, dueDate: Date.now.addMinutes(30))
        let quiz = QuizzesHelper.createTestQuizWith2Questions(course: course, due_at: Date.now.addMinutes(30))

        // MARK: Get the user logged in and check ToDo tab bar
        logInDSUser(student)

        let toDoTab = ToDoHelper.TabBar.todoTab.waitUntil(.visible)
        XCTAssertTrue(toDoTab.isVisible)
        XCTAssertTrue(toDoTab.waitUntil(.value(expected: "3 items")).hasValue(value: "3 items"))

        // MARK: Tap ToDo button and check the 3 items
        toDoTab.hit()
        let discussionItem = ToDoHelper.cell(id: discussion.assignment!.id).waitUntil(.visible)
        let assignmentItem = ToDoHelper.cell(id: assignment.id).waitUntil(.visible)
        let quizItem = ToDoHelper.cell(id: quiz.assignment_id!).waitUntil(.visible)
        XCTAssertTrue(discussionItem.isVisible)
        XCTAssertTrue(assignmentItem.isVisible)
        XCTAssertTrue(quizItem.isVisible)

        let discussionItemTitle = ToDoHelper.cellItemTitle(cell: discussionItem).waitUntil(.visible)
        let assignmentItemTitle = ToDoHelper.cellItemTitle(cell: assignmentItem).waitUntil(.visible)
        let quizItemTitle = ToDoHelper.cellItemTitle(cell: quizItem).waitUntil(.visible)
        XCTAssertTrue(discussionItemTitle.isVisible)
        XCTAssertTrue(assignmentItemTitle.isVisible)
        XCTAssertTrue(quizItemTitle.isVisible)
        XCTAssertTrue(discussionItemTitle.hasLabel(label: discussion.title))
        XCTAssertTrue(assignmentItemTitle.hasLabel(label: assignment.name))
        XCTAssertTrue(quizItemTitle.hasLabel(label: quiz.title))

        // MARK: Tap on each item
        discussionItem.hit()
        let backButton = ToDoHelper.toDoBackButton.waitUntil(.visible)
        let discussionMessage = app.find(label: discussion.message).waitUntil(.visible)
        XCTAssertTrue(backButton.isVisible)
        XCTAssertTrue(discussionMessage.isVisible)

        backButton.hit()
        backButton.waitUntil(.vanish)
        assignmentItem.hit()
        backButton.waitUntil(.visible)
        let assignmentDescription = app.find(label: assignment.description!).waitUntil(.visible)
        XCTAssertTrue(backButton.isVisible)
        XCTAssertTrue(assignmentDescription.isVisible)

        backButton.hit()
        backButton.waitUntil(.vanish)
        quizItem.hit()
        backButton.waitUntil(.visible)
        let quizDescription = app.find(label: quiz.description).waitUntil(.visible)
        XCTAssertTrue(backButton.isVisible)
        XCTAssertTrue(quizDescription.isVisible)
    }
}
