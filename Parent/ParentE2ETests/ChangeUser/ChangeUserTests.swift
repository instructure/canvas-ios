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
import XCTest

class ChangeUserTests: E2ETestCase {
    func testChangeUser() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let parent1 = seeder.createUser()
        let parent2 = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        seeder.enrollParent(parent1, in: course)
        seeder.enrollParent(parent2, in: course)
        seeder.addObservee(parent: parent1, student: student)
        seeder.addObservee(parent: parent2, student: student)

        // MARK: Get parent1 logged in, change user to parent2
        logInDSUser(parent1)
        let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
        XCTAssertTrue(profileButton.isVisible)

        profileButton.hit()
        let changeUserButton = ProfileHelper.changeUserButton.waitUntil(.visible)
        let usernameLabel = ProfileHelper.userNameLabel.waitUntil(.visible)
        XCTAssertTrue(changeUserButton.isVisible)
        XCTAssertTrue(usernameLabel.isVisible)
        XCTAssertEqual(usernameLabel.label, parent1.name)

        changeUserButton.hit()
        logInDSUser(parent2)
        XCTAssertTrue(profileButton.waitUntil(.visible).isVisible)

        profileButton.hit()
        XCTAssertTrue(usernameLabel.waitUntil(.visible).isVisible)
        XCTAssertEqual(usernameLabel.label, parent2.name)
    }
}
