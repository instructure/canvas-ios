//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
import TestsFoundation

enum Profile: String, ElementWrapper {
    case
        actAsUserButton,
        changeUserButton,
        colorOverlayToggle,
        developerMenuButton,
        filesButton,
        helpButton,
        logOutButton,
        settingsButton,
        showGradesToggle,
        userEmailLabel,
        userNameLabel,
        versionLabel

    static func ltiButton(domain: String, id: String) -> Element {
        return app.find(id: "Profile.lti.\(domain).\(id)")
    }

    static func close(file: StaticString = #file, line: UInt = #line) {
        Dashboard.profileButton.tapAt(.zero, file: file, line: line)
    }

    static func open(file: StaticString = #file, line: UInt = #line) {
        Dashboard.profileButton.tapUntil(file: file, line: line) {
            Profile.userNameLabel.exists
        }
    }
}

enum ProfileSettings {
    static var profile: Element {
        return app.find(label: "Profile")
    }

    static var about: Element {
        return app.find(label: "About")
    }

    static var landingPage: Element {
        return app.find(label: "Landing Page")
    }

    static var notificationPreferences: Element {
        return app.find(label: "Notification Preferences")
    }
}

enum LandingPageCell: String, ElementWrapper, CaseIterable {
    case dashboard     = "0"
    case calendar      = "1"
    case todo          = "2"
    case notifications = "3"
    case inbox         = "4"

    var relatedTab: TabBar {
        switch self {
        case .dashboard:
            return TabBar.dashboardTab
        case .calendar:
            return TabBar.calendarTab
        case .todo:
            return TabBar.todoTab
        case .notifications:
            return TabBar.notificationsTab
        case .inbox:
            return TabBar.inboxTab
        }
    }
}
