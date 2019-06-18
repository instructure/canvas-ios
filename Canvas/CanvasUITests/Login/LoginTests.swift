//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
import TestsFoundation

enum LoginStart {
    static var findMySchool: Element {
        return app.find(label: "Find my school")
    }

    static func previousUser(name: String) -> Element {
        return app.find(label: name)
    }
}

enum LoginFindSchool: String, ElementWrapper {
    case searchField

    static func resultItem(for name: String) -> Element {
        return app.find(label: name)
    }
}

enum CanvasLogin {
    static var emailTextField: Element {
        return XCUIElementWrapper(app.webViews.textFields["Email"])
    }

    static var passwordTextField: Element {
        return XCUIElementWrapper(app.webViews.secureTextFields["Password"])
    }

    static var logInButton: Element {
        return XCUIElementWrapper(app.webViews.buttons["Log In"])
    }
}

enum RyanaLogin {
    static var ldapButton: Element {
        return XCUIElementWrapper(app.webViews.staticTexts["LDAP"])
    }
}

class LoginTests: CanvasUITests {

    func testFindSchool() {
        // Find my school
        LoginStart.findMySchool.tap()
        LoginFindSchool.searchField.typeText("mtech")
        LoginFindSchool.resultItem(for: "MTECH").waitToExist()
    }

    func testCanvasLoginToDashboard() {
       loginUser(username: "student1", password: "password")

        // Dashboard
        Dashboard.coursesLabel.waitToExist(30)
        XCTAssert(Dashboard.coursesLabel.exists)
        XCTAssert(Dashboard.courseCard(id: "247").exists)
        XCTAssert(Dashboard.dashboardTab.exists)
    }

    func testLDAPLoginToDashboard() {
        // Find my school
        XCTAssert(LoginStart.findMySchool.exists)
        LoginStart.findMySchool.tap()
        LoginFindSchool.searchField.typeText("ryana\r")

        // Ryana Web View
        RyanaLogin.ldapButton.waitToExist()
        RyanaLogin.ldapButton.tap()

        // Email
        CanvasLogin.emailTextField.waitToExist()
        CanvasLogin.emailTextField.tap()
        CanvasLogin.emailTextField.typeText("ldapmobiletest")

        // Password
        CanvasLogin.passwordTextField.typeText("mobiletesting123")

        // Submit
        CanvasLogin.logInButton.tap()

        Dashboard.coursesLabel.waitToExist()
        XCTAssert(Dashboard.dashboardTab.exists)
    }

    func testMultipleUsers() {
        loginUser(username: "student1", password: "password")

        // Change User
        Dashboard.dashboardList.waitToExist(30)
        Dashboard.dashboardList.tap()
        Dashboard.changeUser.waitToExist()
        Dashboard.changeUser.tap()

        loginUser(username: "student2", password: "password")

        // Change User
        Dashboard.dashboardList.waitToExist(30)
        Dashboard.dashboardList.tap()
        Dashboard.changeUser.waitToExist()
        Dashboard.changeUser.tap()

        // Previous Users
        LoginStart.findMySchool.waitToExist()
        XCTAssert(LoginStart.previousUser(name: "Student One").exists)
        XCTAssert(LoginStart.previousUser(name: "Student Two").exists)
    }

    func testSessionMaintainedAfterTermination() {
        loginUser(username: "student1", password: "password")

        // Dashboard
        Dashboard.coursesLabel.waitToExist(30)
        XCTAssert(Dashboard.courseCard(id: "247").exists)
        XCTAssert(Dashboard.dashboardTab.exists)

        XCUIApplication().terminate()
        XCUIApplication().launch()

        // Dashboard
        Dashboard.coursesLabel.waitToExist()
        XCTAssert(Dashboard.courseCard(id: "247").exists)
        XCTAssert(Dashboard.dashboardTab.exists)
    }

    func loginUser(username: String, password: String) {
        // Find my school
        LoginStart.findMySchool.tap()
        LoginFindSchool.searchField.typeText("iosauto\r")

        // Email
        CanvasLogin.emailTextField.waitToExist()
        CanvasLogin.emailTextField.tap()
        CanvasLogin.emailTextField.typeText(username)

        // Password
        CanvasLogin.passwordTextField.typeText(password)

        // Submit
        CanvasLogin.logInButton.tap()
    }
}
