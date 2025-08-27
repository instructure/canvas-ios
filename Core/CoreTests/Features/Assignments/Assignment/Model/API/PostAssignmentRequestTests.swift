//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

class PostAssignmentRequestTests: XCTestCase {

    func testCreateAssignmentRequest() {
        let expectedBody = PostAssignmentRequest.Body.make(
            assignment_overrides: nil,
            description: nil,
            due_at: Date(),
            grading_type: .percent,
            lock_at: nil,
            name: nil,
            only_visible_to_overrides: nil,
            points_possible: 10,
            published: nil,
            unlock_at: nil
        )
        let request = PostAssignmentRequest(courseID: "1", body: expectedBody)

        XCTAssertEqual(request.path, "courses/1/assignments")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.body, expectedBody)
    }
}
