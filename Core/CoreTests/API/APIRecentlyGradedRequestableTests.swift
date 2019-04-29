//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import XCTest
@testable import Core

class APIRecentlyGradedRequestableTests: XCTestCase {
    func testPath() {
        let request = GetRecentlyGradedSubmissionsRequest(userID: "self")
        XCTAssertEqual(request.path, "users/self/graded_submissions")
    }

    func testQuery() {
        let request = GetRecentlyGradedSubmissionsRequest(userID: "self")
        XCTAssertEqual(request.query, [.value("per_page", "3"), .array("include", ["assignment"])])
    }
}
