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

    func testGetSubmissionsRequest() {
        XCTAssertEqual(
            GetSubmissionsRequest(context: .course("1"), assignmentID: "2", grouped: nil, include: []).path,
            "courses/1/assignments/2/submissions"
        )
        XCTAssertEqual(GetSubmissionsRequest(context: .course("1"), assignmentID: "2", grouped: false, include: []).query, [
            .perPage(100),
            .include([]),
            .bool("grouped", false)
        ])
        XCTAssertEqual(GetSubmissionsRequest(context: .course("1"), assignmentID: "2", grouped: true, include: []).query, [
            .perPage(100),
            .include([]),
            .bool("grouped", true)
        ])
        XCTAssertEqual(GetSubmissionsRequest(context: .course("1"), assignmentID: "2", grouped: true, include: GetSubmissionsRequest.Include.allCases).query, [
            .perPage(100),
            .include([
                "rubric_assessment",
                "submission_comments",
                "submission_history",
                "total_scores",
                "user",
                "group",
                "assignment"
            ]),
            .bool("grouped", true)
        ])
    }
}
