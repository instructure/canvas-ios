//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

class SubmissionsListFilterTests: E2ETestCase {
    typealias DetailsHelper = AssignmentsHelper.Details
    typealias SubmissionsHelper = AssignmentsHelper.Details.TeacherSubmissionsList
    typealias FilterHelper = AssignmentsHelper.Details.TeacherSubmissionsList.Filter

    func testSubmissionsListFilter() {
        var teacher: DSUser!
        var student1: DSUser!
        var student2: DSUser!
        var course: DSCourse!
        var assignment: DSAssignment!

        XCTContext.runActivity(named: "Seed test data") { _ in
            teacher = seeder.createUser()
            student1 = seeder.createUser(name: "Student One")
            student2 = seeder.createUser(name: "Student Two")
            course = seeder.createCourse()

            seeder.enrollTeacher(teacher, in: course)
            seeder.enrollStudent(student1, in: course)
            seeder.enrollStudent(student2, in: course)

            assignment = AssignmentsHelper.createAssignment(
                course: course,
                name: "Test Assignment for Submissions",
                submissionTypes: [.online_text_entry]
            )

            GradesHelper.submitAssignment(course: course, student: student1, assignment: assignment)
        }

        XCTContext.runActivity(named: "Navigate to submissions list filter") { _ in
            logInDSUser(teacher)
            let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
            XCTAssertVisible(courseCard)

            AssignmentsHelper.navigateToAssignments(course: course)
            let navBar = app.find(labelContaining: "Assignments", type: .staticText)
            XCTAssertVisible(navBar)

            let assignmentButton = AssignmentsHelper.assignmentButton(assignment: assignment).waitUntil(.visible)
            XCTAssertVisible(assignmentButton)
            XCTAssertContains(assignmentButton.label, assignment.name)
            assignmentButton.hit()

            let viewAllSubmissionsButton = DetailsHelper.viewAllSubmissionsButton.waitUntil(.visible)
            XCTAssertVisible(viewAllSubmissionsButton)
            viewAllSubmissionsButton.hit()

            let filterButton = SubmissionsHelper.filterButton.waitUntil(.visible)
            XCTAssertVisible(filterButton)
            filterButton.hit()
        }

        XCTContext.runActivity(named: "Verify filter screen appears") { _ in
            // TODO: Replace with commented version after a11y issues are fixed (see comments for `NavigationBarTitleView`)
            let navBar = FilterHelper.navBar(assignment: assignment).waitUntil(.visible)
            XCTAssertVisible(navBar)

//            if #available(iOS 26, *) {
//                let navTitle = FilterHelper.navTitle.waitUntil(.visible)
//                let navSubtitle = FilterHelper.navSubtitle(assignment: assignment).waitUntil(.visible)
//                XCTAssertVisible(navTitle)
//                XCTAssertVisible(navSubtitle)
//            } else {
//                let navBar = FilterHelper.navBar(assignment: assignment).waitUntil(.visible)
//                XCTAssertVisible(navBar)
//            }
        }

        XCTContext.runActivity(named: "Verify filter rows are displayed") { _ in
            let notSubmittedSwitch = FilterHelper.StatusOptions.notSubmitted.waitUntil(.visible)
            XCTAssertVisible(notSubmittedSwitch)
            XCTAssertEqual(notSubmittedSwitch.value as? String, "1")

            let submittedSwitch = FilterHelper.StatusOptions.submitted.waitUntil(.visible)
            XCTAssertVisible(submittedSwitch)
            XCTAssertEqual(submittedSwitch.value as? String, "1")

            let gradedSwitch = FilterHelper.StatusOptions.graded.waitUntil(.visible)
            XCTAssertVisible(gradedSwitch)
            XCTAssertEqual(gradedSwitch.value as? String, "1")

            let lateSwitch = FilterHelper.StatusOptions.late.waitUntil(.visible)
            XCTAssertVisible(lateSwitch)
            XCTAssertEqual(lateSwitch.value as? String, "1")

            let missingSwitch = FilterHelper.StatusOptions.missing.waitUntil(.visible)
            XCTAssertVisible(missingSwitch)
            XCTAssertEqual(missingSwitch.value as? String, "1")

            app.scrollDown()

            let scoredMoreThanField = FilterHelper.PreciseFiltering.scoredMoreThanField.waitUntil(.visible)
            XCTAssertVisible(scoredMoreThanField)

            let scoredLessThanField = FilterHelper.PreciseFiltering.scoredLessThanField.waitUntil(.visible)
            XCTAssertVisible(scoredLessThanField)

            let studentSortableNameRadio = FilterHelper.SortBy.studentSortableName.waitUntil(.visible)
            XCTAssertVisible(studentSortableNameRadio)
            XCTAssertSelected(studentSortableNameRadio)

            let studentNameRadio = FilterHelper.SortBy.studentName.waitUntil(.visible)
            XCTAssertVisible(studentNameRadio)
            XCTAssertNotSelected(studentNameRadio)

            let submissionDateRadio = FilterHelper.SortBy.submissionDate.waitUntil(.visible)
            XCTAssertVisible(submissionDateRadio)
            XCTAssertNotSelected(submissionDateRadio)

            let submissionStatusRadio = FilterHelper.SortBy.submissionStatus.waitUntil(.visible)
            XCTAssertVisible(submissionStatusRadio)
            XCTAssertNotSelected(submissionStatusRadio)
        }
    }
}
