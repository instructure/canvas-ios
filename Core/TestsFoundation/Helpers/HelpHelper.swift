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
    public static var doneButton: XCUIElement { app.find(label: "Done", type: .button) }

    public static var searchTheCanvasGuides: XCUIElement {
        return app.find(id: "helpItems").find(labelContaining: "Search the Canvas Guides", type: .button)
    }

    public static var customLink: XCUIElement {
        return app.find(id: "helpItems").find(labelContaining: "CUSTOM LINK", type: .button)
    }

    public static var askYourInstructor: XCUIElement {
        return app.find(id: "helpItems").find(labelContaining: "Ask Your Instructor", type: .button)
    }

    public static var reportAProblem: XCUIElement {
        return app.find(id: "helpItems").find(labelContaining: "Report a Problem", type: .button)
    }

    public static var submitAFeatureIdea: XCUIElement {
        return app.find(id: "helpItems").find(labelContaining: "Submit a Feature Idea", type: .button)
    }

    public static var covid19: XCUIElement {
        return app.find(id: "helpItems").find(labelContaining: "COVID-19 Canvas Resources", type: .button)
    }

    // Teacher only
    public static var conferenceGuides: XCUIElement {
        return app.find(id: "helpItems").find(labelContaining: "Conference Guides", type: .button)
    }

    public static var askTheCommunity: XCUIElement {
        return app.find(id: "helpItems").find(labelContaining: "Ask the Community", type: .button)
    }

    public static var trainingServices: XCUIElement {
        return app.find(id: "helpItems").find(labelContaining: "Training Services Portal", type: .button)
    }

    // Functions
    public static func navigateToHelpPage() {
        DashboardHelper.profileButton.hit()
        ProfileHelper.helpButton.hit()
    }

    public static func closeSafariAndActivateApp() {
        SafariAppHelper.safariApp.terminate()
        app.activate()
    }

    public static func returnToHelpPage(teacher: Bool = false) {
        closeSafariAndActivateApp()
        if teacher { doneButton.hit() }
        navigateToHelpPage()
    }
}
