//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import Student
@testable import Core

class AssignmentListModelTests: StudentTestCase {

    var model: AssignmentListModel!

    override func setUp() {
        super.setUp()
        model = AssignmentListModel()
    }

    func testEqualityInDuplicateGroups() {
        let set = NSMutableOrderedSet()
        let g = APIAssignmentListGroup.make(id: "1", name: "a")
        let h = APIAssignmentListGroup.make(id: "1", name: "b")
        set.add(g)
        set.add(h)
        XCTAssertEqual(set.count, 1)
    }

    func testAddingResponse2() {
        let a = APIAssignmentListAssignment.make()
        let b = APIAssignmentListAssignment.make(id: "2")
        let groups = [APIAssignmentListGroup.make(assignments: [a, b])]
        let response = APIAssignmentListResponse.make(groups: groups)

        model.addResponse(response: response)
        model.addResponse(response: response)
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(model.assignmentCount(forSection: 0), 2)
    }

    func testAddCursor() {
        let a = APIAssignmentListAssignment.make()
        let groups = [APIAssignmentListGroup.make(assignments: [a], pageInfo: .make(endCursor: "aa", hasNextPage: false))]
        let response = APIAssignmentListResponse.make(groups: groups)

        model.addResponse(response: response)

        let cursor1 = model.dequeueCursor(forSection: 0)

        XCTAssertEqual(cursor1, "aa")

        let cursor2 = model.dequeueCursor(forSection: 0)
        XCTAssertNil(cursor2)
    }

    func testAssignmentFor() {
        let a = APIAssignmentListAssignment.make(name: "A")
        let b = APIAssignmentListAssignment.make(id: "2", name: "B")
        let groups = [APIAssignmentListGroup.make(assignments: [a]), APIAssignmentListGroup.make(id: "2", assignments: [b])]
        let response = APIAssignmentListResponse.make(groups: groups)

        model.addResponse(response: response)

        XCTAssertEqual(model.assignment(for: IndexPath(row: 0, section: 0))?.name, "A")
        XCTAssertEqual(model.assignment(for: IndexPath(row: 0, section: 1))?.name, "B")
        XCTAssertNil(model.assignment(for: IndexPath(row: 0, section: 2)))
    }

    func testHasNext() {
        let a = APIAssignmentListAssignment.make()
        let b = APIAssignmentListAssignment.make(id: "2")
        let groups = [
            APIAssignmentListGroup.make(assignments: [a], pageInfo: .make(endCursor: "aa", hasNextPage: false)),
            APIAssignmentListGroup.make(id: "2", assignments: [b]),
        ]
        let response = APIAssignmentListResponse.make(groups: groups)

        model.addResponse(response: response)

        XCTAssertTrue( model.hasNext(forSection: 0) )
        XCTAssertFalse( model.hasNext(forSection: 1) )
    }

    func testAssignmentCount() {
        let a = APIAssignmentListAssignment.make(name: "A")
        let b = APIAssignmentListAssignment.make(id: "2", name: "B")
        let c = APIAssignmentListAssignment.make(id: "3", name: "C")
        let groups = [APIAssignmentListGroup.make(assignments: [a]), APIAssignmentListGroup.make(id: "2", assignments: [b, c])]
        let response = APIAssignmentListResponse.make(groups: groups)

        model.addResponse(response: response)

        XCTAssertEqual(model.assignmentCount(forSection: 0), 1)
        XCTAssertEqual(model.assignmentCount(forSection: 1), 2)
        XCTAssertEqual(model.assignmentCount(forSection: 100), 0)
    }
}
