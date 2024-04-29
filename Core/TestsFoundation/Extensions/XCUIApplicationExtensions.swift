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

import XCTest

public extension XCUIApplication {
    func uninstall() {
        terminate()

        let timeout = TimeInterval(5)
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

        var appName = ""

        let testRunner = Bundle.main.infoDictionary?["CFBundleExecutable"] as! String
        let executable = testRunner
            .replacingOccurrences(of: "E2ETests-Runner", with: "")
            .replacingOccurrences(of: "UITests-Runner", with: "")

        appName = "Canvas \(executable)"

        let appIcon = springboard.icons[appName].firstMatch
        if appIcon.waitForExistence(timeout: timeout) {
            appIcon.press(forDuration: 1)
        } else {
            return
        }

        let removeAppButton = springboard.buttons["Remove App"]
        if removeAppButton.waitForExistence(timeout: timeout) {
            removeAppButton.tap()
        } else {
            XCTFail("Failed to find 'Remove App'")
        }

        let deleteAppButton = springboard.alerts.buttons["Delete App"]
        if deleteAppButton.waitForExistence(timeout: timeout) {
            deleteAppButton.tap()
        } else {
            XCTFail("Failed to find 'Delete App'")
        }

        let finalDeleteButton = springboard.alerts.buttons["Delete"]
        if finalDeleteButton.waitForExistence(timeout: timeout) {
            finalDeleteButton.tap()
        } else {
            XCTFail("Failed to find 'Delete'")
        }
    }
}
