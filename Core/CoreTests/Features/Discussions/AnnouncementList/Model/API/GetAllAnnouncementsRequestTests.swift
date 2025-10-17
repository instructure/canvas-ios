//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
@testable import Core

class GetAllAnnouncementsRequestTests: XCTestCase {
    func testPath() {
        let request = GetAllAnnouncementsRequest(contextCodes: ["1", "2"])
        XCTAssertEqual(request.method, .get)
        XCTAssertEqual(request.path, "announcements")
    }

    func testMinimalQuery() {
        let request = GetAllAnnouncementsRequest(contextCodes: ["1", "2"])
        XCTAssertEqual(request.query, [
            .array("context_codes", ["1", "2"]),
            .optionalBool("active_only", nil),
            .optionalBool("latest_only", nil),
            .optionalValue("start_date", nil),
            .optionalValue("end_date", nil)
        ])
    }

    func testExhaustiveQuery() {
        let request = GetAllAnnouncementsRequest(contextCodes: ["1", "2"], activeOnly: true, latestOnly: false)
        XCTAssertEqual(request.query, [
            .array("context_codes", ["1", "2"]),
            .optionalBool("active_only", true),
            .optionalBool("latest_only", false),
            .optionalValue("start_date", nil),
            .optionalValue("end_date", nil)
        ])
    }
}
