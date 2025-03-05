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
        let highPercent = "80"
        let lowPercent = "20"
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

        courseGradeAbove.writeText(text: highPercent)
        courseGradeBelow.writeText(text: lowPercent)
        assignmentMissing.hit()
        assignmentGradeAbove.writeText(text: highPercent)
        assignmentGradeBelow.writeText(text: lowPercent)
        courseAnnouncements.hit()
        institutionAnnouncements.hit()
        XCTAssertTrue(courseGradeAbove.waitUntil(.value(expected: highPercent)).hasValue(value: highPercent))
        XCTAssertTrue(courseGradeBelow.waitUntil(.value(expected: lowPercent)).hasValue(value: lowPercent))
        XCTAssertTrue(assignmentMissing.waitUntil(.value(expected: "on")).hasValue(value: "on"))
        XCTAssertTrue(assignmentGradeAbove.waitUntil(.value(expected: highPercent)).hasValue(value: highPercent))
        XCTAssertTrue(assignmentGradeBelow.waitUntil(.value(expected: lowPercent)).hasValue(value: lowPercent))
        XCTAssertTrue(courseAnnouncements.waitUntil(.value(expected: "on")).hasValue(value: "on"))
        XCTAssertTrue(institutionAnnouncements.waitUntil(.value(expected: "on")).hasValue(value: "on"))

        // MARK: Go back, then open details and check if the new values got saved
        backButton.hit()
        student1cell.hit()
        XCTAssertTrue(courseGradeAbove.waitUntil(.visible).hasValue(value: highPercent))
        XCTAssertTrue(courseGradeBelow.waitUntil(.visible).hasValue(value: lowPercent))
        XCTAssertTrue(assignmentMissing.waitUntil(.visible).hasValue(value: "on"))
        XCTAssertTrue(assignmentGradeAbove.waitUntil(.visible).hasValue(value: highPercent))
        XCTAssertTrue(assignmentGradeBelow.waitUntil(.visible).hasValue(value: lowPercent))
        XCTAssertTrue(courseAnnouncements.waitUntil(.visible).hasValue(value: "on"))
        XCTAssertTrue(institutionAnnouncements.waitUntil(.visible).hasValue(value: "on"))
    }
}
