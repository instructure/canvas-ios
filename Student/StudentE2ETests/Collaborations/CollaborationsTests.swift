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

class CollaborationsTests: E2ETestCase {
    func testCollaborationsOpensLinkInBrowser() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, navigate to Collaborations
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        courseCard.hit()
        let collaborationsButton = CourseDetailsHelper.cell(type: .collaborations).waitUntil(.visible)
        XCTAssertTrue(collaborationsButton.isVisible)

        collaborationsButton.hit()

        // MARK: Check if browser opens with the correct URL
        XCTAssertTrue(SafariAppHelper.safariApp.wait(for: .runningForeground, timeout: 10))
        XCTAssertTrue(SafariAppHelper.browserURL.contains("\(user.host)/courses/\(course.id)/collaborations"))
    }
}
