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

class ConferencesTests: E2ETestCase {
    typealias Helper = ConferencesHelper
    typealias DetailsHelper = Helper.Details

    func testConferences() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        let conference = Helper.createConference(course: course)

        // MARK: Get the user logged in, navigate to Conferences
        logInDSUser(student)
        Helper.navigateToConferences(course: course)
        let navBar = Helper.navBar.waitUntil(.visible)
        let newConferencesHeader = Helper.newConferencesHeader.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(newConferencesHeader.isVisible)

        // MARK: Check elements of Conferences
        let conferenceTitle = Helper.cellTitle(conference: conference).waitUntil(.visible)
        let conferenceStatus = Helper.cellStatus(conference: conference).waitUntil(.visible)
        let conferenceDetails = Helper.cellDetails(conference: conference).waitUntil(.visible)
        XCTAssertTrue(conferenceTitle.isVisible)
        XCTAssertTrue(conferenceStatus.isVisible)
        XCTAssertTrue(conferenceDetails.isVisible)
        XCTAssertTrue(conferenceTitle.hasLabel(label: conference.title))
        XCTAssertTrue(conferenceStatus.hasLabel(label: "Not Started"))
        XCTAssertTrue(conferenceDetails.hasLabel(label: conference.description))

        // MARK: Check elements of Conference Details
        conferenceTitle.hit()
        let detailsTitle = DetailsHelper.title.waitUntil(.visible)
        let detailsStatus = DetailsHelper.status.waitUntil(.visible)
        let detailsDetails = DetailsHelper.details.waitUntil(.visible)
        XCTAssertTrue(detailsTitle.isVisible)
        XCTAssertTrue(detailsStatus.isVisible)
        XCTAssertTrue(detailsDetails.isVisible)
        XCTAssertTrue(detailsTitle.hasLabel(label: conference.title))
        XCTAssertTrue(detailsStatus.hasLabel(label: "Not Started"))
        XCTAssertTrue(detailsDetails.hasLabel(label: conference.description))
    }
}
