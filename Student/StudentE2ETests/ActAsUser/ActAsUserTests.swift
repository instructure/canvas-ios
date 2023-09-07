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

import TestsFoundation

class ActAsUserTests: E2ETestCase {
    func testActAsUser() {
        // MARK: Seed the usual stuff
        let admin = seeder.createAdminUser()
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, check "Act As User"
        logInDSUser(admin)

        let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
        XCTAssertTrue(profileButton.isVisible)

        profileButton.hit()
        let userNameLabel = ProfileHelper.userNameLabel.waitUntil(.visible)
        XCTAssertTrue(userNameLabel.hasLabel(label: admin.name))

        var actAsUserButton = ProfileHelper.actAsUserButton.waitUntil(.visible)
        XCTAssertTrue(actAsUserButton.isVisible)

        actAsUserButton.hit()
        let userIDField = ActAsUserHelper.userIDField.waitUntil(.visible)
        XCTAssertTrue(userIDField.isVisible)

        userIDField.writeText(text: student.id)
        let domainField = ActAsUserHelper.domainField.waitUntil(.visible)
        if !domainField.hasValue(value: "https://\(user.host)") {
            domainField.cutText()
            domainField.writeText(text: "https://\(user.host)")
        }
        actAsUserButton = ActAsUserHelper.actAsUserButton
        actAsUserButton.actionUntilElementCondition(action: .swipeUp(), condition: .visible)
        XCTAssertTrue(actAsUserButton.isVisible)

        actAsUserButton.hit()
        DashboardHelper.courseCard(course: course).waitUntil(.visible)
        profileButton.hit()
        userNameLabel.waitUntil(.visible)
        XCTAssertTrue(userNameLabel.isVisible)
        XCTAssertTrue(userNameLabel.hasLabel(label: student.name))

        let endActAsUserButton = ActAsUserHelper.endActAsUserButton.waitUntil(.visible)
        XCTAssertTrue(endActAsUserButton.isVisible)

        endActAsUserButton.hit()
        ActAsUserHelper.okAlertButton.hit()
        app.find(label: "No Courses", type: .staticText).waitUntil(.visible)
        XCTAssertFalse(endActAsUserButton.waitUntil(.vanish).isVisible)

        profileButton.hit()
        userNameLabel.waitUntil(.visible)
        XCTAssertTrue(userNameLabel.isVisible)
        XCTAssertTrue(userNameLabel.hasLabel(label: admin.name))
    }
}
