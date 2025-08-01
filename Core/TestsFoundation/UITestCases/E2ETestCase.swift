//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
@testable import Core

open class E2ETestCase: CoreUITestCase {

    open override var user: UITestUser {.dataSeedAdmin}
    private let isRetry = ProcessInfo.processInfo.environment["CANVAS_TEST_IS_RETRY"] == "YES"
    public let seeder = DataSeeder()
    open override var useMocks: Bool {false}
    open override var doLoginAfterSetup: Bool { false }
    open var canvasFeatureFlags: [DSCanvasFeatureFlag] { [] }

    open override func setUp() {
        super.setUp()

        setNetworkStateOnline()
        for canvasFeatureFlag in canvasFeatureFlags {
            let featureFlagResponse = seeder.setFeatureFlag(featureFlag: canvasFeatureFlag.featureFlag, state: canvasFeatureFlag.state)
            XCTAssertEqual(featureFlagResponse.state, canvasFeatureFlag.state.rawValue)
        }
    }

    open func findSchool(lastLogin: Bool = false) {
        let findSchoolButton = LoginHelper.Start.findSchoolButton.waitUntil(.visible)
        if lastLogin && LoginHelper.Start.lastLoginButton.exists && LoginHelper.Start.lastLoginButton.label == user.host {
            LoginHelper.Start.lastLoginButton.hit()
        } else {
            findSchoolButton.hit()
            LoginHelper.FindSchool.searchField.writeText(text: user.host)
            LoginHelper.FindSchool.nextButton.hit()
        }
    }

    open func loginAfterSchoolFound(_ dsUser: DSUser, password: String = "password") {
        XCTContext.runActivity(named: "Login with \(dsUser.login_id!)") { _ in
            LoginHelper.Login.emailField.waitUntil(.visible, timeout: 60)
            LoginHelper.Login.emailField.writeText(text: dsUser.login_id!)
            LoginHelper.Login.passwordField.writeText(text: password)
            LoginHelper.Login.loginButton.hit()

            homeScreen.waitUntil(.visible, timeout: 20)
            user.session = currentSession()
            setAppThemeToSystem()
        }
    }

    open func logInDSUser(_ dsUser: DSUser, lastLogin: Bool = true, password: String = "password") {
        findSchool(lastLogin: lastLogin)
        loginAfterSchoolFound(dsUser, password: password)
    }

    open func logOut() {
        DashboardHelper.profileButton.hit()
        ProfileHelper.logOutButton.hit()
    }

    // Workaround to handle app theme prompt
    open func setAppThemeToSystem() {
        let canvasThemePromptTitle = app.find(label: "Canvas is now available in dark theme")
        let systemSettingsButton = app.find(label: "System settings", type: .button)
        if canvasThemePromptTitle.waitUntil(.visible, timeout: 5).exists {
            systemSettingsButton.actionUntilElementCondition(action: .tap, element: canvasThemePromptTitle, condition: .vanish)
        }
    }

    @discardableResult
    open func setNetworkStateOffline(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Bool {
        do {
            if try CommandLine.isOnline() {
                try CommandLine.setConnection(state: .off)
            }

            return try CommandLine.isOffline()
        } catch(let error) {
            XCTFail(
                error.localizedDescription,
                file: file,
                line: line
            )
            return false
        }
    }

    @discardableResult
    open func setNetworkStateOnline(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Bool {
        do {
            if try CommandLine.isOffline() {
                try CommandLine.setConnection(state: .on)
                sleep(10) // Give it some time to fully regain internet connection
            }

            return try CommandLine.isOnline()
        } catch(let error) {
            XCTFail(
                error.localizedDescription,
                file: file,
                line: line
            )
            return false
        }
    }
}
