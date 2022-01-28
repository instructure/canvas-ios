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

    open override func setUp() {
        LoginSession.useTestKeychain()
        continueAfterFailure = false
        if CoreUITestCase.needsLaunch || app.state != .runningForeground || isRetry {
            CoreUITestCase.needsLaunch = false
            launch()
            if currentSession() != nil {
                homeScreen.waitToExist()
            }
        }

        reset()
        send(.enableExperimentalFeatures(experimentalFeatures))

        if case .passThruAndLog(toPath: let logPath) = missingMockBehavior {
            // Clear old log
            try? FileManager.default.removeItem(atPath: logPath)
        }
    }

    open func logInDSUser(_ dsUser: DSUser) {
        if let entry = user.session {
            return logInEntry(entry)
        }

        // Assumes we are on the login start screen
        LoginStart.findSchoolButton.tap()
        LoginFindSchool.searchField.pasteText("\(user.host)")
        LoginFindSchool.searchField.typeText("\r")

        LoginWeb.emailField.waitToExist(60)
        LoginWeb.emailField.pasteText(dsUser.login_id)
        LoginWeb.passwordField.tap().pasteText("password")
        LoginWeb.logInButton.tap()

        homeScreen.waitToExist()
        user.session = currentSession()
    }
}
