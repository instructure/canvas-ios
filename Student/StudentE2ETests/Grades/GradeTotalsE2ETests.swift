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

import Core
import TestsFoundation

class GradesTotalsE2ETests: E2ETestCase {
    func testGradeTotalsE2E() {
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // Create some assignments with different grading type
        let assignmentName = "Assignment"
        let assignmentDescription = "This is a description for Assignment"
        let assignment = seeder.createAssignment(courseId: course.id, assignementBody: .init(name: assignmentName, description: assignmentDescription, published: true, points_possible: 100))

        let assignment1Name = "Assignment 1"
        let assignment1 = seeder.createAssignment(courseId: course.id, assignementBody: .init(name: assignment1Name, description: assignmentDescription, published: true, points_possible: 100))

        let assignment2Name = "PassFail Grade Assignment"
        let assignment2 = seeder.createAssignment(courseId: course.id, assignementBody:
                .init(name: assignment2Name, description: assignmentDescription, published: true, points_possible: 100, grading_type: .pass_fail))

        let assignmentName3 = "Another PassFail Grade Assignment"
        let assignment3 = seeder.createAssignment(courseId: course.id, assignementBody:
                .init(name: assignmentName3, description: assignmentDescription, published: true, points_possible: 100, grading_type: .pass_fail))

        let assignmentName4 = "Another Percentage Grade Assignment"
        let assignment4 = seeder.createAssignment(courseId: course.id, assignementBody:
                .init(name: assignmentName4, description: assignmentDescription, published: true, points_possible: 100, grading_type: .percent))

        let assignmentName5 = "Another Letter Grade Assignment"
        let assignment5 = seeder.createAssignment(courseId: course.id, assignementBody:
                .init(name: assignmentName5, description: assignmentDescription, published: true, points_possible: 100, grading_type: .letter_grade))

        let assignmentName6 = "Another Letter Grade Assignment"
        let assignment6 = seeder.createAssignment(courseId: course.id, assignementBody:
                .init(name: assignmentName6, description: assignmentDescription, published: true, points_possible: 100, grading_type: .letter_grade))

        logInDSUser(student)

        // Create submissions for all
        seeder.createSubmission(courseId: course.id, assignmentId: assignment.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        seeder.createSubmission(courseId: course.id, assignmentId: assignment1.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        seeder.createSubmission(courseId: course.id, assignmentId: assignment2.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        seeder.createSubmission(courseId: course.id, assignmentId: assignment3.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        seeder.createSubmission(courseId: course.id, assignmentId: assignment4.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        seeder.createSubmission(courseId: course.id, assignmentId: assignment5.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        seeder.createSubmission(courseId: course.id, assignmentId: assignment6.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        // See if total grades is N/A
        Dashboard.courseCard(id: course.id).waitToExist()
        Dashboard.courseCard(id: course.id).tap()

        CourseNavigation.grades.waitToExist(5)
        sleep(1)
        CourseNavigation.grades.tap()
        app.find(label: "Total Grade").waitToExist()
        GradeList.totalGrade(totalGrade: "N/A").waitToExist()

        // Check if total is updating accordingly
        seeder.postGrade(courseId: course.id, assignmentId: assignment.id, userId: student.id, requestBody: .init(posted_grade: "100"))
        checkForTotalGrade(totalGrade: "100%")

        seeder.postGrade(courseId: course.id, assignmentId: assignment1.id, userId: student.id, requestBody: .init(posted_grade: "0"))
        checkForTotalGrade(totalGrade: "50%")

        seeder.postGrade(courseId: course.id, assignmentId: assignment2.id, userId: student.id, requestBody: .init(posted_grade: "fail"))
        checkForTotalGrade(totalGrade: "33.33%")

        seeder.postGrade(courseId: course.id, assignmentId: assignment3.id, userId: student.id, requestBody: .init(posted_grade: "pass"))
        checkForTotalGrade(totalGrade: "50%")

        seeder.postGrade(courseId: course.id, assignmentId: assignment4.id, userId: student.id, requestBody: .init(posted_grade: "75%"))
        checkForTotalGrade(totalGrade: "55%")

        seeder.postGrade(courseId: course.id, assignmentId: assignment5.id, userId: student.id, requestBody: .init(posted_grade: "A"))
        checkForTotalGrade(totalGrade: "62.5%")

        seeder.postGrade(courseId: course.id, assignmentId: assignment6.id, userId: student.id, requestBody: .init(posted_grade: "0"))
        checkForTotalGrade(totalGrade: "53.57%")
    }

    private func checkForTotalGrade(totalGrade: String) {
        sleep(3)
        pullToRefresh()
        GradeList.totalGrade(totalGrade: totalGrade).waitToExist(3)
    }
}
