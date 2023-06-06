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
import XCTest

public class HelpHelper: BaseHelper {
    public static let safariApp = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")

    public static func navigateToHelpPage() {
        Dashboard.profileButton.tap()
        let helpButton = Profile.helpButton.waitToExist()
        helpButton.tap()
    }

    public static var browserURL: String {
        safariApp.activate()
        safariApp.find(id: "ReloadButton").waitToExist()
        safariApp.find(id: "TabBarItemTitle").tap()
        let url = safariApp.find(id: "URL").waitToExist().value()
        return url!
    }

    public static func closeSafariAndActivateApp() {
        safariApp.terminate()
        app.activate()
    }

    public static func returnToHelpPage() {
        closeSafariAndActivateApp()
        navigateToHelpPage()
    }
}
