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

import XCTest
@testable import Core

final class PutPlannerNoteRequestTests: XCTestCase {

    private enum TestConstants {
        static let title = "some title"
        static let details = "some details"
        static let todoDate = Clock.now
        static let courseId = "some courseId"
    }

    func testProperties() {
        let testee = PutPlannerNoteRequest(id: "42", body: .make())

        XCTAssertEqual(testee.method, .put)
        XCTAssertEqual(testee.path, "planner_notes/42")
    }

    func testBodyEncoding() throws {
        let testee = PutPlannerNoteRequest.Body.make(
            title: TestConstants.title,
            details: TestConstants.details,
            todo_date: TestConstants.todoDate,
            course_id: TestConstants.courseId
        )

        let json = try testee.encodeToJson()

        XCTAssertEqual(json.contains(jsonKey: "title", value: TestConstants.title), true)
        XCTAssertEqual(json.contains(jsonKey: "details", value: TestConstants.details), true)
        XCTAssertEqual(json.contains(jsonKey: "todo_date", value: TestConstants.todoDate.isoString()), true)
        XCTAssertEqual(json.contains(jsonKey: "course_id", value: TestConstants.courseId), true)
    }

    func testBodyEncodingShouldNotSkipNils() throws {
        let testee = PutPlannerNoteRequest.Body.make(
            details: nil,
            course_id: nil
        )

        let json = try testee.encodeToJson()

        XCTAssertEqual(json.contains(jsonKey: "details", value: nil), true)
        XCTAssertEqual(json.contains(jsonKey: "course_id", value: nil), true)
    }
}
