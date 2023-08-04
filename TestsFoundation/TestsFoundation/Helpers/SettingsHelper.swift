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

public enum SettingsMenuItem: Int {
    case landingPage = 0
    case appearance = 1
    case pairWithObserver = 2
    case subscribeToCalendarFeed = 3
    case about = 4
    case privacyPolicy = 5
    case termsOfUse = 6
    case canvasOnGitHub = 7
}

public enum LandingPageMenuItem: Int {
    case dashboard = 0
    case calendar = 1
    case toDo = 2
    case notifications = 3
    case inbox = 4
}

public enum AppearanceMenuItem: Int {
    case system = 0
    case light = 1
    case dark = 2
}

public class SettingsHelper: BaseHelper {
    public static var navBar: XCUIElement { app.find(id: "Settings") }
    public static var doneButton: XCUIElement { app.find(id: "screen.dismiss") }
    public static var preferencesLabel: XCUIElement { app.find(id: "Preferences") }

    public static func menuItem(item: SettingsMenuItem) -> XCUIElement {
        return app.find(id: "settings.tableView").findAll(type: .cell, minimumCount: 8)[item.rawValue]
    }

    public static func labelOfMenuItem(menuItem: XCUIElement) -> XCUIElement {
        return menuItem.find(type: .staticText)
    }

    public static func navigateToSettings() {
        DashboardHelper.profileButton.hit()
        ProfileHelper.settingsButton.hit()
    }

    public struct SubSettings {
        public static var landingPageNavBar: XCUIElement { app.find(id: "Landing Page") }
        public static var appearanceNavBar: XCUIElement { app.find(id: "Appearance") }
        public static var pairWithObserverNavBar: XCUIElement { app.find(id: "Pair with Observer")}
        public static var termsOfUseNavBar: XCUIElement { app.find(id: "Terms of Use") }
        public static var QRCodeImage: XCUIElement { app.find(id: "QRCodeImage") }

        public static func landingPageMenuItem(item: LandingPageMenuItem) -> XCUIElement {
            return app.find(id: "ItemPickerItem.0-\(item.rawValue)")
        }

        public static func appearanceMenuItem(item: AppearanceMenuItem) -> XCUIElement {
            return app.find(id: "ItemPickerItem.0-\(item.rawValue)")
        }

        public static func labelOfMenuItem(menuItem: XCUIElement) -> XCUIElement {
            return menuItem.find(type: .staticText)
        }

        public static var backButton: XCUIElement { app.find(label: "Settings", type: .button) }
        public static var shareButton: XCUIElement { app.find(label: "Share", type: .button) }
        public static var doneButton: XCUIElement { app.findAll(type: .navigationBar, minimumCount: 2)[1].find(id: "screen.dismiss") }
    }

    public struct About {
        public static var aboutView: XCUIElement { app.find(id: "AboutView") }
        public static var appLabel: XCUIElement { app.find(id: "App")}
        public static var domainLabel: XCUIElement { app.find(id: "Domain")}
        public static var loginIdLabel: XCUIElement { app.find(id: "Login ID")}
        public static var emailLabel: XCUIElement { app.find(id: "Email")}
        public static var versionLabel: XCUIElement { app.find(id: "Version")}
    }
}
