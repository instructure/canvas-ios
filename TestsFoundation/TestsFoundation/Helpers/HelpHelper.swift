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

public class HelpHelper: BaseHelper {
    public static var searchTheCanvasGuides: XCUIElement {
        return app.find(id: "helpItems").findAll(type: .button)[0]
    }

    public static var askYourInstructor: XCUIElement {
        return app.find(id: "helpItems").findAll(type: .button, minimumCount: 2)[1]
    }

    public static var reportAProblem: XCUIElement {
        return app.find(id: "helpItems").findAll(type: .button, minimumCount: 3)[2]
    }

    public static var submitAFeatureIdea: XCUIElement {
        return app.find(id: "helpItems").findAll(type: .button, minimumCount: 4)[3]
    }

    public static var covid19: XCUIElement {
        return app.find(id: "helpItems").findAll(type: .button, minimumCount: 5)[4]
    }

    public static func navigateToHelpPage() {
        DashboardHelper.profileButton.hit()
        ProfileHelper.helpButton.hit()
    }

    public static var browserURL: String {
        SafariAppHelper.safariApp.activate()
        SafariAppHelper.safariApp.find(id: "ReloadButton").waitUntil(.visible)
        SafariAppHelper.safariApp.find(id: "TabBarItemTitle").hit()
        let url = SafariAppHelper.safariApp.find(id: "URL").waitUntil(.visible).value as? String ?? ""
        return url
    }

    public static func closeSafariAndActivateApp() {
        SafariAppHelper.safariApp.terminate()
        app.activate()
    }

    public static func returnToHelpPage() {
        closeSafariAndActivateApp()
        navigateToHelpPage()
    }
}
