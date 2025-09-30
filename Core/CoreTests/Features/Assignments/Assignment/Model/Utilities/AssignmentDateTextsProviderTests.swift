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

    // MARK: - Summarized Due Dates for not Teacher app

    func test_summarizedDueDates_withNoSubAssignments_shouldHaveSingleItem() {
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

    func test_summarizedDueDates_withSubAssignmentsAndNoDueDate_shouldHaveMultipleItems() {
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

    func test_summarizedDueDates_withSubAssignmentsAndBeforeLockDate_shouldHaveMultipleItems() {
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

    func test_summarizedDueDates_withSubAssignmentsAndAfterLockDate_shouldHaveSingleClosedItem() {
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

    func test_summarizedDueDatesForStudent_withSubAssignmentsAndOverrides_shouldIgnoreOverrides() {
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

    // MARK: - Summarized Due Dates for Teacher app

    func test_summarizedDueDatesForTeacher_withNoSubAssignments_shouldHaveSingleItem() {
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

    func test_summarizedDueDatesForTeacher_withSubAssignmentsAndNoDueDate_shouldHaveMultipleItems() {
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

    func test_summarizedDueDatesForTeacher_withSubAssignmentsAndBeforeLockDate_shouldHaveMultipleItems() {
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

    func test_summarizedDueDatesForTeacher_withSubAssignmentsAndAfterLockDate_shouldHaveSingleClosedItem() {
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

    func test_summarizedDueDatesForTeacher_withSubAssignmentsAndOverrides_shouldHaveSingleItem() {
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

    func test_summarizedDueDatesForTeacher_withNoSubAssignmentsAndLockedAndHasOverrides_shouldHaveMultipleCase() {
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

    func test_summarizedDueDatesForTeacher_withSubAssignmentsAndLockedAndHasOverrides_shouldHaveMultipleCase() {
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

    // MARK: - Due Date Items - hasOverrides logic

    func test_dueDateItems_withNoSubAssignmentsAndNoOverrides_shouldReturnSingleDueDate() {
        let assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_overrides: false,
            has_sub_assignments: false
        ))
        let items = testee.dueDateItems(for: assignment)

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.title, "Due")
        XCTAssertEqual(items.first?.date, DueDateFormatter.dateTextWithoutDue(testData.dueDate1))
    }

    func test_dueDateItems_withSubAssignmentsAndNoOverrides_shouldReturnBothDueDates() {
        let assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", name: "Task 1", due_at: testData.dueDate2),
                .make(tag: "tag2", name: "Task 2", due_at: testData.dueDate3)
            ]
        ))
        let items = testee.dueDateItems(for: assignment)

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].title, "Task 1 due")
        XCTAssertEqual(items[0].date, DueDateFormatter.dateTextWithoutDue(testData.dueDate2))
        XCTAssertEqual(items[1].title, "Task 2 due")
        XCTAssertEqual(items[1].date, DueDateFormatter.dateTextWithoutDue(testData.dueDate3))
    }

    func test_dueDateItemsForStudent_withOverrides_shouldReturnSingleDueDate() {
        environment.app = .student
        let assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_overrides: true,
            has_sub_assignments: false
        ))
        let items = testee.dueDateItems(for: assignment)

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.title, "Due")
        XCTAssertEqual(items.first?.date, DueDateFormatter.dateTextWithoutDue(testData.dueDate1))
    }

    func test_dueDateItemsForStudent_withSubAssignmentOverrides_shouldReturnBothDueDates() {
        environment.app = .student
        let assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", name: "Task 1", due_at: testData.dueDate2, overrides: [.make()]),
                .make(tag: "tag2", name: "Task 2", due_at: testData.dueDate3)
            ]
        ))
        let items = testee.dueDateItems(for: assignment)

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].title, "Task 1 due")
        XCTAssertEqual(items[0].date, DueDateFormatter.dateTextWithoutDue(testData.dueDate2))
        XCTAssertEqual(items[1].title, "Task 2 due")
        XCTAssertEqual(items[1].date, DueDateFormatter.dateTextWithoutDue(testData.dueDate3))
    }

    func test_dueDateItemsForTeacher_withOverrides_shouldReturnSingleItemWithNilTitle() {
        environment.app = .teacher
        let assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_overrides: true,
            has_sub_assignments: false
        ))
        let items = testee.dueDateItems(for: assignment)

        XCTAssertEqual(items.count, 1)
        XCTAssertNil(items.first?.title)
        XCTAssertEqual(items.first?.date, DueDateFormatter.multipleDueDatesText)
    }

    func test_dueDateItemsForTeacher_withSubAssignmentOverrides_shouldReturnSingleItemWithNilTitle() {
        environment.app = .teacher
        let assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", name: "Task 1", due_at: testData.dueDate2, overrides: [.make()]),
                .make(tag: "tag2", name: "Task 2", due_at: testData.dueDate3)
            ]
        ))
        let items = testee.dueDateItems(for: assignment)

        XCTAssertEqual(items.count, 1)
        XCTAssertNil(items.first?.title)
        XCTAssertEqual(items.first?.date, DueDateFormatter.multipleDueDatesText)
    }

    // MARK: - Due Date Items - lockDate not affecting due date display

    func test_dueDateItems_withNoSubAssignmentsAndPassedLockDate_shouldNotDisplayClosedText() {
        Clock.mockNow(testData.lockDate.addDays(1))
        let assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            lock_at: testData.lockDate,
            has_sub_assignments: false
        ))
        let items = testee.dueDateItems(for: assignment)

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.title, "Due")
        XCTAssertEqual(items.first?.date, DueDateFormatter.dateTextWithoutDue(testData.dueDate1))
    }

    func test_dueDateItems_withSubAssignmentsAndPassedLockDate_shouldNotDisplayClosedText() {
        Clock.mockNow(testData.lockDate.addDays(1))
        let assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", name: "Task 1", due_at: testData.dueDate2, lock_at: testData.lockDate),
                .make(tag: "tag2", name: "Task 2", due_at: testData.dueDate3, lock_at: testData.lockDate)
            ]
        ))
        let items = testee.dueDateItems(for: assignment)

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].title, "Task 1 due")
        XCTAssertEqual(items[0].date, DueDateFormatter.dateTextWithoutDue(testData.dueDate2))
        XCTAssertEqual(items[1].title, "Task 2 due")
        XCTAssertEqual(items[1].date, DueDateFormatter.dateTextWithoutDue(testData.dueDate3))
    }

    // MARK: - Due Date Items - general logic

    func test_dueDateItems_withNoSubAssignmentsAndNilDueDate_shouldReturnSingleNoDueDate() {
        let assignment = makeAssignment(.make(
            due_at: nil,
            has_sub_assignments: false
        ))
        let items = testee.dueDateItems(for: assignment)

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.title, "Due")
        XCTAssertEqual(items.first?.date, DueDateFormatter.noDueDateText)
    }

    func test_dueDateItems_withNoSubAssignmentsAndDueDate_shouldReturnSingleDueDate() {
        let assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: false
        ))
        let items = testee.dueDateItems(for: assignment)

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.title, "Due")
        XCTAssertEqual(items.first?.date, DueDateFormatter.dateTextWithoutDue(testData.dueDate1))
    }

    func test_dueDateItems_withSubAssignmentsAndNilDueDates_shouldReturnMultipleItemsWithNoDueDateText() {
        let assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", name: "Task 1", due_at: nil),
                .make(tag: "tag2", name: "Task 2", due_at: nil)
            ]
        ))
        let items = testee.dueDateItems(for: assignment)

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].title, "Task 1 due")
        XCTAssertEqual(items[0].date, DueDateFormatter.noDueDateText)
        XCTAssertEqual(items[1].title, "Task 2 due")
        XCTAssertEqual(items[1].date, DueDateFormatter.noDueDateText)
    }

    func test_dueDateItems_withSubAssignmentsAndDueDates_shouldReturnMultipleItems() {
        let assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", name: "Task 1", due_at: testData.dueDate2),
                .make(tag: "tag2", name: "Task 2", due_at: nil),
                .make(tag: "tag3", name: "Task 3", due_at: testData.dueDate3)
            ]
        ))
        let items = testee.dueDateItems(for: assignment)

        XCTAssertEqual(items.count, 3)
        XCTAssertEqual(items[0].title, "Task 1 due")
        XCTAssertEqual(items[0].date, DueDateFormatter.dateTextWithoutDue(testData.dueDate2))
        XCTAssertEqual(items[1].title, "Task 2 due")
        XCTAssertEqual(items[1].date, DueDateFormatter.noDueDateText)
        XCTAssertEqual(items[2].title, "Task 3 due")
        XCTAssertEqual(items[2].date, DueDateFormatter.dateTextWithoutDue(testData.dueDate3))
    }

    func test_dueDateItems_withSubAssignmentsButNoCheckpoints_shouldReturnNoItems() {
        let assignment = makeAssignment(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: []
        ))
        let items = testee.dueDateItems(for: assignment)

        XCTAssertEqual(items.count, 0)
    }

    // MARK: - Private helpers

    private func makeAssignment(_ apiModel: APIAssignment) -> Assignment {
        .make(from: apiModel, in: databaseClient)
    }
}
