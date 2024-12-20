//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

@testable import Core
import XCTest

class DashboardInvitationNameTests: XCTestCase {

    func testEmptyCourse() {
        XCTAssertEqual(String.dashboardInvitationName(courseName: nil, sectionName: nil), "")
    }

    func testCourseNameOnly() {
        XCTAssertEqual(String.dashboardInvitationName(courseName: "course name", sectionName: nil), "course name")
        XCTAssertEqual(String.dashboardInvitationName(courseName: "course name", sectionName: ""), "course name")
        XCTAssertEqual(String.dashboardInvitationName(courseName: "course name", sectionName: "course name"), "course name")
    }

    func testSectionNameOnly() {
        XCTAssertEqual(String.dashboardInvitationName(courseName: nil, sectionName: "section name"), ", section name")
    }

    func testCourseAndSectionNames() {
        XCTAssertEqual(String.dashboardInvitationName(courseName: "course name", sectionName: "section name"), "course name, section name")
    }
}
