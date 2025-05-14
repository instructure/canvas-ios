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
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Assignments and check visibility
        Helper.navigateToAssignments(course: course)
        let navBar = Helper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        let assignmentButton = Helper.assignmentButton(assignment: assignment).waitUntil(.visible)
        XCTAssertTrue(assignmentButton.isVisible)
        XCTAssertContains(assignmentButton.label, assignment.name)

        // MARK: Tap on the assignment and check details
        assignmentButton.hit()
        let nameLabel = DetailsHelper.name.waitUntil(.visible)
        let pointsLabel = DetailsHelper.points.waitUntil(.visible)
        let publishedLabel = DetailsHelper.published.waitUntil(.visible)
        let dueLabel = DetailsHelper.due.waitUntil(.visible)
        let submissionTypesLabel = DetailsHelper.submissionTypes.waitUntil(.visible)
        let viewAllSubmissionsButton = DetailsHelper.viewAllSubmissionsButton.waitUntil(.visible)
        let oneNeedsGrading = DetailsHelper.oneNeedsGradingButton.waitUntil(.visible)
        let descriptionLabel = DetailsHelper.description(assignment: assignment).waitUntil(.visible)
        XCTAssertTrue(nameLabel.isVisible)
        XCTAssertEqual(nameLabel.label, assignment.name)
        XCTAssertTrue(pointsLabel.isVisible)
        XCTAssertEqual(pointsLabel.label, "\(assignment.points_possible!) pt")
        XCTAssertTrue(publishedLabel.isVisible)
        XCTAssertEqual(publishedLabel.label, "Published")
        XCTAssertTrue(dueLabel.isVisible)
        XCTAssertContains(dueLabel.label, "No due date")
        XCTAssertTrue(submissionTypesLabel.isVisible)
        XCTAssertEqual(submissionTypesLabel.label, "Text Entry")
        XCTAssertTrue(viewAllSubmissionsButton.isVisible)
        XCTAssertEqual(viewAllSubmissionsButton.label, "View all submissions")
        XCTAssertTrue(oneNeedsGrading.isVisible)
        XCTAssertEqual(oneNeedsGrading.stringValue, "100%")
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
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Assignments
        Helper.navigateToAssignments(course: course)
        let navBar = Helper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        // MARK: Check due date of assignments
        let yesterdaysAssignmentButton = Helper.assignmentButton(assignment: yesterdaysAssignment).waitUntil(.visible)
        let tomorrowsAssignmentButton = Helper.assignmentButton(assignment: tomorrowsAssignment).waitUntil(.visible)
        XCTAssertTrue(yesterdaysAssignmentButton.isVisible)
        XCTAssertContains(yesterdaysAssignmentButton.label, "Due Yesterday")
        XCTAssertTrue(tomorrowsAssignmentButton.isVisible)
        XCTAssertContains(tomorrowsAssignmentButton.label, "Due Tomorrow")
    }
}
