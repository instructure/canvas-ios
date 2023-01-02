//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import TestsFoundation

class ProfileE2ETests: CoreUITestCase {
    override func setUp() {
        // opening and closing profile causes flakiness
        // relaunch every test for stability
        Self.needsLaunch = true
        super.setUp()
    }

    func testProfileDisplaysUsername() {
        Profile.open()
        XCTAssertEqual(Profile.userNameLabel.label(), "Student One")
    }

    func testProfileChangesUser() {
        Profile.open()
        Profile.changeUserButton.tap()
        let entry = user!.session!
        LoginStartSession.cell(host: entry.baseURL.host!, userID: entry.userID).waitToExist()
    }

    func xtestProfileLogsOut() {
        Profile.open()
        Profile.logOutButton.tap()
        LoginStart.findSchoolButton.waitToExist()
        let entry = user!.session!
        XCTAssertFalse(LoginStartSession.cell(host: entry.baseURL.host!, userID: entry.userID).exists)
    }

    func testPreviewUserFile() {
        Profile.open()
        Profile.filesButton.tap()

        FileList.file(index: 0).tap()
        FileDetails.imageView.waitToExist()
    }

    func xtestProfileLandingPage() {
        guard let entry = user?.session else {
            return XCTFail("Couldn't get keychain entry")
        }
        for cell in LandingPageCell.allCases.reversed() { // dashboard last
            TabBar.dashboardTab.tap()
            Profile.open()
            Profile.settingsButton.tap()
            ProfileSettings.landingPage.tap()
            cell.tap()
            app.find(label: "Settings", type: .button).tap()
            app.find(label: "Done", type: .button).tap()
            Profile.open()
            Profile.changeUserButton.tap()
            LoginStartSession.cell(entry).tap()
            cell.relatedTab.waitToExist()
            XCTAssertTrue(cell.relatedTab.isSelected)
        }
    }
}
