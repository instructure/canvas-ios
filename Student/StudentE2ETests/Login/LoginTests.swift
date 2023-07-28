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

class LoginTests: E2ETestCase {
    func testLoginHappyPath() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Check Start screen
        let canvasLogo = LoginHelper.Start.canvasLogo.waitUntil(condition: .visible)
        XCTAssertTrue(canvasLogo.isVisible)

        let canvasLabel = LoginHelper.Start.canvasLabel.waitUntil(condition: .visible)
        XCTAssertTrue(canvasLabel.isVisible)

        let findSchoolButton = LoginHelper.Start.findSchoolButton.waitUntil(condition: .visible)
        XCTAssertTrue(findSchoolButton.isVisible)

        let lastLoginButton = LoginHelper.Start.lastLoginButton
        if lastLoginButton.isVisible {
            XCTAssertEqual(findSchoolButton.label, "Find another school")
        } else {
            XCTAssertEqual(findSchoolButton.label, "Find my school")
        }

        let qrCodeButton = LoginHelper.Start.qrCodeButton.waitUntil(condition: .visible)
        XCTAssertTrue(qrCodeButton.isVisible)
        XCTAssertEqual(qrCodeButton.label, "QR Login")

        let canvasNetworkButton = LoginHelper.Start.canvasNetworkButton.waitUntil(condition: .visible)
        XCTAssertTrue(canvasNetworkButton.isVisible)
        XCTAssertEqual(canvasNetworkButton.label, "Canvas Network")

        findSchoolButton.tap()

        // MARK: Check Find School screen
        let findSchoolLabel = LoginHelper.FindSchool.findSchoolLabel.waitUntil(condition: .visible)
        XCTAssertTrue(findSchoolLabel.isVisible)
        XCTAssertEqual(findSchoolLabel.label, "Find School")

        let findSchoolInput = LoginHelper.FindSchool.searchField.waitUntil(condition: .visible)
        XCTAssertTrue(findSchoolInput.isVisible)
        XCTAssertEqual(findSchoolInput.label, "School’s name")
        XCTAssertEqual(findSchoolInput.placeholderValue, "Find your school or district")

        let nextButton = LoginHelper.nextButton.waitUntil(condition: .vanish)
        XCTAssertFalse(nextButton.isVisible)

        findSchoolInput.pasteText(text: user.host)
        nextButton.waitUntil(condition: .visible)
        XCTAssertTrue(nextButton.isVisible)

        nextButton.tap()

        // MARK: Check Login screen
        let navBar = LoginHelper.Login.navBar.waitUntil(condition: .visible)
        XCTAssertTrue(navBar.isVisible)

        let hostLabel = LoginHelper.Login.hostLabel.waitUntil(condition: .visible)
        XCTAssertTrue(hostLabel.isVisible)
        XCTAssertEqual(hostLabel.label, user.host)

        let emailInput = LoginHelper.Login.emailField.waitUntil(condition: .visible)
        XCTAssertTrue(emailInput.isVisible)
        XCTAssertEqual(emailInput.placeholderValue, "Email")

        let passwordInput = LoginHelper.Login.passwordField.waitUntil(condition: .visible)
        XCTAssertTrue(passwordInput.isVisible)
        XCTAssertEqual(passwordInput.placeholderValue, "Password")

        let loginButton = LoginHelper.Login.loginButton.waitUntil(condition: .visible)
        XCTAssertTrue(loginButton.isVisible)
        XCTAssertEqual(loginButton.label, "Log In")

        let forgotPasswordButton = LoginHelper.Login.forgotPasswordButton.waitUntil(condition: .visible)
        XCTAssertTrue(forgotPasswordButton.isVisible)
        XCTAssertEqual(forgotPasswordButton.label, "Forgot Password?")

        let needAccountButton = LoginHelper.Login.needAccountButton.waitUntil(condition: .visible)
        XCTAssertTrue(needAccountButton.isVisible)
        XCTAssertEqual(needAccountButton.label, "Need a Canvas Account? Click Here, It's Free!")

        emailInput.tap()
        emailInput.pasteText(text: student.login_id)
        passwordInput.tap()
        emailInput.pasteText(text: student.password!)
        loginButton.tap()

        // MARK: Check if login was successful
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(condition: .visible)
        XCTAssertTrue(courseCard.isVisible)
    }

    // Follow-up of MBL-14653
    func testLoginWithLastUser() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in and logged out
        logInDSUser(student, lastLogin: false)

        logOut()

        // MARK: Check visibility and content of Last Login button
        let lastLoginBtn = LoginHelper.Start.lastLoginButton.waitUntil(condition: .visible)
        XCTAssertTrue(lastLoginBtn.isVisible)
        XCTAssertEqual(lastLoginBtn.label, user.host)

        // MARK: Get the user logged in using Last Login button
        lastLoginBtn.tap()
        loginAfterSchoolFound(student)

        // MARK: Check if login was successful
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(condition: .visible)
        XCTAssertTrue(courseCard.isVisible)
    }

    func testForgotPassword() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Start login process
        findSchool()
        let navBar = LoginHelper.Login.navBar.waitUntil(condition: .visible)
        XCTAssertTrue(navBar.isVisible)

        let forgotPasswordButton = LoginHelper.Login.forgotPasswordButton.waitUntil(condition: .visible)
        XCTAssertTrue(forgotPasswordButton.isVisible)
        XCTAssertEqual(forgotPasswordButton.label, "Forgot Password?")

        // MARK: Tap "Forgot Password" button
        forgotPasswordButton.tap()
        let emailInput = LoginHelper.Login.emailField.waitUntil(condition: .visible)
        XCTAssertTrue(emailInput.isVisible)

        let requestPasswordButton = LoginHelper.Login.loginButton.waitUntil(condition: .visible)
        XCTAssertTrue(requestPasswordButton.isVisible)
        XCTAssertEqual(requestPasswordButton.label, "Request Password")

        let backToLoginButton = LoginHelper.Login.forgotPasswordButton.waitUntil(condition: .visible)
        XCTAssertTrue(backToLoginButton.isVisible)
        XCTAssertEqual(backToLoginButton.label, "Back to Login")
    }

    func testLoginWithoutUsernameAndPassword() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Start login process
        findSchool()
        let navBar = LoginHelper.Login.navBar.waitUntil(condition: .visible)
        XCTAssertTrue(navBar.isVisible)

        let loginButton = LoginHelper.Login.loginButton.waitUntil(condition: .visible)
        XCTAssertTrue(loginButton.isVisible)

        loginButton.tap()

        // MARK: Check "No password was given" label
        let noPasswordLabel = LoginHelper.Login.noPasswordLabel.waitUntil(condition: .visible)
        XCTAssertTrue(noPasswordLabel.isVisible)

        let emailInput = LoginHelper.Login.emailField.waitUntil(condition: .visible)
        XCTAssertTrue(emailInput.isVisible)

        emailInput.tap()
        emailInput.pasteText(text: student.login_id)
        loginButton.tap()

        noPasswordLabel.waitUntil(condition: .visible)
        XCTAssertTrue(noPasswordLabel.isVisible)
    }

    func testLoginMultipleUsers() {
        // MARK: Seed the usual stuff
        let student1 = seeder.createUser()
        let student2 = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudents([student1, student2], in: course)

        // MARK: Get the first user logged in
        logInDSUser(student1)

        var courseCard = DashboardHelper.courseCard(course: course).waitUntil(condition: .visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Change user
        let profileButton = DashboardHelper.profileButton.waitUntil(condition: .visible)
        XCTAssertTrue(profileButton.isVisible)

        profileButton.tap()

        let changeUserButton = ProfileHelper.changeUserButton.waitUntil(condition: .visible)
        XCTAssertTrue(changeUserButton.isVisible)

        changeUserButton.tap()

        // MARK: Check visibility of "Previous Login" cell
        let previousLoginCell = LoginHelper.Start.previousLoginCell(dsUser: student1).waitUntil(condition: .visible)
        XCTAssertTrue(previousLoginCell.isVisible)

        // MARK: Get the second user logged in
        logInDSUser(student2)

        courseCard = DashboardHelper.courseCard(course: course).waitUntil(condition: .visible)
        XCTAssertTrue(courseCard.isVisible)
    }

    func testWrongUsernameAndPassword() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Start login process
        findSchool()
        let navBar = LoginHelper.Login.navBar.waitUntil(condition: .visible)
        XCTAssertTrue(navBar.isVisible)

        let emailInput = LoginHelper.Login.emailField.waitUntil(condition: .visible)
        XCTAssertTrue(emailInput.isVisible)

        let passwordInput = LoginHelper.Login.passwordField.waitUntil(condition: .visible)
        XCTAssertTrue(passwordInput.isVisible)

        let loginButton = LoginHelper.Login.loginButton.waitUntil(condition: .visible)
        XCTAssertTrue(loginButton.isVisible)

        // MARK: Wrong username and password
        emailInput.tap()
        emailInput.pasteText(text: "wrong email")
        passwordInput.tap()
        passwordInput.pasteText(text: "wrong password")

        loginButton.tap()

        var invalidUsernameOrPasswordLabel = LoginHelper.Start.invalidUsernameOrPasswordLabel.waitUntil(condition: .visible)
        XCTAssertTrue(invalidUsernameOrPasswordLabel.isVisible)

        // MARK: Correct username with wrong password
        emailInput.tap()
        emailInput.pasteText(text: student.login_id)
        passwordInput.tap()
        passwordInput.pasteText(text: "wrong password")
        loginButton.tap()

        invalidUsernameOrPasswordLabel = LoginHelper.Start.invalidUsernameOrPasswordLabel.waitUntil(condition: .visible)
        XCTAssertTrue(invalidUsernameOrPasswordLabel.isVisible)

        // MARK: Check that the user didn't get logged in
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(condition: .vanish)
        XCTAssertFalse(courseCard.isVisible)
    }
}
