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

import Foundation
import TestsFoundation
import Core

class DSSubmissionsE2ETests: E2ETestCase {
    func testSubmission() {
        let users = seeder.createUsers(2)
        let course = seeder.createCourse()
        let student = users[0]
        let teacher = users[1]

        seeder.enrollStudent(student, in: course)
        seeder.enrollTeacher(teacher, in: course)

        let assignmentName = "Assignment 1"
        let assignmentDescription = "This is a description for Assignment 1"
        let assignment = seeder.createAssignment(courseId: course.id, assignementBody: .init(name: assignmentName, description: assignmentDescription, published: true))

        logInDSUser(teacher)

        // Need to sleep here because the backend needs some time to handle the assignment creation
        sleep(5)

        let submission = seeder.createSubmission(courseId: course.id, assignmentId: assignment.id, requestBody:
            .init(submission_type: SubmissionType.online_text_entry, body: "This is a submission body", user_id: student.id))

        Dashboard.courseCard(id: course.id).waitToExist()
        Dashboard.courseCard(id: course.id).tap()
        CourseNavigation.assignments.tap()
        AssignmentsList.assignment(id: assignment.id).tap()
        AssignmentDetails.viewAllSubmissionsButton.tap()
        SubmissionsListPage.cell(userID: student.id).waitToExist()
        SubmissionsListPage.cell(userID: student.id).tap()
        app.find(label: submission.body).waitToExist()
    }
}
