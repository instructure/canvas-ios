//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import XCTest
import SwiftUITest

class LoginTests: XCTestCase {
    func testLoginToDashboard() {
        let app = XCUIApplication()
        app.launch()
        let driver = DriverFactory.getXCUITestDriver(app, testCase: self)

        // Find my school
        let button = driver.find(label: "Find my school")
        XCTAssert(button.exists)
        button.tap()
        let textField = driver.find(id: "LoginFindSchool.searchField")
        textField.typeText("iosauto\r")

        // Email
        let email = app.webViews.textFields["Email"]
        XCTAssert(email.waitForExistence(timeout: 10))
        XCTAssert(email.isHittable)
        email.tap()
        email.typeText("student1")

        // Password
        let password = app.webViews.secureTextFields["Password"]
        XCTAssert(password.waitForExistence(timeout: 10))
        XCTAssert(password.isHittable)
        password.tap()
        password.typeText("password")

        // Submit
        let submit = app.webViews.buttons["Log In"]
        submit.tap()

        // Dashboard
        XCTAssert(driver.find(label: "Courses").exists)
        XCTAssert(driver.find(id: "course-247").exists)
        XCTAssert(driver.find(label: "Login ").exists)
        XCTAssert(driver.find(label: "Dashboard").exists)
    }
}
