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

    static func previousUser(studentNumber: String) -> Element {
        return app.find(label: "Student \(studentNumber)")
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

enum Dashboard {
    static var courses: Element {
        return app.find(label: "Courses")
    }

    static func courseCard(id: String) -> Element {
        return app.find(id: "course-\(id)")
    }

    static var dashboardTab: Element {
        return app.find(label: "Dashboard")
    }

    static var dashboardList: Element {
        return app.find(id: "favorited-course-list.profile-btn")
    }

    static var changeUser: Element {
        return app.find(label: "Change User")
    }
}

class LoginTests: CanvasUITests {

    func testFindSchool() {
        // Find my school
        LoginStart.findMySchool.tap()
        LoginFindSchool.searchField.typeText("mtech")
        XCTAssert(LoginFindSchool.resultItem(for: "MTECH").exists)
    }

    func testCanvasLoginToDashboard() {
       loginUser(username: "student1", password: "password")

        // Dashboard
        XCTAssert(Dashboard.courses.exists)
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
        CanvasLogin.emailTextField.typeText("ldapmobiletest")

        // Password
        CanvasLogin.passwordTextField.typeText("mobiletesting123")

        // Submit
        CanvasLogin.logInButton.tap()

        XCTAssert(Dashboard.courses.exists)
        XCTAssert(Dashboard.dashboardTab.exists)
    }

    func testMultipleUsers() {
        loginUser(username: "student1", password: "password")

        // Change User
        Dashboard.dashboardList.tap()
        Dashboard.changeUser.tap()

        loginUser(username: "student2", password: "password")

        // Change User
        Dashboard.dashboardList.tap()
        Dashboard.changeUser.tap()

        // Previous Users
        XCTAssert(LoginStart.previousUser(studentNumber: "One").exists)
        XCTAssert(LoginStart.previousUser(studentNumber: "Two").exists)
    }

    func loginUser(username: String, password: String) {
        // Find my school
        XCTAssert(LoginStart.findMySchool.exists)
        LoginStart.findMySchool.tap()
        LoginFindSchool.searchField.typeText("iosauto\r")

        // Email
        CanvasLogin.emailTextField.typeText(username)

        // Password
        CanvasLogin.passwordTextField.typeText(password)

        // Submit
        CanvasLogin.logInButton.tap()
    }
}
