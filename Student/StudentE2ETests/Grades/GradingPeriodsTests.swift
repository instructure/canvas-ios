//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

class GradingPeriodsTests: E2ETestCase {
    typealias Helper = GradesHelper

    func testGradingPeriodsFilter() {
        // MARK: Seed the usual stuff with grading periods containing graded assignments
        let student = seeder.createUser()
        let enrollmentTerm = Helper.createEnrollmentTerm()
        let gradingPeriods = Helper.createTestGradingPeriods(enrollmentTerm: enrollmentTerm)
        let course = seeder.createCourse(enrollmentTerm: enrollmentTerm)
        seeder.enrollStudent(student, in: course)
        sleep(60)
        let assignment1 = AssignmentsHelper.createAssignment(
            course: course,
            name: "First Assignment",
            dueDate: Date.now.addSeconds(60),
            lockAt: Date.now.addSeconds(60)
        )
        Helper.submitAssignment(course: course, student: student, assignment: assignment1)
        Helper.gradeAssignment(grade: "1.0", course: course, assignment: assignment1, user: student)
        sleep(240)
        let assignment2 = AssignmentsHelper.createAssignment(
            course: course,
            name: "Second Assignment",
            dueDate: Date.now.addSeconds(60),
            lockAt: Date.now.addSeconds(60)
        )
        Helper.submitAssignment(course: course, student: student, assignment: assignment2)
        Helper.gradeAssignment(grade: "1.0", course: course, assignment: assignment2, user: student)
        sleep(60)

        // MARK: Get the user logged in, navigate to Grades page
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        Helper.navigateToGrades(course: course)
        let filterButton = Helper.filterButton.waitUntil(.visible)
        XCTAssertTrue(filterButton.isVisible)

        let assignment1Cell = Helper.cell(assignment: assignment1)
        let assignment2Cell = Helper.cell(assignment: assignment2)
        if filterButton.hasLabel(label: "All") {
            assignment1Cell.waitUntil(.visible)
            assignment2Cell.waitUntil(.visible)
            XCTAssertTrue(assignment1Cell.isVisible)
            XCTAssertTrue(assignment2Cell.isVisible)
        } else if filterButton.hasLabel(label: gradingPeriods[0].title) {
            assignment1Cell.waitUntil(.visible)
            assignment2Cell.waitUntil(.vanish)
            XCTAssertTrue(assignment1Cell.isVisible)
            XCTAssertTrue(assignment2Cell.isVanished)
        } else if filterButton.hasLabel(label: gradingPeriods[1].title) {
            assignment1Cell.waitUntil(.vanish)
            assignment2Cell.waitUntil(.visible)
            XCTAssertTrue(assignment1Cell.isVanished)
            XCTAssertTrue(assignment2Cell.isVisible)
        }

        // MARK: Check filter options
        filterButton.hit()
        let allOption = Helper.Filter.optionButton().waitUntil(.visible)
        let firstGPButton = Helper.Filter.optionButton(gradingPeriod: gradingPeriods[0]).waitUntil(.visible)
        let secondGPButton = Helper.Filter.optionButton(gradingPeriod: gradingPeriods[1]).waitUntil(.visible)
        XCTAssertTrue(allOption.isVisible)
        XCTAssertTrue(firstGPButton.isVisible)
        XCTAssertTrue(secondGPButton.isVisible)

        // MARK: Filter for All
        allOption.hit()
        XCTAssertTrue(assignment1Cell.waitUntil(.visible).isVisible)
        XCTAssertTrue(assignment2Cell.waitUntil(.visible).isVisible)

        // MARK: Filter for first grading period
        filterButton.waitUntil(.visible)
        XCTAssertTrue(filterButton.isVisible)

        filterButton.hit()
        XCTAssertTrue(allOption.waitUntil(.visible).isVisible)
        XCTAssertTrue(firstGPButton.waitUntil(.visible).isVisible)
        XCTAssertTrue(secondGPButton.waitUntil(.visible).isVisible)

        firstGPButton.hit()
        XCTAssertTrue(assignment1Cell.waitUntil(.visible).isVisible)
        XCTAssertTrue(assignment2Cell.waitUntil(.vanish).isVanished)

        // MARK: Filter for second grading period
        filterButton.waitUntil(.visible)
        XCTAssertTrue(filterButton.isVisible)

        filterButton.hit()
        XCTAssertTrue(allOption.waitUntil(.visible).isVisible)
        XCTAssertTrue(firstGPButton.waitUntil(.visible).isVisible)
        XCTAssertTrue(secondGPButton.waitUntil(.visible).isVisible)

        secondGPButton.hit()
        XCTAssertTrue(assignment1Cell.waitUntil(.vanish).isVanished)
        XCTAssertTrue(assignment2Cell.waitUntil(.visible).isVisible)
    }
}
