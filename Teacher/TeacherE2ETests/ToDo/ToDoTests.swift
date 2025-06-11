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
import XCTest

class ToDoTests: E2ETestCase {
    func testToDo() {
        // MARK: Seed the usual stuff with a submitted assignment
        let student = seeder.createUser()
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        seeder.enrollTeacher(teacher, in: course)
        let assignment = AssignmentsHelper.createAssignment(course: course, dueDate: Date.now.addMinutes(30))
        let submission = GradesHelper.submitAssignment(course: course, student: student, assignment: assignment)

        // MARK: Get the user logged in and check ToDo tab bar
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        let toDoTab = ToDoHelper.TabBar.todoTab.waitUntil(.visible)
        XCTAssertTrue(toDoTab.isVisible)
        XCTAssertEqual(toDoTab.stringValue, "1 item")

        // MARK: Tap ToDo button and check the 3 items
        toDoTab.hit()
        let assignmentItem = ToDoHelper.cell(id: assignment.id).waitUntil(.visible)
        let assignmentItemTitle = ToDoHelper.cellItemTitle(cell: assignmentItem).waitUntil(.visible)
        XCTAssertTrue(assignmentItem.isVisible)
        XCTAssertTrue(assignmentItemTitle.isVisible)
        XCTAssertEqual(assignmentItemTitle.label, assignment.name)

        // MARK: Check submission
        assignmentItem.hit()
        let userLabel = AssignmentsHelper.SpeedGrader.userButton.waitUntil(.visible)
        let submissionBody = app.find(label: submission.body).waitUntil(.visible)
        XCTAssertContains(userLabel.label, "\(student.name), Submitted")
        XCTAssertTrue(submissionBody.isVisible)
    }
}
