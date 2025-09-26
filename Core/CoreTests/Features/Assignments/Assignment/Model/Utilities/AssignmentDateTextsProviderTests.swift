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
import TestsFoundation

final class AssignmentDateTextsProviderTests: CoreTestCase {

    private static let testData = (
        dueDate1: Date.make(year: 2025, month: 9, day: 15),
        dueDate2: Date.make(year: 2025, month: 9, day: 20),
        dueDate3: Date.make(year: 2025, month: 9, day: 18),
        lockDate: Date.make(year: 2025, month: 9, day: 22)
    )
    private lazy var testData = Self.testData

    private var testee: AssignmentDateTextsProviderLive!

    override func setUp() {
        super.setUp()
        testee = .init()
    }

    override func tearDown() {
        testee = nil
        Clock.reset()
        super.tearDown()
    }

    // MARK: - Due dates for not Teacher app

    func test_dueDates_withNoSubAssignments_shouldHaveSingleItem() {
        // WHEN available
        Clock.mockNow(testData.lockDate.addDays(-1))
        var assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            lock_at: testData.lockDate,
            has_sub_assignments: false
        ))
        var dueDates = testee.summarizedDueDates(for: assignment)
        // THEN
        XCTAssertEqual(dueDates.count, 1)
        XCTAssertEqual(dueDates.first, DueDateFormatter.dateText(testData.dueDate1))

        // WHEN closed
        Clock.mockNow(testData.lockDate.addDays(1))
        assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            lock_at: testData.lockDate,
            has_sub_assignments: false
        ))
        dueDates = testee.summarizedDueDates(for: assignment)
        // THEN
        XCTAssertEqual(dueDates.count, 1)
        XCTAssertEqual(dueDates.first, DueDateFormatter.availabilityClosedText)

        // WHEN multiple in Student/Parent app
        assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_overrides: true,
            has_sub_assignments: false
        ))
        dueDates = testee.summarizedDueDates(for: assignment)
        // THEN
        XCTAssertEqual(dueDates.count, 1)
        XCTAssertEqual(dueDates.first, DueDateFormatter.dateText(testData.dueDate1))
    }

    func test_dueDates_withSubAssignmentsAndNoDueDate_shouldHaveMultipleItems() {
        // WHEN one is nil
        var assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", due_at: testData.dueDate2),
                .make(tag: "tag2", due_at: nil)
            ]
        ))
        var dueDates = testee.summarizedDueDates(for: assignment)
        // THEN
        XCTAssertEqual(dueDates.count, 2)
        XCTAssertEqual(dueDates.first, DueDateFormatter.dateText(testData.dueDate2))
        XCTAssertEqual(dueDates.last, DueDateFormatter.noDueDateText)

        // WHEN all are nil
        assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", due_at: nil),
                .make(tag: "tag2", due_at: nil)
            ]
        ))
        dueDates = testee.summarizedDueDates(for: assignment)
        // THEN
        XCTAssertEqual(dueDates.count, 2)
        XCTAssertEqual(dueDates.first, DueDateFormatter.noDueDateText)
        XCTAssertEqual(dueDates.last, DueDateFormatter.noDueDateText)
    }

    func test_dueDates_withSubAssignmentsAndBeforeLockDate_shouldHaveMultipleItems() {
        Clock.mockNow(testData.lockDate.addDays(-1))

        let assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            lock_at: testData.lockDate,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", due_at: testData.dueDate2, lock_at: testData.lockDate),
                .make(tag: "tag2", due_at: testData.dueDate3, lock_at: testData.lockDate)
            ]
        ))
        let dueDates = testee.summarizedDueDates(for: assignment)

        XCTAssertEqual(dueDates.count, 2)
        XCTAssertEqual(dueDates.first, DueDateFormatter.dateText(testData.dueDate2))
        XCTAssertEqual(dueDates.last, DueDateFormatter.dateText(testData.dueDate3))
    }

    func test_dueDates_withSubAssignmentsAndAfterLockDate_shouldHaveSingleClosedItem() {
        Clock.mockNow(testData.lockDate.addDays(1))

        let assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", due_at: testData.dueDate2),
                .make(tag: "tag2", due_at: testData.dueDate3, lock_at: testData.lockDate)
            ]
        ))
        let dueDates = testee.summarizedDueDates(for: assignment)

        XCTAssertEqual(dueDates.count, 1)
        XCTAssertEqual(dueDates.first, DueDateFormatter.availabilityClosedText)
    }

    func test_dueDatesForStudent_withSubAssignmentsAndOverrides_shouldIgnoreOverrides() {
        Clock.mockNow(testData.lockDate.addDays(1))

        let assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", due_at: testData.dueDate2, lock_at: testData.lockDate),
                .make(tag: "tag2", due_at: testData.dueDate3, overrides: [.make()])
            ]
        ))
        let dueDates = testee.summarizedDueDates(for: assignment)

        XCTAssertEqual(dueDates.count, 1)
        XCTAssertEqual(dueDates.first, DueDateFormatter.availabilityClosedText)
    }

    // MARK: - Due dates for Teacher app

    func test_dueDatesForTeacher_withNoSubAssignments_shouldHaveSingleItem() {
        environment.app = .teacher

        // WHEN available
        Clock.mockNow(testData.lockDate.addDays(-1))
        var assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            lock_at: testData.lockDate,
            has_sub_assignments: false
        ))
        var dueDates = testee.summarizedDueDates(for: assignment)
        // THEN
        XCTAssertEqual(dueDates.count, 1)
        XCTAssertEqual(dueDates.first, DueDateFormatter.dateText(testData.dueDate1))

        // WHEN closed
        Clock.mockNow(testData.lockDate.addDays(1))
        assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            lock_at: testData.lockDate,
            has_sub_assignments: false
        ))
        dueDates = testee.summarizedDueDates(for: assignment)
        // THEN
        XCTAssertEqual(dueDates.count, 1)
        XCTAssertEqual(dueDates.first, DueDateFormatter.availabilityClosedText)

        // WHEN multiple
        assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_overrides: true,
            has_sub_assignments: false
        ))
        dueDates = testee.summarizedDueDates(for: assignment)
        // THEN
        XCTAssertEqual(dueDates.count, 1)
        XCTAssertEqual(dueDates.first, DueDateFormatter.multipleDueDatesText)
    }

    func test_dueDatesForTeacher_withSubAssignmentsAndNoDueDate_shouldHaveMultipleItems() {
        environment.app = .teacher

        // WHEN one is nil
        var assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", due_at: testData.dueDate2),
                .make(tag: "tag2", due_at: nil)
            ]
        ))
        var dueDates = testee.summarizedDueDates(for: assignment)
        // THEN
        XCTAssertEqual(dueDates.count, 2)
        XCTAssertEqual(dueDates.first, DueDateFormatter.dateText(testData.dueDate2))
        XCTAssertEqual(dueDates.last, DueDateFormatter.noDueDateText)

        // WHEN all are nil
        assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", due_at: nil),
                .make(tag: "tag2", due_at: nil)
            ]
        ))
        dueDates = testee.summarizedDueDates(for: assignment)
        // THEN
        XCTAssertEqual(dueDates.count, 2)
        XCTAssertEqual(dueDates.first, DueDateFormatter.noDueDateText)
        XCTAssertEqual(dueDates.last, DueDateFormatter.noDueDateText)
    }

    func test_dueDatesForTeacher_withSubAssignmentsAndBeforeLockDate_shouldHaveMultipleItems() {
        environment.app = .teacher
        Clock.mockNow(testData.lockDate.addDays(-1))

        let assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            lock_at: testData.lockDate,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", due_at: testData.dueDate2, lock_at: testData.lockDate),
                .make(tag: "tag2", due_at: testData.dueDate3, lock_at: testData.lockDate)
            ]
        ))
        let dueDates = testee.summarizedDueDates(for: assignment)

        XCTAssertEqual(dueDates.count, 2)
        XCTAssertEqual(dueDates.first, DueDateFormatter.dateText(testData.dueDate2))
        XCTAssertEqual(dueDates.last, DueDateFormatter.dateText(testData.dueDate3))
    }

    func test_dueDatesForTeacher_withSubAssignmentsAndAfterLockDate_shouldHaveSingleClosedItem() {
        environment.app = .teacher
        Clock.mockNow(testData.lockDate.addDays(1))

        let assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", due_at: testData.dueDate2),
                .make(tag: "tag2", due_at: testData.dueDate3, lock_at: testData.lockDate)
            ]
        ))
        let dueDates = testee.summarizedDueDates(for: assignment)

        XCTAssertEqual(dueDates.count, 1)
        XCTAssertEqual(dueDates.first, DueDateFormatter.availabilityClosedText)
    }

    func test_dueDatesForTeacher_withSubAssignmentsAndOverrides_shouldHaveSingleItem() {
        environment.app = .teacher

        let assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", due_at: testData.dueDate2),
                .make(tag: "tag2", due_at: testData.dueDate3, overrides: [.make()])
            ]
        ))
        let dueDates = testee.summarizedDueDates(for: assignment)

        XCTAssertEqual(dueDates.count, 1)
        XCTAssertEqual(dueDates.first, DueDateFormatter.multipleDueDatesText)
    }

    // MARK: - Special case priority

    func test_dueDatesForTeacher_withNoSubAssignmentsAndLockedAndHasOverrides_shouldHaveMultipleCase() {
        Clock.mockNow(testData.lockDate.addDays(1))
        environment.app = .teacher

        // WHEN multiple
        let assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_overrides: true,
            lock_at: testData.lockDate,
            has_sub_assignments: false
        ))
        let dueDates = testee.summarizedDueDates(for: assignment)
        // THEN
        XCTAssertEqual(dueDates.count, 1)
        XCTAssertEqual(dueDates.first, DueDateFormatter.multipleDueDatesText)
    }

    func test_dueDatesForTeacher_withSubAssignmentsAndLockedAndHasOverrides_shouldHaveMultipleCase() {
        Clock.mockNow(testData.lockDate.addDays(1))
        environment.app = .teacher

        let assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", due_at: testData.dueDate2, lock_at: testData.lockDate),
                .make(tag: "tag2", due_at: testData.dueDate3, overrides: [.make()])
            ]
        ))
        let dueDates = testee.summarizedDueDates(for: assignment)

        XCTAssertEqual(dueDates.count, 1)
        XCTAssertEqual(dueDates.first, DueDateFormatter.multipleDueDatesText)
    }

    // MARK: - Private helpers

    private func makeAssignment(_ apiModel: APIAssignment) -> Assignment {
        .make(from: apiModel, in: databaseClient)
    }
}
