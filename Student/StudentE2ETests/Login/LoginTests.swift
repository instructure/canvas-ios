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

import Foundation
import TestsFoundation

class LoginTests: E2ETestCase {
    func testLoginHappyPath() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Check Start screen
        let canvasLogo = LoginHelper.Start.canvasLogo.waitToExist()
        XCTAssertTrue(canvasLogo.isVisible)

        let canvasLabel = LoginHelper.Start.canvasLabel.waitToExist()
        XCTAssertTrue(canvasLabel.isVisible)

        let findSchoolButton = LoginHelper.Start.findSchoolButton.waitToExist()
        XCTAssertTrue(findSchoolButton.isVisible)

        let lastLoginButton = LoginHelper.Start.lastLoginButton
        if lastLoginButton.isVisible {
            XCTAssertEqual(findSchoolButton.label(), "Find another school")
        } else {
            XCTAssertEqual(findSchoolButton.label(), "Find my school")
        }

        let qrCodeButton = LoginHelper.Start.qrCodeButton.waitToExist()
        XCTAssertTrue(qrCodeButton.isVisible)
        XCTAssertEqual(qrCodeButton.label(), "QR Login")

        let canvasNetworkButton = LoginHelper.Start.canvasNetworkButton.waitToExist()
        XCTAssertTrue(canvasNetworkButton.isVisible)
        XCTAssertEqual(canvasNetworkButton.label(), "Canvas Network")

        findSchoolButton.tap()

        // MARK: Check Find School screen
        let findSchoolLabel = LoginHelper.FindSchool.findSchoolLabel.waitToExist()
        XCTAssertTrue(findSchoolLabel.isVisible)
        XCTAssertEqual(findSchoolLabel.label(), "Find School")

        let findSchoolInput = LoginHelper.FindSchool.searchField.waitToExist()
        XCTAssertTrue(findSchoolInput.isVisible)
        XCTAssertEqual(findSchoolInput.label(), "School’s name")
        XCTAssertEqual(findSchoolInput.placeholderValue(), "Find your school or district")

        let nextButton = LoginHelper.nextButton.waitToVanish()
        XCTAssertFalse(nextButton.isVisible)

        findSchoolInput.pasteText(user.host)
        nextButton.waitToExist()
        XCTAssertTrue(nextButton.isVisible)

        nextButton.tap()

        // MARK: Check Login screen
        let navBar = LoginHelper.Login.navBar.waitToExist()
        XCTAssertTrue(navBar.isVisible)

        let hostLabel = LoginHelper.Login.hostLabel.waitToExist()
        XCTAssertTrue(hostLabel.isVisible)
        XCTAssertEqual(hostLabel.label(), user.host)

        let emailInput = LoginHelper.Login.emailField.waitToExist()
        XCTAssertTrue(emailInput.isVisible)
        XCTAssertEqual(emailInput.placeholderValue(), "Email")

        let passwordInput = LoginHelper.Login.passwordField.waitToExist()
        XCTAssertTrue(passwordInput.isVisible)
        XCTAssertEqual(passwordInput.placeholderValue(), "Password")

        let loginButton = LoginHelper.Login.loginButton.waitToExist()
        XCTAssertTrue(loginButton.isVisible)
        XCTAssertEqual(loginButton.label(), "Log In")

        let forgotPasswordButton = LoginHelper.Login.forgotPasswordButton.waitToExist()
        XCTAssertTrue(forgotPasswordButton.isVisible)
        XCTAssertEqual(forgotPasswordButton.label(), "Forgot Password?")

        let needAccountButton = LoginHelper.Login.needAccountButton.waitToExist()
        XCTAssertTrue(needAccountButton.isVisible)
        XCTAssertEqual(needAccountButton.label(), "Need a Canvas Account? Click Here, It's Free!")

        emailInput.tap().pasteText(student.login_id)
        passwordInput.tap().pasteText(student.password!)
        loginButton.tap()

        // MARK: Check if login was successful
        let courseCard = DashboardHelper.courseCard(course: course).waitToExist()
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
        let lastLoginBtn = LoginStart.lastLoginButton.waitToExist()
        XCTAssertTrue(lastLoginBtn.isVisible)
        XCTAssertEqual(lastLoginBtn.label(), user.host)

        // MARK: Get the user logged in using Last Login button
        lastLoginBtn.tap()
        loginAfterSchoolFound(student)

        // MARK: Check if login was successful
        let courseCard = DashboardHelper.courseCard(course: course).waitToExist()
        XCTAssertTrue(courseCard.isVisible)
    }

    func testForgotPassword() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Start login process
        findSchool()
        let navBar = LoginHelper.Login.navBar.waitToExist()
        XCTAssertTrue(navBar.isVisible)

        let forgotPasswordButton = LoginHelper.Login.forgotPasswordButton.waitToExist()
        XCTAssertTrue(forgotPasswordButton.isVisible)
        XCTAssertEqual(forgotPasswordButton.label(), "Forgot Password?")

        // MARK: Tap "Forgot Password" button
        forgotPasswordButton.tap()
        let emailInput = LoginHelper.Login.emailField.waitToExist()
        XCTAssertTrue(emailInput.isVisible)

        let requestPasswordButton = LoginHelper.Login.loginButton.waitToExist()
        XCTAssertTrue(requestPasswordButton.isVisible)
        XCTAssertEqual(requestPasswordButton.label(), "Request Password")

        let backToLoginButton = LoginHelper.Login.forgotPasswordButton.waitToExist()
        XCTAssertTrue(backToLoginButton.isVisible)
        XCTAssertEqual(backToLoginButton.label(), "Back to Login")
    }

    func testLoginWithoutUsernameAndPassword() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Start login process
        findSchool()
        let navBar = LoginHelper.Login.navBar.waitToExist()
        XCTAssertTrue(navBar.isVisible)

        let loginButton = LoginHelper.Login.loginButton.waitToExist()
        XCTAssertTrue(loginButton.isVisible)

        loginButton.tap()

        // MARK: Check "No password was given" label
        let noPasswordLabel = LoginHelper.Login.noPasswordLabel.waitToExist()
        XCTAssertTrue(noPasswordLabel.isVisible)

        let emailInput = LoginHelper.Login.emailField.waitToExist()
        XCTAssertTrue(emailInput.isVisible)

        emailInput.tap().pasteText(student.login_id)
        loginButton.tap()

        noPasswordLabel.waitToExist()
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

        var courseCard = DashboardHelper.courseCard(course: course).waitToExist()
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Change user
        let profileButton = DashboardHelper.profileButton.waitToExist()
        XCTAssertTrue(profileButton.isVisible)

        profileButton.tap()

        let changeUserButton = ProfileHelper.changeUserButton.waitToExist()
        XCTAssertTrue(changeUserButton.isVisible)

        changeUserButton.tap()

        // MARK: Check visibility of "Previous Login" cell
        let previousLoginCell = LoginHelper.Start.previousLoginCell(dsUser: student1).waitToExist()
        XCTAssertTrue(previousLoginCell.isVisible)

        // MARK: Get the second user logged in
        logInDSUser(student2)

        courseCard = DashboardHelper.courseCard(course: course).waitToExist()
        XCTAssertTrue(courseCard.isVisible)
    }

    func testWrongUsernameAndPassword() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Start login process
        findSchool()
        let navBar = LoginHelper.Login.navBar.waitToExist()
        XCTAssertTrue(navBar.isVisible)

        let emailInput = LoginHelper.Login.emailField.waitToExist()
        XCTAssertTrue(emailInput.isVisible)

        let passwordInput = LoginHelper.Login.passwordField.waitToExist()
        XCTAssertTrue(passwordInput.isVisible)

        let loginButton = LoginHelper.Login.loginButton.waitToExist()
        XCTAssertTrue(loginButton.isVisible)

        // MARK: Wrong username and password
        emailInput.tap().pasteText("wrong email")
        passwordInput.tap().pasteText("wrong password")

        loginButton.tap()

        var invalidUsernameOrPasswordLabel = LoginHelper.Start.invalidUsernameOrPasswordLabel.waitToExist()
        XCTAssertTrue(invalidUsernameOrPasswordLabel.isVisible)

        // MARK: Correct username with wrong password
        emailInput.tap().pasteText(student.login_id)
        passwordInput.tap().pasteText("wrong password")
        loginButton.tap()

        invalidUsernameOrPasswordLabel = LoginHelper.Start.invalidUsernameOrPasswordLabel.waitToExist()
        XCTAssertTrue(invalidUsernameOrPasswordLabel.isVisible)

        // MARK: Check that the user didn't get logged in
        let courseCard = DashboardHelper.courseCard(course: course).waitToVanish()
        XCTAssertFalse(courseCard.isVisible)
    }
}
