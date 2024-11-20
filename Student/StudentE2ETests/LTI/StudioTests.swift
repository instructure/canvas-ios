//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

class StudioTests: E2ETestCase {

    func testStudioAvailabilityAndEmbeddedVideo() throws {
        try XCTSkipIf(true, "Skipped because of a recent Studio change.")
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = LTIHelper.Studio.course
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in
        logInDSUser(student)
        let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
        XCTAssertTrue(profileButton.isVisible)

        // MARK: Open Profile menu, check Studio availability
        profileButton.hit()
        let studioButton = ProfileHelper.studioButton.waitUntil(.visible)
        XCTAssertTrue(studioButton.isVisible)

        studioButton.hit()
        let doneButton = LTIHelper.Studio.doneButton.waitUntil(.visible)
        let logoLink = LTIHelper.Studio.studioLogoLink.waitUntil(.visible)
        let myLibraryLabel = LTIHelper.Studio.myLibraryLabel.waitUntil(.visible)
        XCTAssertTrue(doneButton.isVisible)
        XCTAssertTrue(logoLink.isVisible)
        XCTAssertTrue(myLibraryLabel.isVisible)

        doneButton.hit()

        // MARK: Navigate to Pages, Check page with embedded video
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        courseCard.hit()
        let pageButton = CourseDetailsHelper.cell(type: .pages).waitUntil(.visible)
        XCTAssertTrue(pageButton.isVisible)

        pageButton.hit()
        let frontPageButton = PagesHelper.frontPage.waitUntil(.visible)
        XCTAssertTrue(frontPageButton.isVisible)

        frontPageButton.hit()
        let titleLabel = LTIHelper.Studio.Embedded.testVideoTitle.waitUntil(.visible)
        let playButton = LTIHelper.Studio.Embedded.playButton.waitUntil(.visible)
        XCTAssertTrue(titleLabel.isVisible)
        XCTAssertTrue(playButton.isVisible)
    }
}
