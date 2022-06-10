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

class DSGradingStandardsE2ETests: E2ETestCase {
    func testGradingStandardsE2E() {
        // Seed the usual stuff with 2 assignments
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        let gradingScheme = seeder.postGradingStandards(courseId: course.id, requestBody: .init())
        seeder.updateCourseWithGradingScheme(courseId: course.id, gradingStandardId: Int(gradingScheme.id)!)

        let assignmentName = "Assignment"
        let assignmentDescription = "This is a description for Assignment"
        let assignment = seeder.createAssignment(courseId: course.id, assignementBody: .init(name: assignmentName, description: assignmentDescription, published: true, points_possible: 100))

        let assignment1Name = "Assignment 1"
        let assignment1 = seeder.createAssignment(courseId: course.id, assignementBody: .init(name: assignment1Name, description: assignmentDescription, published: true, points_possible: 100))

        logInDSUser(student)

        // Create submissions for all
        seeder.createSubmission(courseId: course.id, assignmentId: assignment.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        seeder.createSubmission(courseId: course.id, assignmentId: assignment1.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        Dashboard.courseCard(id: course.id).waitToExist()
        Dashboard.courseCard(id: course.id).tap()

        CourseNavigation.grades.waitToExist(5)
        sleep(1)
        CourseNavigation.grades.tap()
        app.find(label: "Total Grade").waitToExist()
        GradeList.totalGrade(totalGrade: "N/A (F)").waitToExist()

        // Check if total is updating accordingly
        seeder.postGrade(courseId: course.id, assignmentId: assignment.id, userId: student.id, requestBody: .init(posted_grade: "100"))
        checkForTotalGrade(totalGrade: "100% (A)")

        seeder.postGrade(courseId: course.id, assignmentId: assignment1.id, userId: student.id, requestBody: .init(posted_grade: "0"))
        checkForTotalGrade(totalGrade: "50% (F)")
    }

    private func checkForTotalGrade(totalGrade: String) {
        sleep(3)
        pullToRefresh()
        GradeList.totalGrade(totalGrade: totalGrade).waitToExist(3)
    }
}
