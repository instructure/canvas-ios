//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import XCTest
import TestsFoundation

class ActAsUserTest: E2ETestCase {
    func testActAsUser() {
        let testAdmin = UITestUser.readAdmin1
        let testStudent = seeder.createUser()
        let testCourse = seeder.createCourse()
        seeder.enrollStudent(testStudent, in: testCourse)
        logInUser(testAdmin)

        // Opening profile page
        Profile.open()

        // Check if username on UI is correct
        XCTAssertEqual(Profile.userNameLabel.label(),
                       "Admin One", "Incorrect username")

        // Check if Act-As-User button is visible
        XCTAssertTrue(Profile.actAsUserButton.waitToExist().isVisible,
                      "Act-As-User button is not visible")

        // Tap Act-As-User button
        Profile.actAsUserButton.tap()

        // Check if user ID input field is visible
        XCTAssertTrue(ActAsUser.userIDField.waitToExist().isVisible,
                      "User ID field is not visible")

        // Type user ID to input field
        ActAsUser.userIDField.typeText(testStudent.id).swipeUp()

        // Type user host to input field if existing value is incorrect
        if ActAsUser.domainField.value() != "https://\(user.host)" {
            ActAsUser.domainField.cutText()
            ActAsUser.domainField.typeText("https://\(user.host)")
        }

        // Check if Act-As-User button is visible
        XCTAssertTrue(ActAsUser.actAsUserButton.waitToExist().isVisible,
                      "Act-As-User button is not visible")

        // Tap Act-As-User button
        ActAsUser.actAsUserButton.tap()

        // Open profile page
        Profile.open()

        // Check if username on UI is correct
        XCTAssertEqual(Profile.userNameLabel.label(), testStudent.name,
                       "Incorrect username")

        // Close profile page
        Profile.close()

        // Check if End-Act-As-User button is visible
        XCTAssertTrue(ActAsUser.endActAsUserButton.waitToExist().isVisible,
                      "End-Act-As-User button is not visible")

        // Tap End-Act-As-User button
        ActAsUser.endActAsUserButton.tap()

        // Check if OK button of the alert is visible
        XCTAssertTrue(app.alerts.buttons["OK"].waitForExistence(timeout: 10),
                      "OK button of the alert is not visible")

        // Tap OK button of the alert
        app.alerts.buttons["OK"].tap()

        // Wait for End-Act-As-User button to vanish
        ActAsUser.endActAsUserButton.waitToVanish()

        // Check if End-Act-As-User button is not visible
        XCTAssertFalse(ActAsUser.endActAsUserButton.isVisible,
                       "End-Act-As-User button is still visible")

        // Open profile page
        Profile.open()

        // Check if username on UI is correct
        XCTAssertEqual(Profile.userNameLabel.label(), testAdmin.username,
                       "Incorrect username")

        // Close profile page
        Profile.close()
    }
}
