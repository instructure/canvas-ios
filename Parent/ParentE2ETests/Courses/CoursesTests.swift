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

import TestsFoundation
import XCTest

class CoursesTests: E2ETestCase {
    typealias DetailsHelper = CourseDetailsHelperParent

    func testCourses() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let parent = seeder.createUser()
        let course1 = seeder.createCourse()
        let course2 = seeder.createCourse()
        let assignment1 = AssignmentsHelper.createAssignment(course: course1, gradingType: .letter_grade)
        let assignment2 = AssignmentsHelper.createAssignment(course: course1)
        seeder.enrollStudent(student, in: course1)
        seeder.enrollStudent(student, in: course2)
        seeder.enrollParent(parent, in: course1)
        seeder.enrollParent(parent, in: course2)
        seeder.addObservee(parent: parent, student: student)
        GradesHelper.submitAssignment(course: course1, student: student, assignment: assignment1)
        GradesHelper.gradeAssignment(grade: "A", course: course1, assignment: assignment1, user: student)

        // MARK: Get the user logged in, check course cards
        logInDSUser(parent)
        let courseCard1 = DashboardHelperParent.courseCard(course: course1).waitUntil(.visible)
        let courseTitleLabel1 = DashboardHelperParent.courseTitleLabel(course: course1).waitUntil(.visible)
        let courseGradeLabel1 = DashboardHelperParent.courseGradeLabel(course: course1).waitUntil(.visible)
        let courseCard2 = DashboardHelperParent.courseCard(course: course2).waitUntil(.visible)
        let courseTitleLabel2 = DashboardHelperParent.courseTitleLabel(course: course2).waitUntil(.visible)
        let courseGradeLabel2 = DashboardHelperParent.courseGradeLabel(course: course2).waitUntil(.visible)
        XCTAssertTrue(courseCard1.isVisible)
        XCTAssertTrue(courseTitleLabel1.isVisible)
        XCTAssertTrue(courseGradeLabel1.isVisible)
        XCTAssertTrue(courseTitleLabel1.hasLabel(label: course1.name))
        XCTAssertTrue(courseGradeLabel1.hasLabel(label: "100%"))
        XCTAssertTrue(courseCard2.isVisible)
        XCTAssertTrue(courseTitleLabel2.isVisible)
        XCTAssertTrue(courseGradeLabel2.isVisible)
        XCTAssertTrue(courseTitleLabel2.hasLabel(label: course2.name))
        XCTAssertTrue(courseGradeLabel2.hasLabel(label: "No Grade"))

        // MARK: Details of Course 1
        courseCard1.hit()
        let totalGradeLabel = DetailsHelper.totalGradeLabel.waitUntil(.visible)
        let assignmentCell1 = DetailsHelper.assignmentCell(assignment: assignment1).waitUntil(.visible)
        let assignmentCell2 = DetailsHelper.assignmentCell(assignment: assignment2).waitUntil(.visible)
        let letterGradeLabelOfAssignment1 = DetailsHelper.letterGradeLabelOfAssignmentCell(assignment: assignment1, letterGrade: "A")
            .waitUntil(.visible)
        let backButton = DetailsHelper.backButton.waitUntil(.visible)
        XCTAssertTrue(totalGradeLabel.isVisible)
        XCTAssertTrue(totalGradeLabel.hasLabel(label: "Total grade is 100%"))
        XCTAssertTrue(assignmentCell1.isVisible)
        XCTAssertTrue(assignmentCell2.isVisible)
        XCTAssertTrue(letterGradeLabelOfAssignment1.isVisible)
        XCTAssertTrue(backButton.isVisible)

        // MARK: Details of Course 2
        backButton.hit()
        courseCard2.hit()
        XCTAssertTrue(totalGradeLabel.waitUntil(.visible).isVisible)
        XCTAssertTrue(totalGradeLabel.hasLabel(label: "Total grade is N/A"))
    }
}
