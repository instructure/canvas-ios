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

class LoginTests: CanvasUITests {
    override var user: UITestUser? { return nil }

    func testFindSchool() {
        LoginStart.findSchoolButton.tap()
        LoginFindSchool.searchField.typeText("mtech")
        LoginFindAccountResult.item(host: "mtec.instructure.com").waitToExist()
    }

    func testCanvasLoginToDashboard() {
        logInUser(.readStudent1)

        Dashboard.coursesLabel.waitToExist()
        Dashboard.courseCard(id: "247").waitToExist()
        XCTAssert(TabBar.dashboardTab.exists)
    }

    func testLDAPLoginToDashboard() {
        let user = UITestUser.ldapUser
        LoginStart.findSchoolButton.tap()
        LoginFindSchool.searchField.typeText("\(user.host)\r")

        XCUIElementWrapper(app.webViews.links["LDAP"]).tap()

        LoginWeb.emailField.typeText(user.username)
        LoginWeb.passwordField.typeText(user.password)
        LoginWeb.logInButton.tap()

        Dashboard.coursesLabel.waitToExist()
        TabBar.dashboardTab.waitToExist()
    }

    func testMultipleUsers() {
        logInUser(.readStudent1)
        let entry1 = UITestUser.readStudent1.keychainEntry!

        Profile.open()
        Profile.changeUserButton.tap()

        logInUser(.readStudent2)
        let entry2 = UITestUser.readStudent2.keychainEntry!

        Profile.open()
        Profile.changeUserButton.tap()

        LoginStart.findSchoolButton.waitToExist()
        XCTAssert(LoginStartKeychainEntry.cell(host: entry1.baseURL.host!, userID: entry1.userID).exists)
        XCTAssert(LoginStartKeychainEntry.cell(host: entry2.baseURL.host!, userID: entry2.userID).exists)
    }

    func testSessionMaintainedAfterTermination() {
        logInUser(.readStudent1)

        Dashboard.coursesLabel.waitToExist()
        Dashboard.courseCard(id: "247").waitToExist()
        TabBar.dashboardTab.waitToExist()

        launch()

        Dashboard.coursesLabel.waitToExist()
        Dashboard.courseCard(id: "247").waitToExist()
        TabBar.dashboardTab.waitToExist()
    }

    func testMDMLogin() {
        let user = UITestUser.readStudent1
        launch { app in
            app.launchArguments.append(contentsOf: [
                "-com.apple.configuration.managed",
                user.profile
            ])
        }

        LoginStartMDMLogin.cell(host: user.host, username: user.username).tap()

        Dashboard.coursesLabel.waitToExist()
        Dashboard.courseCard(id: "247").waitToExist()
        TabBar.dashboardTab.waitToExist()
    }
}
