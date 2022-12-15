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

class LoginE2ETests: CoreUITestCase {
    override var user: UITestUser? { nil }

    func testFindSchool() {
        XCTAssertEqual(LoginStart.findSchoolButton.label(), "Find my school")
        LoginStart.findSchoolButton.tap()
        LoginFindSchool.searchField.typeText("iOS Auto")
        LoginFindAccountResult.item(host: "iosauto.instructure.com").waitToExist()
    }

    func testCanvasLoginToDashboard() {
        logInUser(.readStudent1)

        Dashboard.coursesLabel.waitToExist()
        Dashboard.courseCard(id: "247").waitToExist()
        XCTAssert(TabBar.dashboardTab.exists)
    }

    // TODO: Get new LDAP account
    func xtestLDAPLoginToDashboard() {
        let user = UITestUser.ldapUser
        LoginStart.findSchoolButton.tap()
        LoginFindSchool.searchField.typeText("\(user.host)\r")

        app.webViews.links.matching(label: "LDAP").firstElement.tap()

        LoginWeb.emailField.typeText(user.username)
        LoginWeb.passwordField.typeText(user.password)
        LoginWeb.logInButton.tap()

        Dashboard.coursesLabel.waitToExist()
        TabBar.dashboardTab.waitToExist()
    }

    func testSAMLLoginToDashboard() {
        setAnimationsEnabled(true)
        defer { setAnimationsEnabled(false) }
        let user = UITestUser.saml
        LoginStart.findSchoolButton.tap()
        LoginFindSchool.searchField.typeText("\(user.host)")
        app.find(label: "iOS Auto - SAML").tap()
        let emailField = app.find(label: "Enter your email, phone, or Skype.")
        emailField.tap()
        emailField.typeText("\(user.username)\r")
        LoginWeb.passwordField.tap()
        LoginWeb.passwordField.typeText("\(user.password)\r")
        let staySignedInButton = app.find(label: "No", type: .button)
        while staySignedInButton.rawElement.waitForExistence(timeout: 5) {
            staySignedInButton.tap()
        }
        TabBar.dashboardTab.waitToExist()
    }

    func testMultipleUsers() {
        logInUser(.readStudent1)
        let entry1 = UITestUser.readStudent1.session!

        Profile.open()
        Profile.changeUserButton.tap()

        logInUser(.readStudent2)
        let entry2 = UITestUser.readStudent2.session!

        Profile.open()
        Profile.changeUserButton.tap()

        LoginStart.findSchoolButton.waitToExist()
        XCTAssert(LoginStartSession.cell(host: entry1.baseURL.host!, userID: entry1.userID).exists)
        XCTAssert(LoginStartSession.cell(host: entry2.baseURL.host!, userID: entry2.userID).exists)
    }

    func testSessionMaintainedAfterTermination() {
        logInUser(.readStudent1)

        Dashboard.coursesLabel.waitToExist()
        Dashboard.courseCard(id: "247").waitToExist()
        TabBar.dashboardTab.waitToExist()

        Dashboard.coursesLabel.waitToExist()
        Dashboard.courseCard(id: "247").waitToExist()
        TabBar.dashboardTab.waitToExist()
    }

    func testMDMLogin() {
        let user = UITestUser.readStudent1
        launch { app in
            app.launchArguments.append(contentsOf: [
                "-com.apple.configuration.managed",
                user.profile,
            ])
        }

        LoginStartMDMLogin.cell(host: user.host, username: user.username).tapUntil {
            Dashboard.coursesLabel.exists
        }
        Dashboard.courseCard(id: "247").waitToExist()
        TabBar.dashboardTab.waitToExist()

        reset()
        launch()
    }

    func testMDMHost() {
        let user = UITestUser.readStudent1
        launch { app in
            app.launchArguments.append(contentsOf: [
                "-com.apple.configuration.managed",
                """
                    <dict>
                        <key>enableLogin</key><true/>
                        <key>host</key><string>\(user.host)</string>
                    </dict>
                """
                .replacingOccurrences(of: "[\\n\\s]", with: "", options: .regularExpression, range: nil),
            ])
        }

        LoginStart.lastLoginButton.waitToExist()
        XCTAssertEqual(LoginStart.lastLoginButton.label(), "Log In")
        XCTAssertFalse(LoginStart.canvasNetworkButton.isVisible)
        LoginStart.lastLoginButton.tap()

        LoginWeb.emailField.typeText(user.username)
        LoginWeb.passwordField.typeText(user.password)
        LoginWeb.logInButton.tap()

        homeScreen.waitToExist()

        launch()
    }

    func testVanityDomain() {
        logInUser(.vanityDomainUser)

        Dashboard.coursesLabel.waitToExist()
        Dashboard.courseCard(id: "1602031").waitToExist()
        XCTAssert(TabBar.dashboardTab.exists)
    }
}
