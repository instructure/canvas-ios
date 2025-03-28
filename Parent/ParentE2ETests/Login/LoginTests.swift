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
        let parent = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollParent(parent, in: course)

        // MARK: Check Start screen
        let canvasLogo = LoginHelper.Start.canvasLogo.waitUntil(.visible)
        XCTAssertTrue(canvasLogo.isVisible)

        let canvasLabel = LoginHelper.Start.canvasLabel.waitUntil(.visible)
        XCTAssertTrue(canvasLabel.isVisible)

        let findSchoolButton = LoginHelper.Start.findSchoolButton.waitUntil(.visible)
        XCTAssertTrue(findSchoolButton.isVisible)

        let lastLoginButton = LoginHelper.Start.lastLoginButton
        if lastLoginButton.isVisible {
            XCTAssertTrue(findSchoolButton.hasLabel(label: "Find another school"))
        } else {
            XCTAssertTrue(findSchoolButton.hasLabel(label: "Find School"))
        }

        let qrCodeButton = LoginHelper.Start.qrCodeButton.waitUntil(.visible)
        XCTAssertTrue(qrCodeButton.isVisible)
        XCTAssertTrue(qrCodeButton.hasLabel(label: "QR Login"))

        findSchoolButton.hit()

        // MARK: Check Find School screen
        let findSchoolLabel = LoginHelper.FindSchool.findSchoolLabel.waitUntil(.visible)
        XCTAssertTrue(findSchoolLabel.isVisible)
        XCTAssertTrue(findSchoolLabel.hasLabel(label: "Find School"))

        let findSchoolInput = LoginHelper.FindSchool.searchField.waitUntil(.visible)
        XCTAssertTrue(findSchoolInput.isVisible)
        XCTAssertTrue(findSchoolInput.hasLabel(label: "School’s name"))
        XCTAssertTrue(findSchoolInput.hasPlaceholderValue(placeholderValue: "Find your school or district"))

        let nextButton = LoginHelper.nextButton.waitUntil(.vanish)
        XCTAssertTrue(nextButton.isVanished)

        findSchoolInput.pasteText(text: user.host)
        nextButton.waitUntil(.visible)
        XCTAssertTrue(nextButton.isVisible)

        nextButton.hit()

        // MARK: Check Login screen
        let navBar = LoginHelper.Login.navBar.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        let hostLabel = LoginHelper.Login.hostLabel.waitUntil(.visible)
        XCTAssertTrue(hostLabel.isVisible)
        XCTAssertTrue(hostLabel.hasLabel(label: user.host))

        let emailInput = LoginHelper.Login.emailField.waitUntil(.visible)
        XCTAssertTrue(emailInput.isVisible)
        XCTAssertTrue(emailInput.hasPlaceholderValue(placeholderValue: "Email"))

        let passwordInput = LoginHelper.Login.passwordField.waitUntil(.visible)
        XCTAssertTrue(passwordInput.isVisible)
        XCTAssertTrue(passwordInput.hasPlaceholderValue(placeholderValue: "Password"))

        let loginButton = LoginHelper.Login.loginButton.waitUntil(.visible)
        XCTAssertTrue(loginButton.isVisible)
        XCTAssertTrue(loginButton.hasLabel(label: "Log In"))

        let forgotPasswordButton = LoginHelper.Login.forgotPasswordButton.waitUntil(.visible)
        XCTAssertTrue(forgotPasswordButton.isVisible)
        XCTAssertTrue(forgotPasswordButton.hasLabel(label: "Forgot Password?"))

        let needAccountButton = LoginHelper.Login.needAccountButton.waitUntil(.visible)
        XCTAssertTrue(needAccountButton.isVisible)
        XCTAssertTrue(needAccountButton.hasLabel(label: "Need a Canvas Account? Click Here, It's Free!"))

        emailInput.writeText(text: parent.login_id!)
        passwordInput.writeText(text: parent.password!)
        loginButton.hit()

        // MARK: Check if login was successful
        let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
        XCTAssertTrue(profileButton.isVisible)

        profileButton.hit()
        let usernameLabel = ProfileHelper.userNameLabel.waitUntil(.visible)
        XCTAssertTrue(usernameLabel.isVisible)
        XCTAssertTrue(usernameLabel.hasLabel(label: parent.name))
    }

    func testForgotPassword() {
        // MARK: Seed the usual stuff
        let parent = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollParent(parent, in: course)

        // MARK: Start login process
        findSchool()
        let navBar = LoginHelper.Login.navBar.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        let forgotPasswordButton = LoginHelper.Login.forgotPasswordButton.waitUntil(.visible)
        XCTAssertTrue(forgotPasswordButton.isVisible)
        XCTAssertTrue(forgotPasswordButton.hasLabel(label: "Forgot Password?"))

        // MARK: Tap "Forgot Password" button
        forgotPasswordButton.hit()
        let emailInput = LoginHelper.Login.emailField.waitUntil(.visible)
        XCTAssertTrue(emailInput.isVisible)

        let requestPasswordButton = LoginHelper.Login.requestPasswordButton.waitUntil(.visible)
        XCTAssertTrue(requestPasswordButton.isVisible)
        XCTAssertTrue(requestPasswordButton.hasLabel(label: "Request Password"))

        let backToLoginButton = LoginHelper.Login.backToLoginButton.waitUntil(.visible)
        XCTAssertTrue(backToLoginButton.isVisible)
        XCTAssertTrue(backToLoginButton.hasLabel(label: "Back to Login"))
    }

    func testLoginWithoutUsernameAndPassword() {
        // MARK: Seed the usual stuff
        let parent = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollParent(parent, in: course)

        // MARK: Start login process
        findSchool()
        let navBar = LoginHelper.Login.navBar.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        let loginButton = LoginHelper.Login.loginButton.waitUntil(.visible)
        XCTAssertTrue(loginButton.isVisible)

        loginButton.hit()

        // MARK: Check "No password was given" label
        let noPasswordLabel = LoginHelper.Login.noPasswordLabel.waitUntil(.visible)
        XCTAssertTrue(noPasswordLabel.isVisible)

        let emailInput = LoginHelper.Login.emailField.waitUntil(.visible)
        XCTAssertTrue(emailInput.isVisible)

        emailInput.writeText(text: parent.login_id!)
        loginButton.hit()

        noPasswordLabel.waitUntil(.visible)
        XCTAssertTrue(noPasswordLabel.isVisible)
    }

    func testWrongUsernameAndPassword() {
        // MARK: Seed the usual stuff
        let parent = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollParent(parent, in: course)

        // MARK: Start login process
        findSchool()
        let navBar = LoginHelper.Login.navBar.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        let emailInput = LoginHelper.Login.emailField.waitUntil(.visible)
        XCTAssertTrue(emailInput.isVisible)

        let passwordInput = LoginHelper.Login.passwordField.waitUntil(.visible)
        XCTAssertTrue(passwordInput.isVisible)

        let loginButton = LoginHelper.Login.loginButton.waitUntil(.visible)
        XCTAssertTrue(loginButton.isVisible)

        // MARK: Wrong username and password
        emailInput.writeText(text: "wrong email")
        passwordInput.writeText(text: "wrong password")

        loginButton.hit()

        var invalidUsernameOrPasswordLabel = LoginHelper.Start.invalidUsernameOrPasswordLabel.waitUntil(.visible)
        XCTAssertTrue(invalidUsernameOrPasswordLabel.isVisible)

        // MARK: Correct username with wrong password
        emailInput.cutText()
        emailInput.writeText(text: parent.login_id!)
        passwordInput.writeText(text: "wrong password")
        loginButton.hit()

        invalidUsernameOrPasswordLabel = LoginHelper.Start.invalidUsernameOrPasswordLabel.waitUntil(.visible)
        XCTAssertTrue(invalidUsernameOrPasswordLabel.isVisible)

        // MARK: Check that the user didn't get logged in
        let profileButton = DashboardHelper.profileButton.waitUntil(.vanish)
        XCTAssertTrue(profileButton.isVanished)
    }

    // Follow-up of MBL-14653
    func testLoginWithLastUser() {
        let parent = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollParent(parent, in: course)
        logInDSUser(parent, lastLogin: false)
        logOut()
        let lastLoginBtn = LoginHelper.Start.lastLoginButton.waitUntil(.visible)
        XCTAssertTrue(lastLoginBtn.hasLabel(label: user.host))

        lastLoginBtn.hit()
        loginAfterSchoolFound(parent)
        let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
        XCTAssertTrue(profileButton.isVisible)
    }
}
