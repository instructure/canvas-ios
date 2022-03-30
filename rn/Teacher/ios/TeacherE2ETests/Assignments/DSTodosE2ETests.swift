//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

class DSTodosE2ETests: E2ETestCase {
    func testTodosE2E() {
        let teacher = seeder.createUser()
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)
        seeder.enrollStudent(student, in: course)

        // Create an assignment with a submission
        let assignmentName = "Assignment 1"
        let assignmentDescription = "Assignment 1 Description"
        let assignment = seeder.createAssignment(courseId: course.id, assignementBody: .init(name: assignmentName, description: assignmentDescription, published: true))

        logInDSUser(teacher)

        let submission = seeder.createSubmission(courseId: course.id, assignmentId: assignment.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        pullToRefresh()
        Dashboard.courseCard(id: course.id).waitToExist()

        // Navigate to Todo tab, do a refresh so badge counter updates
        let oneNeedsGradingLabel = "1 NEEDS GRADING"
        let todoBadgeValue = "1 item"
        TabBar.todoTab.tap()
        pullToRefresh()
        XCTAssertEqual(TabBar.todoTab.value(), todoBadgeValue)
        XCTAssertTrue(app.find(labelContaining: oneNeedsGradingLabel).exists())
        app.find(label: oneNeedsGradingLabel).tap()
        SpeedGrader.doneButton.tap()
        TabBar.dashboardTab.tap()
        TabBar.todoTab.tap()
        XCTAssertEqual(TabBar.todoTab.value(), todoBadgeValue)
        XCTAssertTrue(app.find(label: oneNeedsGradingLabel).exists())

        // Check if the todo counter disappears
        seeder.postGrade(courseId: course.id, assignmentId: assignment.id, userId: student.id, requestBody: .init(posted_grade: "7"))
        pullToRefresh()
        pullToRefresh()
        XCTAssertNotEqual(TabBar.todoTab.value(), todoBadgeValue)
        XCTAssertFalse(app.find(label: oneNeedsGradingLabel).exists())

    }
}
