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

class AddStudentTests: E2ETestCase {
    func testAddStudent() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let parent = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        seeder.enrollParent(parent, in: course)
        let pairingCode = seeder.getPairingCode(student: student)

        // MARK: Get the user logged in, navigate to Manage Students
        logInDSUser(parent)
        let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
        XCTAssertVisible(profileButton)

        profileButton.hit()
        let manageStudentsButton = ProfileHelper.manageStudentsButton.waitUntil(.visible)
        XCTAssertVisible(manageStudentsButton)

        manageStudentsButton.hit()
        let addStudentButton = ManageStudentsHelper.addStudentButton.waitUntil(.visible)
        XCTAssertVisible(addStudentButton)

        // MARK: Add new student
        addStudentButton.hit()
        let qrCodeButton = ManageStudentsHelper.AddStudent.qrCodeButton.waitUntil(.visible)
        let pairingCodeButton = ManageStudentsHelper.AddStudent.pairingCodeButton.waitUntil(.visible)
        XCTAssertVisible(qrCodeButton)
        XCTAssertVisible(pairingCodeButton)

        pairingCodeButton.hit()
        let pairingCodeInput = ManageStudentsHelper.AddStudent.pairingCodeInput.waitUntil(.visible)
        let cancelButton = ManageStudentsHelper.AddStudent.cancelButton.waitUntil(.visible)
        let addButton = ManageStudentsHelper.AddStudent.addButton.waitUntil(.visible)
        XCTAssertVisible(pairingCodeInput)
        XCTAssertVisible(cancelButton)
        XCTAssertVisible(addButton)

        pairingCodeInput.writeText(text: pairingCode.code)
        addButton.hit()

        // MARK: Check if student was added
        let studentCell = ManageStudentsHelper.studentCell(student: student).waitUntil(.visible)
        let nameLabelOfStudentCell = ManageStudentsHelper.nameLabelOfStudentCell(student: student).waitUntil(.visible)
        XCTAssertVisible(studentCell)
        XCTAssertVisible(nameLabelOfStudentCell)
    }
}
