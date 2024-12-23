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

import Core
import XCTest

class GetGlobalNavExternalToolsPlacementsTests: XCTestCase {

    func testAllowedGlobalLTIDomains() {
        XCTAssertEqual(HelpLinkEnrollment.observer.allowedGlobalLTIDomains,
                       ["app.masteryconnect.com"])
        XCTAssertEqual(HelpLinkEnrollment.admin.allowedGlobalLTIDomains,
                       ["arc.instructure.com", "gauge.instructure.com", "app.masteryconnect.com"])
        XCTAssertEqual(HelpLinkEnrollment.student.allowedGlobalLTIDomains,
                       ["arc.instructure.com", "gauge.instructure.com", "app.masteryconnect.com"])
        XCTAssertEqual(HelpLinkEnrollment.teacher.allowedGlobalLTIDomains,
                       ["arc.instructure.com", "gauge.instructure.com", "app.masteryconnect.com"])
        XCTAssertEqual(HelpLinkEnrollment.unenrolled.allowedGlobalLTIDomains,
                       ["arc.instructure.com", "gauge.instructure.com"])
        XCTAssertEqual(HelpLinkEnrollment.user.allowedGlobalLTIDomains,
                       ["arc.instructure.com", "gauge.instructure.com"])
    }
}
