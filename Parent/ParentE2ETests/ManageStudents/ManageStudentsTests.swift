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

class ManageStudentsTests: E2ETestCase {
    func testManageStudents() {
        // MARK: Seed the usual stuff
        let student1 = seeder.createUser()
        let student2 = seeder.createUser()
        let parent = seeder.createUser()
        let course = seeder.createCourse()
        let subject = "Sample Subject of \(parent.name)"
        let message = "Sample Message of \(parent.name)"
        seeder.enrollStudent(student1, in: course)
        seeder.enrollStudent(student2, in: course)
        seeder.enrollParent(parent, in: course)
        seeder.addObservee(parent: parent, student: student1)
        seeder.addObservee(parent: parent, student: student2)

        // MARK: Get the user logged in, navigate to Manage Students
        logInDSUser(parent)
        let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
        XCTAssertTrue(profileButton.isVisible)

        profileButton.hit()
        let manageStudentsButton = ProfileHelper.manageStudentsButton.waitUntil(.visible)
        XCTAssertTrue(manageStudentsButton.isVisible)

        // MARK: Check students
        manageStudentsButton.hit()
        let student1cell = ManageStudentsHelper.studentCell(student: student1)!.waitUntil(.visible)
        let student2cell = ManageStudentsHelper.studentCell(student: student2)!.waitUntil(.visible)
        XCTAssertTrue(student1cell.isVisible)
        XCTAssertTrue(student2cell.isVisible)

        // MARK: Check detail screen
        student1cell.hit()
        let backButton = ManageStudentsHelper.Details.backButton.waitUntil(.visible)
        let courseGradeAbove = ManageStudentsHelper.Details.courseGradeAbove.waitUntil(.visible)
        let courseGradeBelow = ManageStudentsHelper.Details.courseGradeBelow.waitUntil(.visible)
        let assignmentMissing = ManageStudentsHelper.Details.assignmentMissing.waitUntil(.visible)
        let assignmentGradeAbove = ManageStudentsHelper.Details.assignmentGradeAbove.waitUntil(.visible)
        let assignmentGradeBelow = ManageStudentsHelper.Details.assignmentGradeBelow.waitUntil(.visible)
        let courseAnnouncements = ManageStudentsHelper.Details.courseAnnouncements.waitUntil(.visible)
        let institutionAnnouncements = ManageStudentsHelper.Details.institutionAnnouncements.waitUntil(.visible)
        XCTAssertTrue(backButton.isVisible)
        XCTAssertTrue(courseGradeAbove.isVisible)
        XCTAssertTrue(courseGradeBelow.isVisible)
        XCTAssertTrue(assignmentMissing.isVisible)
        XCTAssertTrue(assignmentGradeAbove.isVisible)
        XCTAssertTrue(assignmentGradeBelow.isVisible)
        XCTAssertTrue(courseAnnouncements.isVisible)
        XCTAssertTrue(institutionAnnouncements.isVisible)

        courseGradeAbove.writeText(text: "80")
        courseGradeBelow.writeText(text: "20")
        assignmentMissing.hit()
        assignmentGradeAbove.writeText(text: "80")
        assignmentGradeBelow.writeText(text: "20")
        courseAnnouncements.hit()
        institutionAnnouncements.hit()
        XCTAssertTrue(courseGradeAbove.waitUntil(.value(expected: "80")).hasValue(value: "80"))
        XCTAssertTrue(courseGradeBelow.waitUntil(.value(expected: "20")).hasValue(value: "20"))
        XCTAssertTrue(assignmentMissing.waitUntil(.value(expected: "1")).hasValue(value: "1"))
        XCTAssertTrue(assignmentGradeAbove.waitUntil(.value(expected: "80")).hasValue(value: "80"))
        XCTAssertTrue(assignmentGradeBelow.waitUntil(.value(expected: "20")).hasValue(value: "20"))
        XCTAssertTrue(courseAnnouncements.waitUntil(.value(expected: "1")).hasValue(value: "1"))
        XCTAssertTrue(institutionAnnouncements.waitUntil(.value(expected: "1")).hasValue(value: "1"))

        // MARK: Go back, then open details and check if the new values got saved
        backButton.hit()
        student1cell.hit()
        XCTAssertTrue(courseGradeAbove.waitUntil(.visible).hasValue(value: "80"))
        XCTAssertTrue(courseGradeBelow.waitUntil(.visible).hasValue(value: "20"))
        XCTAssertTrue(assignmentMissing.waitUntil(.visible).hasValue(value: "1"))
        XCTAssertTrue(assignmentGradeAbove.waitUntil(.visible).hasValue(value: "80"))
        XCTAssertTrue(assignmentGradeBelow.waitUntil(.visible).hasValue(value: "20"))
        XCTAssertTrue(courseAnnouncements.waitUntil(.visible).hasValue(value: "1"))
        XCTAssertTrue(institutionAnnouncements.waitUntil(.visible).hasValue(value: "1"))
    }
}
