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
        DashboardHelper.profileButton.hit()
        let userNameLabel = ProfileHelper.userNameLabel.waitUntil(.visible)
        XCTAssertEqual(userNameLabel.label, "Student One")
    }

    func xtestProfileLogsOut() {
        DashboardHelper.profileButton.hit()
        ProfileHelper.logOutButton.hit()
        LoginHelper.Start.findSchoolButton.waitUntil(.visible)
        let entry = user!.session!
        XCTAssertFalse(LoginHelper.LoginStartSession.cell(host: entry.baseURL.host!, userID: entry.userID).waitUntil(.vanish).isVisible)
    }

    func testPreviewUserFile() {
        DashboardHelper.profileButton.hit()
        ProfileHelper.filesButton.hit()

        FilesHelper.List.file(index: 0).hit()
        XCTAssertTrue(FilesHelper.Details.imageView.waitUntil(.visible).isVisible)
    }
}
