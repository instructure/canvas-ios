//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

class AssignmentDueDateItemViewModelTests: CoreTestCase {

    func testNoDueDate() {
        let apiAssignmentDate = APIAssignmentDate.make(
            id: "1")
        let item = AssignmentDate.save(apiAssignmentDate, assignmentID: "1", in: databaseClient)
        let testee = AssignmentDueDateItemViewModel(item: item)

        XCTAssertEqual(testee.assignee, "Everyone")
        XCTAssertEqual(testee.title, "No Due Date")
    }

    func testDueDate() {
        let apiAssignmentDate = APIAssignmentDate.make(
            id: "1",
            due_at: Date(fromISOString: "2022-12-25T14:24:37Z")!
        )
        let item = AssignmentDate.save(apiAssignmentDate, assignmentID: "1", in: databaseClient)
        let testee = AssignmentDueDateItemViewModel(item: item)

        XCTAssertEqual(testee.title, "Due \(Date(fromISOString: "2022-12-25T14:24:37Z")!.dateTimeString)")
    }

    func testFromUntilDates() {
        let apiAssignmentDate = APIAssignmentDate.make(
            id: "1",
            unlock_at: Date(fromISOString: "2022-12-06T14:24:37Z")!,
            lock_at: Date(fromISOString: "2022-12-25T14:24:37Z")!
        )
        let item = AssignmentDate.save(apiAssignmentDate, assignmentID: "1", in: databaseClient)
        let testee = AssignmentDueDateItemViewModel(item: item)

        XCTAssertEqual(testee.from, Date(fromISOString: "2022-12-06T14:24:37Z")?.dateTimeString)
        XCTAssertEqual(testee.until, Date(fromISOString: "2022-12-25T14:24:37Z")?.dateTimeString)
        XCTAssertNil(testee.fromEmptyAccessibility)
        XCTAssertNil(testee.untilEmptyAccessibility)
    }

    func testAccessibility() {
        let apiAssignmentDate = APIAssignmentDate.make(
            id: "1")
        let item = AssignmentDate.save(apiAssignmentDate, assignmentID: "1", in: databaseClient)
        let testee = AssignmentDueDateItemViewModel(item: item)

        XCTAssertEqual(testee.from, "--")
        XCTAssertEqual(testee.until, "--")
        XCTAssertEqual(testee.fromEmptyAccessibility, "No available from date set.")
        XCTAssertEqual(testee.untilEmptyAccessibility, "No available until date set.")
    }
}
