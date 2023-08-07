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

public class ProfileHelper: BaseHelper {
    public static var actAsUserButton: XCUIElement { app.find(id: "Profile.actAsUserButton") }
    public static var changeUserButton: XCUIElement { app.find(id: "Profile.changeUserButton") }
    public static var colorOverlayToggle: XCUIElement { app.find(id: "Profile.colorOverlayToggle") }
    public static var developerMenuButton: XCUIElement { app.find(id: "Profile.developerMenuButton") }
    public static var filesButton: XCUIElement { app.find(id: "Profile.filesButton") }
    public static var helpButton: XCUIElement { app.find(id: "Profile.helpButton") }
    public static var logOutButton: XCUIElement { app.find(id: "Profile.logOutButton") }
    public static var settingsButton: XCUIElement { app.find(id: "Profile.settingsButton") }
    public static var showGradesToggle: XCUIElement { app.find(id: "Profile.showGradesToggle") }
    public static var userEmailLabel: XCUIElement { app.find(id: "Profile.userEmailLabel") }
    public static var userNameLabel: XCUIElement { app.find(id: "Profile.userNameLabel") }
    public static var versionLabel: XCUIElement { app.find(id: "Profile.versionLabel") }
    public static var inboxButton: XCUIElement { app.find(id: "Profile.inboxButton") }
}
