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

class APICalendarEventSubAssignmentTests: XCTestCase {

    func test_make_createsWithDefaults() {
        // WHEN
        let assignment = APICalendarEventSubAssignment.make()

        // THEN
        XCTAssertEqual(assignment.id, "")
        XCTAssertEqual(assignment.course_id, "")
        XCTAssertEqual(assignment.submission_types, [.discussion_topic])
        XCTAssertNil(assignment.sub_assignment_tag)
        XCTAssertNil(assignment.discussion_topic)
        XCTAssertNil(assignment.html_url)
    }

    func test_make_createsWithCustomValues() {
        let url = URL(string: "https://custom.com")

        // WHEN
        let assignment = APICalendarEventSubAssignment.make(
            id: "custom_id",
            course_id: "custom_course",
            submission_types: [.online_quiz, .online_upload],
            sub_assignment_tag: "custom_tag",
            html_url: url
        )

        // THEN
        XCTAssertEqual(assignment.id, "custom_id")
        XCTAssertEqual(assignment.course_id, "custom_course")
        XCTAssertEqual(assignment.submission_types, [.online_quiz, .online_upload])
        XCTAssertEqual(assignment.sub_assignment_tag, "custom_tag")
        XCTAssertEqual(assignment.html_url, url)
    }
}
