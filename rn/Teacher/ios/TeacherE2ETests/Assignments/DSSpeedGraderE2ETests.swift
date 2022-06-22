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
import Core

class DSSpeedGraderE2ETests: E2ETestCase {
    func testSpeedGraderE2E() {
        let users = seeder.createUsers(2)
        let course = seeder.createCourse()
        let student = users[0]
        let teacher = users[1]
        seeder.enrollStudent(student, in: course)
        seeder.enrollTeacher(teacher, in: course)

        let assignmentName = "Assignment 1"
        let assignmentDescription = "This is a description for Assignment 1"
        let assignment = seeder.createAssignment(courseId: course.id, assignementBody: .init(name: assignmentName, description: assignmentDescription, published: true, points_possible: 10))

        logInDSUser(teacher)

        let submission = seeder.createSubmission(courseId: course.id, assignmentId: assignment.id, requestBody:
            .init(submission_type: SubmissionType.online_text_entry, body: "This is a submission body", user_id: student.id))

        Dashboard.courseCard(id: course.id).waitToExist()
        Dashboard.courseCard(id: course.id).tap()
        CourseNavigation.assignments.waitToExist()
        CourseNavigation.assignments.tap()
        sleep(1)
        AssignmentsList.assignment(id: assignment.id).waitToExist().tap()
        AssignmentDetails.viewAllSubmissionsButton.waitToExist()
        AssignmentDetails.viewAllSubmissionsButton.tap()
        SubmissionsListPage.cell(userID: student.id).waitToExist()
        SubmissionsListPage.cell(userID: student.id).tap()
        SpeedGrader.Segment.grades.tap()
        sleep(1)
        app.find(id: "SpeedGrader.gradeButton", label: "addSolid").tap()
        app.find(label: "Grade", type: .textField).tap().typeText("5")
        app.find(label: "OK").tap()
        SpeedGrader.doneButton.tap()
        sleep(1)
        pullToRefresh()
        XCTAssertFalse(SubmissionsListPage.cell(userID: student.id).exists())
        app.find(labelContaining: "Filter").tap()
        app.find(label: "Graded").tap()
        app.find(label: "Done").tap()
        pullToRefresh()
        SubmissionsListPage.cell(userID: student.id).waitToExist()
    }
}
