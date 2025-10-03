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

class LoginTests: E2ETestCase {
    func testLoginHappyPath() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Check Start screen
        let canvasLogo = LoginHelper.Start.canvasLogo.waitUntil(.visible)
        XCTAssertVisible(canvasLogo)

        let canvasLabel = LoginHelper.Start.canvasLabel.waitUntil(.visible)
        XCTAssertVisible(canvasLabel)

        let findSchoolButton = LoginHelper.Start.findSchoolButton.waitUntil(.visible)
        XCTAssertVisible(findSchoolButton)

        let lastLoginButton = LoginHelper.Start.lastLoginButton
        if lastLoginButton.isVisible {
            XCTAssertEqual(findSchoolButton.label, "Find another school")
        } else {
            XCTAssertEqual(findSchoolButton.label, "Find my school")
        }

        let qrCodeButton = LoginHelper.Start.qrCodeButton.waitUntil(.visible)
        XCTAssertVisible(qrCodeButton)
        XCTAssertEqual(qrCodeButton.label, "QR Login")

        let canvasNetworkButton = LoginHelper.Start.canvasNetworkButton.waitUntil(.visible)
        XCTAssertVisible(canvasNetworkButton)
        XCTAssertEqual(canvasNetworkButton.label, "Canvas Network")

        findSchoolButton.hit()

        // MARK: Check Find School screen
        let findSchoolLabel = LoginHelper.FindSchool.findSchoolLabel.waitUntil(.visible)
        XCTAssertVisible(findSchoolLabel)
        XCTAssertEqual(findSchoolLabel.label, "Find School")

        let findSchoolInput = LoginHelper.FindSchool.searchField.waitUntil(.visible)
        XCTAssertVisible(findSchoolInput)
        XCTAssertEqual(findSchoolInput.label, "School’s name")
        XCTAssertEqual(findSchoolInput.placeholderValue, "Find your school or district")

        let nextButton = LoginHelper.nextButton.waitUntil(.vanish)
        XCTAssertTrue(nextButton.isVanished)

        findSchoolInput.pasteText(text: user.host)
        nextButton.waitUntil(.visible)
        XCTAssertVisible(nextButton)

        nextButton.hit()

        // MARK: Check Login screen
        let navBar = LoginHelper.Login.navBar.waitUntil(.visible)
        XCTAssertVisible(navBar)

        let hostLabel = LoginHelper.Login.hostLabel.waitUntil(.visible)
        XCTAssertVisible(hostLabel)
        XCTAssertEqual(hostLabel.label, user.host)

        let emailInput = LoginHelper.Login.emailField.waitUntil(.visible)
        XCTAssertVisible(emailInput)
        XCTAssertEqual(emailInput.placeholderValue, "Email")

        let passwordInput = LoginHelper.Login.passwordField.waitUntil(.visible)
        XCTAssertVisible(passwordInput)
        XCTAssertEqual(passwordInput.placeholderValue, "Password")

        let loginButton = LoginHelper.Login.loginButton.waitUntil(.visible)
        XCTAssertVisible(loginButton)
        XCTAssertEqual(loginButton.label, "Log In")

        let forgotPasswordButton = LoginHelper.Login.forgotPasswordButton.waitUntil(.visible)
        XCTAssertVisible(forgotPasswordButton)
        XCTAssertEqual(forgotPasswordButton.label, "Forgot Password?")

        let needAccountButton = LoginHelper.Login.needAccountButton.waitUntil(.visible)
        XCTAssertVisible(needAccountButton)
        XCTAssertEqual(needAccountButton.label, "Need a Canvas Account? Click Here, It's Free!")

        emailInput.writeText(text: student.login_id!)
        passwordInput.writeText(text: student.password!)
        loginButton.hit()

        // MARK: Check if login was successful
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)
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
        let lastLoginBtn = LoginHelper.Start.lastLoginButton.waitUntil(.visible)
        XCTAssertVisible(lastLoginBtn)
        XCTAssertEqual(lastLoginBtn.label, user.host)

        // MARK: Get the user logged in using Last Login button
        lastLoginBtn.hit()
        loginAfterSchoolFound(student)

        // MARK: Check if login was successful
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)
    }

    func testForgotPassword() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Start login process
        findSchool()
        let navBar = LoginHelper.Login.navBar.waitUntil(.visible)
        XCTAssertVisible(navBar)

        let forgotPasswordButton = LoginHelper.Login.forgotPasswordButton.waitUntil(.visible)
        XCTAssertVisible(forgotPasswordButton)
        XCTAssertEqual(forgotPasswordButton.label, "Forgot Password?")

        // MARK: Tap "Forgot Password" button
        forgotPasswordButton.hit()
        let emailInput = LoginHelper.Login.emailField.waitUntil(.visible)
        XCTAssertVisible(emailInput)

        let requestPasswordButton = LoginHelper.Login.requestPasswordButton.waitUntil(.visible)
        XCTAssertVisible(requestPasswordButton)
        XCTAssertEqual(requestPasswordButton.label, "Request Password")

        let backToLoginButton = LoginHelper.Login.backToLoginButton.waitUntil(.visible)
        XCTAssertVisible(backToLoginButton)
        XCTAssertEqual(backToLoginButton.label, "Back to Login")
    }

    func testLoginWithoutUsernameAndPassword() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Start login process
        findSchool()
        let navBar = LoginHelper.Login.navBar.waitUntil(.visible)
        XCTAssertVisible(navBar)

        let loginButton = LoginHelper.Login.loginButton.waitUntil(.visible)
        XCTAssertVisible(loginButton)

        loginButton.hit()

        // MARK: Check "No password was given" label
        let noPasswordLabel = LoginHelper.Login.noPasswordLabel.waitUntil(.visible)
        XCTAssertVisible(noPasswordLabel)

        let emailInput = LoginHelper.Login.emailField.waitUntil(.visible)
        XCTAssertVisible(emailInput)

        emailInput.writeText(text: student.login_id!)
        loginButton.hit()

        noPasswordLabel.waitUntil(.visible)
        XCTAssertVisible(noPasswordLabel)
    }

    func testLoginMultipleUsers() {
        // MARK: Seed the usual stuff
        let student1 = seeder.createUser()
        let student2 = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudents([student1, student2], in: course)

        // MARK: Get the first user logged in
        logInDSUser(student1)

        var courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)

        // MARK: Change user
        let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
        XCTAssertVisible(profileButton)

        profileButton.hit()

        let changeUserButton = ProfileHelper.changeUserButton.waitUntil(.visible)
        XCTAssertVisible(changeUserButton)

        changeUserButton.hit()
        XCTAssertTrue(LoginHelper.Start.findSchoolButton.waitUntil(.visible).isVisible)

        // MARK: Check visibility of "Previous Login" cell
        let previousLoginCell = LoginHelper.Start.previousLoginCell(dsUser: student1).waitUntil(.visible)
        XCTAssertVisible(previousLoginCell)

        // MARK: Get the second user logged in
        logInDSUser(student2)

        courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)
    }

    func testWrongUsernameAndPassword() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Start login process
        findSchool()
        let navBar = LoginHelper.Login.navBar.waitUntil(.visible)
        XCTAssertVisible(navBar)

        let emailInput = LoginHelper.Login.emailField.waitUntil(.visible)
        XCTAssertVisible(emailInput)

        let passwordInput = LoginHelper.Login.passwordField.waitUntil(.visible)
        XCTAssertVisible(passwordInput)

        let loginButton = LoginHelper.Login.loginButton.waitUntil(.visible)
        XCTAssertVisible(loginButton)

        // MARK: Wrong username and password
        emailInput.writeText(text: "wrong email")
        passwordInput.writeText(text: "wrong password")

        loginButton.hit()

        var invalidUsernameOrPasswordLabel = LoginHelper.Start.invalidUsernameOrPasswordLabel.waitUntil(.visible)
        XCTAssertVisible(invalidUsernameOrPasswordLabel)

        // MARK: Correct username with wrong password
        emailInput.cutText()
        emailInput.writeText(text: student.login_id!)
        passwordInput.writeText(text: "wrong password")
        loginButton.hit()

        invalidUsernameOrPasswordLabel = LoginHelper.Start.invalidUsernameOrPasswordLabel.waitUntil(.visible)
        XCTAssertVisible(invalidUsernameOrPasswordLabel)

        // MARK: Check that the user didn't get logged in
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.vanish)
        XCTAssertTrue(courseCard.isVanished)
    }
}
