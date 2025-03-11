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

public enum SettingsMenuItem: String {
    case landingPage = "Landing Page"
    case appearance = "Appearance"
    case pairWithObserver = "Pair with Observer"
    case subscribeToCalendarFeed = "Subscribe to Calendar Feed"
    case about = "About"
    case synchronization = "Synchronization"
    case privacyPolicy = "Privacy Policy"
    case termsOfUse = "Terms of Use"
    case canvasOnGitHub = "Canvas on GitHub"
}

public enum LandingPageMenuItem: String {
    case dashboard = "Dashboard"
    case calendar = "Calendar"
    case toDo = "To Do"
    case notifications = "Notifications"
    case inbox = "Inbox"
    case courses = "Courses"
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
        return app.find(id: "settings.tableView").find(label: item.rawValue, type: .staticText)
    }

    public static func valueOfMenuItem(item: SettingsMenuItem) -> XCUIElement? {
        let cells = app.find(id: "settings.tableView").findAll(type: .cell)
        for cell in cells {
            let staticTexts = cell.findAll(type: .staticText)
            for staticText in staticTexts where staticText.label == item.rawValue {
                return staticTexts[1]
            }
        }
        return nil
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
            return app.find(type: .table).find(label: item.rawValue, type: .staticText)
        }

        public static func appearanceMenuItem(item: AppearanceMenuItem) -> XCUIElement {
            return app.find(id: "ItemPickerItem.0-\(item.rawValue)")
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

    public struct OfflineSync {
        public static var autoContentSyncSwitch: XCUIElement { app.find(label: "Auto Content Sync", type: .switch).find(type: .switch) }
        public static var syncFrequencyButton: XCUIElement { app.find(labelContaining: "Sync Frequency", type: .button) }
        public static var wifiOnlySwitch: XCUIElement { app.find(label: "Sync Content Over Wi-Fi Only", type: .switch).find(type: .switch) }
        public static var backButton: XCUIElement { app.find(label: "Settings", type: .button) }

        public static var turnOffWifiOnlySyncStaticText: XCUIElement { app.find(label: "Turn Off Wi-Fi Only Sync?", type: .staticText) }
        public static var turnOffButton: XCUIElement { app.find(label: "Turn Off", type: .button) }

        public struct SyncFrequency {
            public static var asTheOsAllows: XCUIElement { app.find(labelContaining: "as the OS allows", type: .staticText) }
            public static var daily: XCUIElement { app.find(label: "Daily", type: .staticText) }
            public static var weekly: XCUIElement { app.find(label: "Weekly", type: .staticText) }
        }
    }
}
