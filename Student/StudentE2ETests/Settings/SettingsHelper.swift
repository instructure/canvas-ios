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

import TestsFoundation

public class SettingsHelper: BaseHelper {
    public static var navBar: Element { app.find(id: "Settings") }
    public static var doneButton: Element { app.find(id: "screen.dismiss") }
    public static var preferencesLabel: Element { app.find(id: "Preferences") }

    public static func menuItem(item: SettingsMenuItem) -> Element {
        return app.find(id: "settings.tableView").rawElement.findAll(type: .cell)[item.rawValue]
    }

    public static func labelOfMenuItem(menuItem: Element) -> Element {
        return menuItem.rawElement.find(type: .staticText)
    }

    public static func navigateToSettings() {
        Dashboard.profileButton.tap()
        Profile.settingsButton.tap()
    }

    struct SubSettings {
        public static var landingPageNavBar: Element { app.find(id: "Landing Page") }
        public static var appearanceNavBar: Element { app.find(id: "Appearance") }
        public static var pairWithObserverNavBar: Element { app.find(id: "Pair with Observer")}
        public static var termsOfUseNavBar: Element { app.find(id: "Terms of Use") }
        public static var QRCodeImage: Element { app.find(id: "QRCodeImage") }

        public static func landingPageMenuItem(item: LandingPageMenuItem) -> Element {
            return app.find(id: "ItemPickerItem.0-\(item.rawValue)")
        }

        public static func appearanceMenuItem(item: AppearanceMenuItem) -> Element {
            return app.find(id: "ItemPickerItem.0-\(item.rawValue)")
        }

        public static func labelOfMenuItem(menuItem: Element) -> Element {
            return menuItem.rawElement.find(type: .staticText)
        }

        public static var backButton: Element { app.find(label: "Settings", type: .button) }
        public static var shareButton: Element { app.find(label: "Share", type: .button) }
        public static var doneButton: Element { app.findAll(type: .navigationBar)[1].rawElement.find(id: "screen.dismiss") }

        struct CalendarApp {
            public static let calendarApp = XCUIApplication(bundleIdentifier: "com.apple.mobilecal")
            public static var continueButton: Element { calendarApp.find(label: "Continue", type: .button) }
            public static var navBar: Element { calendarApp.find(id: "Add Subscription Calendar") }
            public static var subscriptionUrl: Element {
                calendarApp.find(type: .table).rawElement.find(type: .cell).rawElement.find(type: .textField)
            }
        }

        struct SafariApp {
            public static let safariApp = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")

            public static var browserURL: String {
                safariApp.activate()
                safariApp.find(id: "ReloadButton").waitToExist()
                safariApp.find(id: "TabBarItemTitle").tap()
                let url = safariApp.find(id: "URL").waitToExist().value()
                return url!
            }
        }
    }

    struct About {
        public static var aboutView: Element { app.find(id: "AboutView") }
        public static var appLabel: Element { app.find(id: "App")}
        public static var domainLabel: Element { app.find(id: "Domain")}
        public static var loginIdLabel: Element { app.find(id: "Login ID")}
        public static var emailLabel: Element { app.find(id: "Email")}
        public static var versionLabel: Element { app.find(id: "Version")}
    }
}

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
