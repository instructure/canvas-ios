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

class DSContextCardE2ETests: E2ETestCase {
    func testContextCardE2E() {
        // Lets seed a teacher and student with some courses
        let teacher = seeder.createUser()
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)
        seeder.enrollStudent(student, in: course)

        // Seed some assignments
        let assignmentName = "Assignment 1"
        let assignmentDescription = "Assignment 1 Description"
        let assignment = seeder.createAssignment(courseId: course.id, assignementBody: .init(name: assignmentName, description: assignmentDescription, published: true))

        let assignmentName2 = "Assignment 2"
        let assignmentDescription2 = "Assignment 2 Description"
        let assignment2 = seeder.createAssignment(courseId: course.id, assignementBody: .init(name: assignmentName2, description: assignmentDescription2, published: true, points_possible: 10))

        let assignmentName3 = "Assignment 3"
        let assignmentDescription3 = "Assignment 3 Description"
        let assignment3 = seeder.createAssignment(courseId: course.id, assignementBody: .init(name: assignmentName3, description: assignmentDescription3, published: true, points_possible: 5))

        logInDSUser(teacher)

        // Seed submissions
        seeder.createSubmission(courseId: course.id, assignmentId: assignment.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        seeder.createSubmission(courseId: course.id, assignmentId: assignment2.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        seeder.createSubmission(courseId: course.id, assignmentId: assignment3.id, requestBody:
            .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))

        DashboardHelper.courseCard(course: course).hit()

        // Grade 2 of the submissions
        seeder.postGrade(courseId: course.id, assignmentId: assignment2.id, userId: student.id, requestBody: .init(posted_grade: "7"))

        seeder.postGrade(courseId: course.id, assignmentId: assignment3.id, userId: student.id, requestBody: .init(posted_grade: "5"))

        // Check the students context cards via People
        CourseDetailsHelper.cell(type: .people).hit()
        pullToRefresh()
        app.find(label: student.name).hit()
        PeopleHelper.ContextCard.userNameLabel.waitUntil(condition: .visible)
        PeopleHelper.ContextCard.submissionsTotalLabel.waitUntil(condition: .visible)
        XCTAssertEqual(PeopleHelper.ContextCard.userNameLabel.label, student.name)
        XCTAssertEqual(PeopleHelper.ContextCard.courseLabel.label, course.name)
        XCTAssertEqual(PeopleHelper.ContextCard.sectionLabel.label, "Section: \(course.name)")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionsTotalLabel.label, "3 submitted")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionsLateLabel.label, "0 late")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionsMissingLabel.label, "0 missing")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionCell(assignment: assignment).label, "Submission \(assignment.name), Submitted, NEEDS GRADING")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionCell(assignment: assignment2).label, "Submission \(assignment2.name), Submitted, grade 7 / 10")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionCell(assignment: assignment3).label, "Submission \(assignment3.name), Submitted, grade 5 / 5")

        PeopleHelper.backButton.hit()
        PeopleHelper.backButton.hit()

        // Check the students context cards via SpeedGrader
        CourseDetailsHelper.cell(type: .assignments).hit()
        AssignmentsHelper.assignmentButton(assignment: assignment).hit()
        AssignmentsHelper.Details.viewAllSubmissionsButton.hit()
        AssignmentsHelper.submissionListCell(user: student).hit()
        AssignmentsHelper.SpeedGrader.userButton.hit()
        PeopleHelper.ContextCard.userNameLabel.waitUntil(condition: .visible)

        XCTAssertEqual(PeopleHelper.ContextCard.userNameLabel.label, student.name)
        XCTAssertEqual(PeopleHelper.ContextCard.courseLabel.label, course.name)
        XCTAssertEqual(PeopleHelper.ContextCard.sectionLabel.label, "Section: \(course.name)")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionsTotalLabel.label, "3 submitted")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionsLateLabel.label, "0 late")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionsMissingLabel.label, "0 missing")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionCell(assignment: assignment).label, "Submission \(assignment.name), Submitted, NEEDS GRADING")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionCell(assignment: assignment2).label, "Submission \(assignment2.name), Submitted, grade 7 / 10")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionCell(assignment: assignment3).label, "Submission \(assignment3.name), Submitted, grade 5 / 5")
    }
}
