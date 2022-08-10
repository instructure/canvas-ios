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

class DSGradesE2ETests: E2ETestCase {
    func testGradesE2E() {
        // Seed the usual stuff with 2 assignments
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let assignmentName = "Assignment"
        let assignmentDescription = "This is a description for Assignment"
        let assignment = seeder.createAssignment(courseId: course.id, assignementBody: .init(name: assignmentName, description: assignmentDescription, published: true, points_possible: 10))

        let assignment1Name = "Assignment 1"
        let assignment1Description = "This is a description for Assignment 1"
        let assignment1 = seeder.createAssignment(courseId: course.id, assignementBody: .init(name: assignment1Name, description: assignment1Description, published: true, points_possible: 100))

        logInDSUser(student)

        // Create submissions for both
        seeder.createSubmission(courseId: course.id, assignmentId: assignment.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        seeder.createSubmission(courseId: course.id, assignmentId: assignment1.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        // Navigate to an assignment detail and check if grade updates
        Dashboard.courseCard(id: course.id).waitToExist()
        Dashboard.courseCard(id: course.id).tap()
        CourseNavigation.assignments.waitToExist()
        CourseNavigation.assignments.tap()
        AssignmentsList.assignment(id: assignment.id).tap()

        seeder.postGrade(courseId: course.id, assignmentId: assignment.id, userId: student.id, requestBody: .init(posted_grade: "5"))
        seeder.postGrade(courseId: course.id, assignmentId: assignment1.id, userId: student.id, requestBody: .init(posted_grade: "100"))

        pullToRefresh()
        AssignmentDetails.pointsOutOf(actualScore: "5", maxScore: "10").waitToExist()

        // Navigate to Grades Page and check there too
        TabBar.dashboardTab.tap()
        Dashboard.courseCard(id: course.id).waitToExist()
        Dashboard.courseCard(id: course.id).tap()
        CourseNavigation.grades.waitToExist()
        CourseNavigation.grades.tap()
        app.find(label: "Total Grade").waitToExist()
        XCTAssertTrue(GradeList.cell(assignmentID: assignment.id).waitToExist(5).exists())
        XCTAssertTrue(GradeList.cell(assignmentID: assignment1.id).waitToExist(5).exists())
        XCTAssertTrue(GradeList.gradeOutOf(actualPoints: "5", maxPoints: "10").waitToExist(5).exists())
        XCTAssertTrue(GradeList.gradeOutOf(actualPoints: "100", maxPoints: "100").waitToExist(5).exists())
        XCTAssertTrue(GradeList.gradeOutOf(actualPoints: "100", maxPoints: "100").waitToExist(5).exists())
    }

    func testLetterGradesE2E() {
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let assignmentName = "Letter Grade Assignment"
        let assignmentDescription = "This is a description for Assignment"
        let assignment = seeder.createAssignment(courseId: course.id, assignementBody:
                .init(name: assignmentName, description: assignmentDescription, published: true, points_possible: 100, grading_type: .letter_grade))

        let assignmentName1 = "Another Letter Grade Assignment"
        let assignment1 = seeder.createAssignment(courseId: course.id, assignementBody:
                .init(name: assignmentName1, description: assignmentDescription, published: true, points_possible: 100, grading_type: .letter_grade))

        let assignmentName2 = "Graded with Letter Assignment"
        let assignment2 = seeder.createAssignment(courseId: course.id, assignementBody:
                .init(name: assignmentName2, description: assignmentDescription, published: true, points_possible: 100, grading_type: .letter_grade))

        logInDSUser(student)

        seeder.createSubmission(courseId: course.id, assignmentId: assignment.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        seeder.createSubmission(courseId: course.id, assignmentId: assignment1.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        seeder.createSubmission(courseId: course.id, assignmentId: assignment2.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        Dashboard.courseCard(id: course.id).waitToExist(15)
        Dashboard.courseCard(id: course.id).tap()
        CourseNavigation.assignments.waitToExist()
        CourseNavigation.assignments.tap()
        pullToRefresh()
        AssignmentsList.assignment(id: assignment.id).waitToExist(5)
        AssignmentsList.assignment(id: assignment.id).tap()

        seeder.postGrade(courseId: course.id, assignmentId: assignment.id, userId: student.id, requestBody:
                .init(posted_grade: "1"))
        seeder.postGrade(courseId: course.id, assignmentId: assignment1.id, userId: student.id, requestBody:
                .init(posted_grade: "100"))
        seeder.postGrade(courseId: course.id, assignmentId: assignment2.id, userId: student.id, requestBody:
                .init(posted_grade: "B-"))
        pullToRefresh()

        XCTAssertEqual(AssignmentDetails.gradeCircle.label(), "Scored 1 out of 100 points possible")
        XCTAssertEqual(AssignmentDetails.gradeDisplayGrade.label(), "F")

        NavBar.backButton.tap()
        AssignmentsList.assignment(id: assignment1.id).waitToExist()
        AssignmentsList.assignment(id: assignment1.id).tap()
        XCTAssertEqual(AssignmentDetails.gradeCircle.label(), "Scored 100 out of 100 points possible")
        XCTAssertEqual(AssignmentDetails.gradeDisplayGrade.label(), "A")

        NavBar.backButton.tap()
        AssignmentsList.assignment(id: assignment2.id).waitToExist()
        AssignmentsList.assignment(id: assignment2.id).tap()
        XCTAssertEqual(AssignmentDetails.gradeCircle.label(), "Scored 83 out of 100 points possible")
        XCTAssertEqual(AssignmentDetails.gradeDisplayGrade.label(), "B-")
    }

    func testPercentageGradesE2E() {
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let assignmentName = "Percentage Grade Assignment"
        let assignmentDescription = "This is a description for Assignment"
        let assignment = seeder.createAssignment(courseId: course.id, assignementBody:
                .init(name: assignmentName, description: assignmentDescription, published: true, points_possible: 100, grading_type: .percent))

        let assignmentName1 = "Another Percentage Grade Assignment"
        let assignment1 = seeder.createAssignment(courseId: course.id, assignementBody:
                .init(name: assignmentName1, description: assignmentDescription, published: true, points_possible: 100, grading_type: .percent))

        logInDSUser(student)

        seeder.createSubmission(courseId: course.id, assignmentId: assignment.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        seeder.createSubmission(courseId: course.id, assignmentId: assignment1.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        Dashboard.courseCard(id: course.id).waitToExist(15)
        Dashboard.courseCard(id: course.id).tap()
        CourseNavigation.assignments.tap()
        AssignmentsList.assignment(id: assignment.id).waitToExist()
        AssignmentsList.assignment(id: assignment.id).tap()

        seeder.postGrade(courseId: course.id, assignmentId: assignment.id, userId: student.id, requestBody:
                .init(posted_grade: "1"))
        seeder.postGrade(courseId: course.id, assignmentId: assignment1.id, userId: student.id, requestBody:
                .init(posted_grade: "100"))
        pullToRefresh()

        XCTAssertEqual(AssignmentDetails.gradeCircle.label(), "Scored 1 out of 100 points possible")
        XCTAssertEqual(AssignmentDetails.gradeDisplayGrade.label(), "1%")

        NavBar.backButton.tap()
        AssignmentsList.assignment(id: assignment1.id).waitToExist()
        AssignmentsList.assignment(id: assignment1.id).tap()
        XCTAssertEqual(AssignmentDetails.gradeCircle.label(), "Scored 100 out of 100 points possible")
        XCTAssertEqual(AssignmentDetails.gradeDisplayGrade.label(), "100%")
    }

    func testPassFailGradeE2E() {
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let assignmentName = "PassFail Grade Assignment"
        let assignmentDescription = "This is a description for Assignment"
        let assignment = seeder.createAssignment(courseId: course.id, assignementBody:
                .init(name: assignmentName, description: assignmentDescription, published: true, points_possible: 100, grading_type: .pass_fail))

        let assignmentName1 = "Another PassFail Grade Assignment"
        let assignment1 = seeder.createAssignment(courseId: course.id, assignementBody:
                .init(name: assignmentName1, description: assignmentDescription, published: true, points_possible: 100, grading_type: .pass_fail))

        let assignmentName2 = "Incomplete Grade Assignment"
        let assignment2 = seeder.createAssignment(courseId: course.id, assignementBody:
                .init(name: assignmentName2, description: assignmentDescription, published: true, points_possible: 100, grading_type: .pass_fail))

        let assignmentName3 = "Fail Grade Assignment"
        let assignment3 = seeder.createAssignment(courseId: course.id, assignementBody:
                .init(name: assignmentName3, description: assignmentDescription, published: true, points_possible: 100, grading_type: .pass_fail))

        logInDSUser(student)

        seeder.createSubmission(courseId: course.id, assignmentId: assignment.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        seeder.createSubmission(courseId: course.id, assignmentId: assignment1.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        seeder.createSubmission(courseId: course.id, assignmentId: assignment3.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        Dashboard.courseCard(id: course.id).waitToExist(15)
        Dashboard.courseCard(id: course.id).tap()
        CourseNavigation.assignments.waitToExist()
        CourseNavigation.assignments.tap()

        seeder.postGrade(courseId: course.id, assignmentId: assignment.id, userId: student.id, requestBody:
                .init(posted_grade: "pass"))
        seeder.postGrade(courseId: course.id, assignmentId: assignment1.id, userId: student.id, requestBody:
                .init(posted_grade: "100"))
        seeder.postGrade(courseId: course.id, assignmentId: assignment2.id, userId: student.id, requestBody:
                .init(posted_grade: "fail"))
        seeder.postGrade(courseId: course.id, assignmentId: assignment3.id, userId: student.id, requestBody:
                .init(posted_grade: "fail"))
        pullToRefresh()

        AssignmentsList.assignment(id: assignment.id).waitToExist()
        AssignmentsList.assignment(id: assignment.id).tap()

        XCTAssertEqual(AssignmentDetails.gradeCircle.label(), "Scored 100 out of 100 points possible")
        XCTAssertEqual(AssignmentDetails.gradeDisplayGrade.label(), "Complete")

        NavBar.backButton.tap()
        AssignmentsList.assignment(id: assignment1.id).waitToExist()
        AssignmentsList.assignment(id: assignment1.id).tap()
        XCTAssertEqual(AssignmentDetails.gradeCircle.label(), "Scored 100 out of 100 points possible")
        XCTAssertEqual(AssignmentDetails.gradeDisplayGrade.label(), "Complete")

        NavBar.backButton.tap()
        AssignmentsList.assignment(id: assignment2.id).waitToExist()
        AssignmentsList.assignment(id: assignment2.id).tap()
        XCTAssertEqual(AssignmentDetails.gradeCircle.label(), "Scored 0 out of 100 points possible")
        XCTAssertEqual(AssignmentDetails.gradeDisplayGrade.label(), "Incomplete")

        NavBar.backButton.tap()
        AssignmentsList.assignment(id: assignment2.id).waitToExist()
        AssignmentsList.assignment(id: assignment2.id).tap()
        XCTAssertEqual(AssignmentDetails.gradeCircle.label(), "Scored 0 out of 100 points possible")
        XCTAssertEqual(AssignmentDetails.gradeDisplayGrade.label(), "Incomplete")
    }
}
