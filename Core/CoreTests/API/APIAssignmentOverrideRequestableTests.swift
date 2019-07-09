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

import Foundation
import XCTest
@testable import Core

class APIAssignmentOverrideRequestableTests: XCTestCase {
    func testCreateAssignmentOverrideRequest() {
        let override = CreateAssignmentOverrideRequest.Body.AssignmentOverride(title: "a")
        let expectedBody = CreateAssignmentOverrideRequest.Body(assignment_override: override)
        let request = CreateAssignmentOverrideRequest(courseID: "1", assignmentID: "2", body: expectedBody)

        XCTAssertEqual(request.path, "courses/1/assignments/2/overrides")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.body, expectedBody)
    }
}
