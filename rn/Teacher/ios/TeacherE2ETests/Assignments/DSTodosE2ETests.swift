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

        seeder.createSubmission(courseId: course.id, assignmentId: assignment.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        pullToRefresh()
        DashboardHelper.courseCard(course: course).waitUntil(.visible)

        // Navigate to Todo tab, do a refresh so badge counter updates
        let oneNeedsGradingLabel = "1 NEEDS GRADING"
        let todoBadgeValue = "1 item"
        BaseHelper.TabBar.todoTab.hit()
        pullToRefresh()
        XCTAssertTrue(BaseHelper.TabBar.todoTab.waitUntil(.visible).hasValue(value: todoBadgeValue))
        XCTAssertTrue(app.find(labelContaining: oneNeedsGradingLabel).waitUntil(.visible).isVisible)
        app.find(label: oneNeedsGradingLabel).hit()
        AssignmentsHelper.SpeedGrader.doneButton.hit()
        BaseHelper.TabBar.dashboardTab.hit()
        BaseHelper.TabBar.todoTab.hit()
        XCTAssertTrue(BaseHelper.TabBar.todoTab.waitUntil(.visible).hasValue(value: todoBadgeValue))
        XCTAssertTrue(app.find(label: oneNeedsGradingLabel).waitUntil(.visible).isVisible)

        // Check if the todo counter disappears
        seeder.postGrade(courseId: course.id, assignmentId: assignment.id, userId: student.id, requestBody: .init(posted_grade: "7"))
        pullToRefresh()
        pullToRefresh()
        XCTAssertFalse(BaseHelper.TabBar.todoTab.waitUntil(.visible).hasValue(value: todoBadgeValue))
        XCTAssertTrue(app.find(label: oneNeedsGradingLabel).waitUntil(.vanish).isVanished)
    }
}
