//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public class SettingsAppHelper: BaseHelper {
    public static let app = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
    public static var canvasStudentButton: XCUIElement { app.find(label: "Canvas Student", type: .staticText) }

    public struct CanvasStudent {
        public static var notificationsButton: XCUIElement { app.find(label: "Notifications", type: .staticText) }

        public struct Notifications {
            public static var notificationsToggle: XCUIElement { app.find(label: "Allow Notifications", type: .switch) }
        }
    }
}
