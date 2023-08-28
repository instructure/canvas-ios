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

open class BaseHelper {
    public static let seeder = DataSeeder()
    public static var user: UITestUser {.dataSeedAdmin}
    public static var backButton: XCUIElement { app.find(label: "Back", type: .button) }
    public static var nextButton: XCUIElement { app.find(id: "nextButton", type: .button) }
    public static func pullToRefresh() {
        let window = app.find(type: .window)
        window.relativeCoordinate(x: 0.5, y: 0.2)
            .press(forDuration: 0.05, thenDragTo: window.relativeCoordinate(x: 0.5, y: 1.0))
    }

    public struct TabBar {
        public static var dashboardTab: XCUIElement { app.find(id: "TabBar.dashboardTab", type: .button) }
        public static var calendarTab: XCUIElement { app.find(id: "TabBar.calendarTab", type: .button) }
        public static var todoTab: XCUIElement { app.find(id: "TabBar.todoTab", type: .button) }
        public static var notificationsTab: XCUIElement { app.find(id: "notificationsTab", type: .button) }
        public static var inboxTab: XCUIElement { app.find(id: "TabBar.inboxTab", type: .button) }

        // Parent
        public static var coursesTab: XCUIElement { app.find(id: "TabBar.coursesTab", type: .button) }
        public static var alertsTab: XCUIElement { app.find(id: "TabBar.alertsTab", type: .button) }

        // K5
        public static var myCanvasTab: XCUIElement { app.find(id: "TabBar.myCanvasTab", type: .button) }
    }

    public struct AccountNotifications {
        public static func toggleButton(notification: DSAccountNotification) -> XCUIElement {
            return app.find(id: "AccountNotification.\(notification.id).toggleButton")
        }

        public static func dismissButton(notification: DSAccountNotification) -> XCUIElement {
            return app.find(id: "AccountNotification.\(notification.id).dismissButton")
        }
    }
}
