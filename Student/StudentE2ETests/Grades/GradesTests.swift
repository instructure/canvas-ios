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
import XCTest

class GradesTests: E2ETestCase {
    func testGradesE2E() {
        // MARK: Seed the usual stuff with 2 assignments
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let assignment1 = seeder.createAssignment(courseId: course.id, assignementBody: .init(name: "Assignment1", description: "This is a description for Assignment1", published: true, points_possible: 10))

        let assignment2 = seeder.createAssignment(courseId: course.id, assignementBody: .init(name: "Assignment2", description: "This is a description for Assignment2", published: true, points_possible: 100))

        logInDSUser(student)

        // MARK: Create submissions for both
        GradesHelper.createSubmissionsForAssignments(course: course, student: student, assignments: [assignment1, assignment2])

        // MARK: Navigate to an assignment detail and check if grade updates
        var courseCard = Dashboard.courseCard(id: course.id).waitToExist()
        XCTAssertTrue(courseCard.isVisible)

        courseCard.tap()
        let assignmentsButton = CourseNavigation.assignments.waitToExist()
        XCTAssertTrue(assignmentsButton.isVisible)

        assignmentsButton.tap()
        let assignmentOne = AssignmentsList.assignment(id: assignment1.id).waitToExist()
        XCTAssertTrue(assignmentOne.isVisible)
        assignmentOne.tap()

        seeder.postGrade(courseId: course.id, assignmentId: assignment1.id, userId: student.id, requestBody: .init(posted_grade: "5"))
        seeder.postGrade(courseId: course.id, assignmentId: assignment2.id, userId: student.id, requestBody: .init(posted_grade: "100"))

        pullToRefresh()
        let assignmentGrade = AssignmentDetails.pointsOutOf(actualScore: "5", maxScore: "10").waitToExist()
        XCTAssertTrue(assignmentGrade.isVisible)

        // MARK: Navigate to Grades Page and check there too
        TabBar.dashboardTab.tap()
        courseCard = Dashboard.courseCard(id: course.id).waitToExist()
        XCTAssertTrue(courseCard.isVisible)

        courseCard.tap()
        let gradesButton = CourseNavigation.grades.waitToExist()
        XCTAssertTrue(gradesButton.isVisible)

        gradesButton.tap()
        XCTAssertTrue(app.find(label: "Total Grade").waitToExist().exists)
        XCTAssertTrue(GradeList.cell(assignmentID: assignment1.id).waitToExist(5).exists())
        XCTAssertTrue(GradeList.cell(assignmentID: assignment2.id).waitToExist(5).exists())
        XCTAssertTrue(GradeList.gradeOutOf(assignmentID: assignment1.id, actualPoints: "5", maxPoints: "10").waitToExist(5).exists())
        XCTAssertTrue(GradeList.gradeOutOf(assignmentID: assignment2.id, actualPoints: "100", maxPoints: "100").waitToExist(5).exists())
        XCTAssertTrue(GradeList.totalGrade(totalGrade: "95.45%").exists())
    }

    func testLetterGrades() {
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

    func testPercentageGrades() {
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

    func testPassFailGrade() {
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
