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

import Foundation
import XCTest
@testable import Core

class GetSubmissionsForStudentRequestTests: CoreTestCase {

    func test_path() {
        let testee = GetSubmissionsForStudentRequest(context: .course("1"), studentID: "123")

        XCTAssertEqual(testee.path, "courses/1/students/submissions")
    }

    func test_query() {
        let testee = GetSubmissionsForStudentRequest(context: .course("1"), studentID: "123")
        XCTAssertEqual(testee.query, [
            .perPage(100),
            .array("student_ids", ["123"]),
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
        ])
    }
}
