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
@testable import CoreUITests

class ActAsUserE2ETests: CoreUITestCase {
    override var user: UITestUser? { return .readAdmin1 }
    override var abstractTestClass: CoreUITestCase.Type { return ActAsUserE2ETests.self }

    func testActAsUser() {
        Profile.open()
        XCTAssertEqual(Profile.userNameLabel.label(), "Admin One")
        Profile.actAsUserButton.tap()
        ActAsUser.userIDField.typeText("613").swipeUp()
        XCTAssertEqual(ActAsUser.domainField.value(), "https://\(user!.host)")
        ActAsUser.actAsUserButton.tap()

        Dashboard.courseCard(id: "263").waitToExist()
        Profile.open()
        XCTAssertEqual(Profile.userNameLabel.label(), "Student One")
        Profile.close()

        ActAsUser.endActAsUserButton.tap()
        app.alerts.buttons["OK"].tap()
        ActAsUser.endActAsUserButton.waitToVanish()

        Profile.open()
        XCTAssertEqual(Profile.userNameLabel.label(), "Admin One")
        Profile.close()
    }
}
