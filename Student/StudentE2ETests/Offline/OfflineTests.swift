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

class OfflineTests: E2ETestCase {
    override func tearDown() {
        // In case the tests fail at a point where the internet connection is turned off
        goOnline()
    }

    func testNetworkConnectionLose() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Go offline and check app behaviour
        let isOffline = goOffline()
        var offlineLine = DashboardHelper.offlineLine.waitUntil(.visible)
        let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
        XCTAssertTrue(isOffline)
        XCTAssertTrue(offlineLine.isVisible)
        XCTAssertTrue(profileButton.isVisible)

        profileButton.hit()
        offlineLine = ProfileHelper.offlineLine.waitUntil(.visible)
        let offlineLabel = ProfileHelper.offlineLabel.waitUntil(.visible)
        let networkStatusButton = ProfileHelper.networkButton.waitUntil(.visible)
        XCTAssertTrue(offlineLine.isVisible)
        XCTAssertTrue(offlineLabel.isVisible)
        XCTAssertTrue(networkStatusButton.isVisible)
        XCTAssertTrue(networkStatusButton.hasLabel(label: "Disconnected"))

        // MARK: Go back online and check app behaviour
        profileButton.forceTap()
        let isOnline = goOnline()
        offlineLine = DashboardHelper.offlineLine.waitUntil(.vanish)
        XCTAssertTrue(isOnline)
        XCTAssertTrue(offlineLine.isVanished)
        XCTAssertTrue(profileButton.waitUntil(.visible).isVisible)

        profileButton.hit()
        offlineLine = ProfileHelper.offlineLine.waitUntil(.vanish)
        XCTAssertTrue(offlineLine.isVanished)
        XCTAssertTrue(offlineLabel.waitUntil(.vanish).isVanished)
        XCTAssertTrue(networkStatusButton.isVisible)
        XCTAssertTrue(networkStatusButton.hasLabel(label: "Connected via Wifi"))
    }
}
