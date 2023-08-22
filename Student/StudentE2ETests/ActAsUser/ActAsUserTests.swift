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
        let profileButton = DashboardHelper.profileButton.hit()
        let userNameLabel = ProfileHelper.userNameLabel.waitUntil(.visible)
        XCTAssertTrue(userNameLabel.waitUntil(.visible).hasLabel(label: "Admin One"))

        var actAsUserButton = ProfileHelper.actAsUserButton.waitUntil(.visible)
        XCTAssertTrue(actAsUserButton.isVisible)

        actAsUserButton.hit()
        let userIDField = ActAsUserHelper.userIDField.waitUntil(.visible)
        XCTAssertTrue(userIDField.isVisible)

        userIDField.writeText(text: "613")
        let domainField = ActAsUserHelper.domainField.waitUntil(.visible)
        if !domainField.hasValue(value: "https://\(user!.host)") {
            domainField.cutText()
            domainField.writeText(text: "https://\(user!.host)")
        }
        actAsUserButton = ActAsUserHelper.actAsUserButton
        actAsUserButton.actionUntilElementCondition(action: .swipeUp(), condition: .visible)
        XCTAssertTrue(actAsUserButton.isVisible)

        actAsUserButton.hit()
        DashboardHelper.courseCard(courseId: "262").waitUntil(.visible)
        profileButton.hit()
        XCTAssertTrue(userNameLabel.waitUntil(.visible).hasLabel(label: "Student One"))

        let endActAsUserButton = ActAsUserHelper.endActAsUserButton.waitUntil(.visible)
        XCTAssertTrue(endActAsUserButton.isVisible)

        endActAsUserButton.hit()
        ActAsUserHelper.okAlertButton.hit()
        app.find(label: "No Courses", type: .staticText).waitUntil(.visible)
        XCTAssertFalse(endActAsUserButton.waitUntil(.vanish).isVisible)

        profileButton.hit()
        XCTAssertTrue(userNameLabel.waitUntil(.visible).hasLabel(label: "Admin One"))
    }
}
