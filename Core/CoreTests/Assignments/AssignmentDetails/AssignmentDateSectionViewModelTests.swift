//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

class AssignmentDateSectionViewModelTests: CoreTestCase {
    func testProperties() {
        let dueAt = Date()
        let lockAt = Date(timeIntervalSinceNow: 100)
        let unlockAt = Date(timeIntervalSinceNow: -100)
        let apiAssignment = APIAssignment.make(due_at: dueAt, lock_at: lockAt, unlock_at: unlockAt)
        let assignment = Assignment.make(from: apiAssignment)
        let testee = AssignmentDateSectionViewModel(assignment: assignment)

        XCTAssertTrue(testee.isButton)
        XCTAssertEqual(testee.hasMultipleDueDates, false)
        XCTAssertEqual(testee.dueAt, dueAt)
        XCTAssertEqual(testee.lockAt, lockAt)
        XCTAssertEqual(testee.unlockAt, unlockAt)
        XCTAssertEqual(testee.forText, "-")
    }

    func testAllDatesOnly() {
        let dueAt = Date()
        let lockAt = Date(timeIntervalSinceNow: 100)
        let unlockAt = Date(timeIntervalSinceNow: -100)
        let title = "Test"
        let dates = [APIAssignmentDate.make(base: false, title: title, due_at: dueAt, unlock_at: unlockAt, lock_at: lockAt)]
        let apiAssignment = APIAssignment.make(all_dates: dates)
        let assignment = Assignment.make(from: apiAssignment)
        let testee = AssignmentDateSectionViewModel(assignment: assignment)

        XCTAssertEqual(testee.dueAt, dueAt)
        XCTAssertEqual(testee.lockAt, lockAt)
        XCTAssertEqual(testee.unlockAt, unlockAt)
        XCTAssertNotNil(testee.forText, title)
    }

    func testAllDatesandDueDate() {
        let dueAt = Date()
        let lockAt = Date(timeIntervalSinceNow: 100)
        let unlockAt = Date(timeIntervalSinceNow: -100)
        let title = "Test"
        let dates = [APIAssignmentDate.make(base: false, title: title, due_at: dueAt, unlock_at: unlockAt, lock_at: lockAt)]
        let assignmentDueAt = Date(timeIntervalSinceNow: 200)
        let assignmentLockAt = Date(timeIntervalSinceNow: 300)
        let assignmentUnlockAt = Date(timeIntervalSinceNow: 400)
        let apiAssignment = APIAssignment.make(all_dates: dates, due_at: assignmentDueAt, lock_at: assignmentLockAt, unlock_at: assignmentUnlockAt)
        let assignment = Assignment.make(from: apiAssignment)
        let testee = AssignmentDateSectionViewModel(assignment: assignment)

        XCTAssertEqual(testee.dueAt, assignmentDueAt)
        XCTAssertEqual(testee.lockAt, lockAt)
        XCTAssertEqual(testee.unlockAt, unlockAt)
        XCTAssertNotNil(testee.forText, title)
    }

    func testBaseTitle() {
        let dates = [APIAssignmentDate.make(base: true)]
        let apiAssignment = APIAssignment.make(all_dates: dates)
        let assignment = Assignment.make(from: apiAssignment)
        let testee = AssignmentDateSectionViewModel(assignment: assignment)

        XCTAssertNotNil(testee.forText, "Everyone")
    }

    func testRoute() {
        let assignment = Assignment.make()
        let testee = AssignmentDateSectionViewModel(assignment: assignment)

        testee.buttonTapped(router: router, viewController: WeakViewController(UIViewController()))

        XCTAssertTrue(router.lastRoutedTo(URL(string: "courses/1/assignments/1/due_dates")!))
    }
}
