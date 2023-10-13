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

class AssignmentsTests: E2ETestCase {
    typealias Helper = AssignmentsHelper
    typealias DetailsHelper = Helper.Details

    func testViewAssignmentAndDetails() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Create an assignment with a submission
        let assignment = Helper.createAssignment(course: course, submissionTypes: [.online_text_entry])
        GradesHelper.submitAssignment(course: course, student: student, assignment: assignment)

        // MARK: Get the user logged in
        logInDSUser(teacher)

        // MARK: Navigate to Assignments and check visibility
        Helper.navigateToAssignments(course: course)
        let navBar = Helper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        let assignmentButton = Helper.assignmentButton(assignment: assignment).waitUntil(.visible)
        XCTAssertTrue(assignmentButton.isVisible)
        XCTAssertTrue(assignmentButton.label.contains(assignment.name))

        // MARK: Tap on the assignment and check details
        assignmentButton.hit()
        let detailsNavBar = DetailsHelper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(detailsNavBar.isVisible)

        let nameLabel = DetailsHelper.name.waitUntil(.visible)
        XCTAssertTrue(nameLabel.isVisible)
        XCTAssertTrue(nameLabel.hasLabel(label: assignment.name))

        let pointsLabel = DetailsHelper.points.waitUntil(.visible)
        XCTAssertTrue(pointsLabel.isVisible)
        XCTAssertTrue(pointsLabel.hasLabel(label: "\(assignment.points_possible!) pt"))

        let publishedLabel = DetailsHelper.published.waitUntil(.visible)
        XCTAssertTrue(publishedLabel.isVisible)
        XCTAssertTrue(publishedLabel.hasLabel(label: "Published"))

        let dueLabel = DetailsHelper.due.waitUntil(.visible)
        XCTAssertTrue(dueLabel.isVisible)
        XCTAssertTrue(dueLabel.hasLabel(label: "No due date", strict: false))

        let submissionTypesLabel = DetailsHelper.submissionTypes.waitUntil(.visible)
        XCTAssertTrue(submissionTypesLabel.isVisible)
        XCTAssertTrue(submissionTypesLabel.hasLabel(label: "Text Entry"))

        let viewAllSubmissionsButton = DetailsHelper.viewAllSubmissionsButton.waitUntil(.visible)
        XCTAssertTrue(viewAllSubmissionsButton.isVisible)
        XCTAssertTrue(viewAllSubmissionsButton.hasLabel(label: "View all submissions"))

        let oneNeedsGrading = DetailsHelper.oneNeedsGradingButton.waitUntil(.visible)
        XCTAssertTrue(oneNeedsGrading.isVisible)
        XCTAssertTrue(oneNeedsGrading.hasValue(value: "100%"))

        let descriptionLabel = DetailsHelper.description(assignment: assignment).waitUntil(.visible)
        XCTAssertTrue(descriptionLabel.isVisible)
    }

    func testAssignmentDueDate() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Create 2 assignments (1 due yesterday and 1 due tomorrow)
        let yesterdaysDate = Date.now.addDays(-1)
        let yesterdaysAssignment = Helper.createAssignment(
            course: course, name: "Yesterdays Assignment", dueDate: yesterdaysDate)

        let tomorrowsDate = Date.now.addDays(1)
        let tomorrowsAssignment = Helper.createAssignment(
            course: course, name: "Tomorrows Assignment", dueDate: tomorrowsDate)

        // MARK: Get the user logged in
        logInDSUser(teacher)

        // MARK: Navigate to Assignments
        Helper.navigateToAssignments(course: course)
        let navBar = Helper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        // MARK: Check Yesterdays Assignment due date
        let yesterdaysAssignmentButton = Helper.assignmentButton(assignment: yesterdaysAssignment)
            .waitUntil(.visible)
        XCTAssertTrue(yesterdaysAssignmentButton.isVisible)
        XCTAssertTrue(yesterdaysAssignmentButton.label.contains("Due Yesterday"))

        // MARK: Check Tomorrows Assignment due date
        let tomorrowsAssignmentButton = Helper.assignmentButton(assignment: tomorrowsAssignment)
            .waitUntil(.visible)
        XCTAssertTrue(tomorrowsAssignmentButton.isVisible)
        XCTAssertTrue(tomorrowsAssignmentButton.label.contains("Due Tomorrow"))
    }
}
