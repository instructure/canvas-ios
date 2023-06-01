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

class ActAsUserTests: CoreUITestCase {
    // TODO: Make it use DataSeeder
    override var user: UITestUser? { return .readAdmin1 }

    func testActAsUser() {
        Profile.open()
        XCTAssertEqual(Profile.userNameLabel.label(), "Admin One")
        XCTAssertTrue(Profile.actAsUserButton.waitToExist().isVisible)

        Profile.actAsUserButton.tap()
        XCTAssertTrue(ActAsUser.userIDField.waitToExist().isVisible)
        XCTAssertTrue(ActAsUser.domainField.waitToExist().isVisible)

        ActAsUser.userIDField.typeText("613").swipeUp()
        if ActAsUser.domainField.value() != "https://\(user!.host)" {
            ActAsUser.domainField.cutText()
            ActAsUser.domainField.typeText("https://\(user!.host)").swipeUp()
        }
        XCTAssertTrue(ActAsUser.actAsUserButton.waitToExist().isVisible)

        ActAsUser.actAsUserButton.tap()
        Profile.open()
        XCTAssertEqual(Profile.userNameLabel.label(), "Student One")

        Profile.close()
        XCTAssertTrue(ActAsUser.endActAsUserButton.waitToExist().isVisible)

        ActAsUser.endActAsUserButton.tap()
        ActAsUser.okAlertButton.tap()
        ActAsUser.endActAsUserButton.waitToVanish()
        XCTAssertFalse(ActAsUser.endActAsUserButton.isVisible)

        Profile.open()
        XCTAssertEqual(Profile.userNameLabel.label(), "Admin One")

        Profile.close()
    }
}
