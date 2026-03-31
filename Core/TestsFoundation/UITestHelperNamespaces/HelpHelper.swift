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

public class HelpHelper: BaseHelper {

    public static var closeButton: XCUIElement { app.find(label: "Close", type: .button) }

    public static func getAllHelpItems() -> [XCUIElement] {
        let helpItemsContainer = app.find(id: "helpItems")
        return helpItemsContainer.buttons.allElementsBoundByIndex
    }

    // MARK: - Navigation

    public static func navigateToHelpPage() {
        XCTContext.runActivity(named: "Navigate to Help screen") { _ in
            DashboardHelper.profileButton.hit()
            ProfileHelper.helpButton.hit()
            let navTitle = app.find(label: "Help", type: .staticText)
            navTitle.waitUntil(.visible)
        }
    }

    public static func returnToHelpPage(isStudentApp: Bool = true) {
        closeSafariAndActivateApp()
        if !isStudentApp {
            closeButton.hit()
        }
        navigateToHelpPage()
    }

    private static func closeSafariAndActivateApp() {
        SafariAppHelper.safariApp.terminate()
        app.activate()
    }
}
