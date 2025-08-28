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

class GetSubmissionsRequestTests: CoreTestCase {

    func test_path() {
        let testee = GetSubmissionsRequest(context: .course("1"), assignmentID: "2")

        XCTAssertEqual(testee.path, "courses/1/assignments/2/submissions")
    }

    func test_pagination() {
        let testee = GetSubmissionsRequest(context: .course("1"), assignmentID: "2")

        XCTAssert(testee.query.contains(.perPage(100)))
    }

    func test_grouped() {
        var testee = GetSubmissionsRequest(context: .course("1"), assignmentID: "2", grouped: false)
        XCTAssert(testee.query.contains(.bool("grouped", false)))

        testee = GetSubmissionsRequest(context: .course("1"), assignmentID: "2", grouped: true)
        XCTAssert(testee.query.contains(.bool("grouped", true)))
    }

    func test_includes() {
        let testee = GetSubmissionsRequest(context: .course("1"), assignmentID: "2", include: GetSubmissionsRequest.Include.allCases)

        XCTAssert(
            testee.query.contains(
                .include([
                    "assignment",
                    "group",
                    "rubric_assessment",
                    "sub_assignment_submissions",
                    "submission_comments",
                    "submission_history",
                    "total_scores",
                    "user"
                ])
            )
        )
    }
}
