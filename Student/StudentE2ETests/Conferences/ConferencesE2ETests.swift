//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import Foundation

import XCTest
@testable import TestsFoundation
@testable import Core

class ConferencesE2ETests: CoreUITestCase {
    lazy var inProgress = ConferencesList.Cell(id: "520")
    lazy var concluded = ConferencesList.Cell(id: "548")

    override func setUp() {
        super.setUp()

        Dashboard.courseCard(id: "5586").tap()
        CourseNavigation.conferences.tap()
    }

    func testConferenceList() {
        let concludedHeader = ConferencesList.header(forSection: 1)
        XCTAssertEqual(concludedHeader.label(), "Concluded Conferences")

        // make sure conferences are on correct side of header
        XCTAssertLessThan(inProgress.title.frame().origin.y, concludedHeader.frame().origin.y)
        XCTAssertGreaterThan(concluded.title.frame().origin.y, concludedHeader.frame().origin.y)

        XCTAssertEqual(inProgress.title.label(), "The Eternal Conference")
        XCTAssertEqual(inProgress.status.label(), "In Progress")
        XCTAssertEqual(inProgress.details.label(), "It never ends...")

        XCTAssert(concluded.status.label().contains("Concluded Apr 17"))
    }

    func testInProgressConferenceDetails() {
        inProgress.title.tap()

        ConferenceDetails.join.waitToExist()
        XCTAssertEqual(ConferenceDetails.title.label(), "The Eternal Conference")
        XCTAssert(ConferenceDetails.status.label().contains("In Progress | Started Apr 8, 2020 at "))
        XCTAssertEqual(ConferenceDetails.details.label(), "It never ends...")
    }
}
