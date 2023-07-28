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
        DashboardHelper.profileButton.hit()
        XCTAssertEqual(ProfileHelper.userNameLabel.waitUntil(condition: .visible).label, "Admin One")

        var actAsUserButton = ProfileHelper.actAsUserButton.waitUntil(condition: .visible)
        XCTAssertTrue(actAsUserButton.isVisible)

        actAsUserButton.tap()
        XCTAssertTrue(ActAsUserHelper.userIDField.waitUntil(condition: .visible).isVisible)
        XCTAssertTrue(ActAsUserHelper.domainField.waitUntil(condition: .visible).isVisible)

        let userIDField = ActAsUserHelper.userIDField.waitUntil(condition: .visible)
        userIDField.writeText(text: "613").swipeUp()
        let domainField = ActAsUserHelper.domainField.waitUntil(condition: .visible)
        if domainField.hasValue(value: "https://\(user!.host)") {
            domainField.cutText()
            domainField.writeText(text: "https://\(user!.host)").swipeUp()
        }
        actAsUserButton = ActAsUserHelper.actAsUserButton.waitUntil(condition: .visible)
        XCTAssertTrue(actAsUserButton.isVisible)

        actAsUserButton.tap()
        let userNameLabel = ProfileHelper.userNameLabel
        let profileButton = DashboardHelper.profileButton.waitUntil(condition: .visible)
        profileButton.actionUntilElementCondition(action: .tap, element: userNameLabel, condition: .visible)
        XCTAssertEqual(userNameLabel.label, "Student One")

        let endActAsUserButton = ActAsUserHelper.endActAsUserButton.waitUntil(condition: .visible)
        XCTAssertTrue(endActAsUserButton.isVisible)

        endActAsUserButton.tap()
        ActAsUserHelper.okAlertButton.hit()
        endActAsUserButton.waitUntil(condition: .vanish)
        XCTAssertFalse(endActAsUserButton.isVisible)

        profileButton.waitUntil(condition: .visible)
        profileButton.actionUntilElementCondition(action: .tap, element: userNameLabel, condition: .visible)
        XCTAssertEqual(userNameLabel.label, "Admin One")
    }
}
