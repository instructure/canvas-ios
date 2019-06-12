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

enum LoginFindSchool: String, CaseIterable, ElementWrapper {
  case searchField
}

enum LoginStart {
    static var findMySchool: Element {
        return app.find(label: "Find my school")
    }
}

enum CanvasLogin {
    static var emailTextField: Element {
        return XCUIApplication().webViews.textFields["Email"].toElement(testCase)
    }
}

class LoginTests: CanvasUITests {
    func testLoginToDashboard() {
        // Find my school
        XCTAssert(LoginStart.findMySchool.exists)
        LoginStart.findMySchool.tap()
        LoginFindSchool.searchField.typeText("iosauto\r")

        // Email
        CanvasLogin.emailTextField.waitToExist(Timeout(value: 10))
        CanvasLogin.emailTextField.tap()
        CanvasLogin.emailTextField.typeText("student1")

        // Password
        let password = application.webViews.secureTextFields["Password"]
        XCTAssert(password.waitForExistence(timeout: 10))
        XCTAssert(password.isHittable)
        password.tap()
        password.typeText("password")

        // Submit
        let submit = application.webViews.buttons["Log In"]
        submit.tap()

        // Dashboard
        // XCTAssert(driver.find(label: "Courses").exists)
        // XCTAssert(driver.find(id: "course-247").exists)
        // XCTAssert(driver.find(label: "Login ").exists)
        // XCTAssert(driver.find(label: "Dashboard").exists)
    }
}
