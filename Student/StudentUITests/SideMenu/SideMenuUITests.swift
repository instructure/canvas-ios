//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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
@testable import Core

class SideMenuUITests: MiniCanvasUITestCase {
    func testNavigation() throws {
        Profile.open()
        Profile.filesButton.tap()
        XCTAssertTrue(app.navigationBars["Core.FileListView"].exists)
    }

    func testSettings() {
        Profile.open()
        Profile.settingsButton.tap()
        XCTAssertTrue(app.navigationBars["Core.ProfileSettingsView"].exists)
    }

//    func testHelp() {
//        Profile.open()
//        Profile.helpButton.waitToExist()
//        Profile.helpButton.tap()
//        XCTAssertTrue(app.buttons["Help"].exists)
//    }

    func testChangeUser() {
        Profile.open()
        Profile.changeUserButton.tap()
        XCTAssertTrue(app.buttons["LoginStart.findSchoolButton"].exists)
    }

    func testLogOut() {
        Profile.open()
        Profile.logOutButton.tap()
        XCTAssertTrue(app.buttons["LoginStart.findSchoolButton"].exists)
    }
}
