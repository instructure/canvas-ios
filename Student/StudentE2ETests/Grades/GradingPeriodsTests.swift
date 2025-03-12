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
import XCTest

class GradingPeriodsTests: E2ETestCase {
    typealias Helper = GradesHelper

    func testGradingPeriodsFilter() throws {
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

        let filterButton = Helper.filterButton

        XCTContext.runActivity(named: "Navigate to Grades page") { _ in
            let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
            XCTAssertTrue(courseCard.isVisible)

            Helper.navigateToGrades(course: course)
            filterButton.waitUntil(.visible)
            XCTAssertTrue(filterButton.isVisible)
        }

        // MARK: Check filter options, set sorting to group
        let allOption = Helper.Filter.optionButton()
        let firstGPButton = Helper.Filter.optionButton(gradingPeriod: gradingPeriods[0])
        let secondGPButton = Helper.Filter.optionButton(gradingPeriod: gradingPeriods[1])
        let sortByGroupSwitch = Helper.Filter.sortByGroupSwitch
        let sortByDateSwitch = Helper.Filter.sortByDateSwitch
        let saveButton = Helper.Filter.saveButton

        XCTContext.runActivity(named: "Check filter screen options") { _ in
            filterButton.hit()

            XCTContext.runActivity(named: "Work around rendering bug") { _ in
                // Sometimes only the "all grading periods" row renders and an empty row below
                firstGPButton.waitUntil(.visible)

                if firstGPButton.isVanished {
                    Helper.Filter.cancelButton.hit()
                    allOption.waitUntil(.vanish)
                    filterButton.hit()
                }
            }

            XCTAssertTrue(allOption.waitUntil(.visible).isVisible)
            XCTAssertTrue(firstGPButton.waitUntil(.visible).isVisible)
            XCTAssertTrue(secondGPButton.waitUntil(.visible).isVisible)
            XCTAssertTrue(sortByGroupSwitch.waitUntil(.visible).isVisible)
            XCTAssertTrue(sortByDateSwitch.waitUntil(.visible).isVisible)
            XCTAssertTrue(saveButton.waitUntil(.visible).isVisible)
            XCTAssertTrue(saveButton.waitUntil(.visible).isDisabled)
        }

        XCTContext.runActivity(named: "Set sorting to groups") { _ in
            allOption.hit()
            sortByGroupSwitch.hit()
            XCTAssertTrue(saveButton.waitUntil(.enabled).isEnabled)
            saveButton.hit()
        }

        let assignment1Cell = Helper.cell(assignment: assignment1)
        let assignment2Cell = Helper.cell(assignment: assignment2)

        XCTContext.runActivity(named: "Check if assignment list isn't filtered") { _ in
            XCTAssertTrue(assignment1Cell.waitUntil(.visible).isVisible)
            XCTAssertTrue(assignment2Cell.waitUntil(.visible).isVisible)
        }

        XCTContext.runActivity(named: "Filter to first grading period") { _ in
            filterButton.hit()
            firstGPButton.waitUntil(.visible).hit()
            XCTAssertTrue(saveButton.waitUntil(.enabled).isEnabled)
            saveButton.hit()
        }

        XCTContext.runActivity(named: "Check if assignment list is filtered") { _ in
            XCTAssertTrue(assignment1Cell.waitUntil(.visible).isVisible)
            XCTAssertTrue(assignment2Cell.waitUntil(.vanish).isVanished)
        }

        XCTContext.runActivity(named: "Filter to second grading period") { _ in
            filterButton.waitUntil(.visible)
            XCTAssertTrue(filterButton.isVisible)
            filterButton.hit()

            XCTAssertTrue(allOption.waitUntil(.visible).isVisible)
            XCTAssertTrue(firstGPButton.waitUntil(.visible).isVisible)
            XCTAssertTrue(secondGPButton.waitUntil(.visible).isVisible)
            XCTAssertTrue(saveButton.waitUntil(.visible).isVisible)
            XCTAssertTrue(saveButton.waitUntil(.visible).isDisabled)

            secondGPButton.hit()
            XCTAssertTrue(saveButton.waitUntil(.enabled).isEnabled)

            saveButton.hit()
        }

        XCTContext.runActivity(named: "Check if assignment list is filtered") { _ in
            XCTAssertTrue(assignment1Cell.waitUntil(.vanish).isVanished)
            XCTAssertTrue(assignment2Cell.waitUntil(.visible).isVisible)
        }
    }
}
