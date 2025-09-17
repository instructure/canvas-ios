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

final class TeacherAssignmentListItemTests: CoreTestCase {

    private static let testData = (
        assignmentId: "some assignmentId",
        assignmentName: "some assignmentName",
        checkpointTag1: "some checkpointTag1",
        checkpointTag2: "some checkpointTag2",
        checkpointName1: "some checkpointName1",
        checkpointName2: "some checkpointName2",
        dueDate1: Date.make(year: 2025, month: 9, day: 15),
        dueDate2: Date.make(year: 2025, month: 9, day: 20),
        dueDate3: Date.make(year: 2025, month: 9, day: 18),
        lockDate: Date.make(year: 2025, month: 9, day: 22),
        htmlURL: URL(string: "https://canvas.instructure.com/assignments/123")!
    )
    private lazy var testData = Self.testData

    private var testee: TeacherAssignmentListItem!

    override func tearDown() {
        testee = nil
        Clock.reset()
        super.tearDown()
    }

    // MARK: - Basic properties

    func test_basicProperties_withNoSubAssignments() {
        testee = makeListItem(.make(
            html_url: testData.htmlURL,
            id: ID(testData.assignmentId),
            name: testData.assignmentName,
            published: true,
            has_sub_assignments: false
        ))

        XCTAssertEqual(testee.id, testData.assignmentId)
        XCTAssertEqual(testee.title, testData.assignmentName)
        XCTAssertEqual(testee.isPublished, true)
        XCTAssertEqual(testee.route, testData.htmlURL)
        XCTAssertEqual(testee.subItems, nil)
    }

    func test_basicProperties_withSubAssignments() {
        testee = makeListItem(.make(
            html_url: testData.htmlURL,
            id: ID(testData.assignmentId),
            name: testData.assignmentName,
            published: true,
            has_sub_assignments: true,
            checkpoints: [.make()]
        ))

        XCTAssertEqual(testee.id, testData.assignmentId)
        XCTAssertEqual(testee.title, testData.assignmentName)
        XCTAssertEqual(testee.isPublished, true)
        XCTAssertEqual(testee.route, testData.htmlURL)
        XCTAssertEqual(testee.subItems?.count, 1)
    }

    // MARK: - Due dates

    func test_dueDates_withNoSubAssignments_shouldHaveSingleItem() {
        // WHEN available
        Clock.mockNow(testData.lockDate.addDays(-1))
        testee = makeListItem(.make(
            due_at: testData.dueDate1,
            lock_at: testData.lockDate,
            has_sub_assignments: false
        ))
        // THEN
        XCTAssertEqual(testee.dueDates.count, 1)
        XCTAssertEqual(testee.dueDates.first, DueDateFormatter.dateText(testData.dueDate1))

        // WHEN closed
        Clock.mockNow(testData.lockDate.addDays(1))
        testee = makeListItem(.make(
            due_at: testData.dueDate1,
            lock_at: testData.lockDate,
            has_sub_assignments: false
        ))
        // THEN
        XCTAssertEqual(testee.dueDates.count, 1)
        XCTAssertEqual(testee.dueDates.first, DueDateFormatter.availabilityClosedText)

        // WHEN multiple
        testee = makeListItem(.make(
            due_at: testData.dueDate1,
            has_overrides: true,
            has_sub_assignments: false
        ))
        // THEN
        XCTAssertEqual(testee.dueDates.count, 1)
        XCTAssertEqual(testee.dueDates.first, DueDateFormatter.multipleDueDatesText)
    }

    func test_dueDates_withSubAssignmentsAndNoDueDate_shouldHaveMultipleItems() {
        // WHEN one is nil
        testee = makeListItem(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", due_at: testData.dueDate2),
                .make(tag: "tag2", due_at: nil)
            ]
        ))
        // THEN
        XCTAssertEqual(testee.dueDates.count, 2)
        XCTAssertEqual(testee.dueDates.first, DueDateFormatter.dateText(testData.dueDate2))
        XCTAssertEqual(testee.dueDates.last, DueDateFormatter.noDueDateText)

        // WHEN all are nil
        testee = makeListItem(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", due_at: nil),
                .make(tag: "tag2", due_at: nil)
            ]
        ))
        // THEN
        XCTAssertEqual(testee.dueDates.count, 2)
        XCTAssertEqual(testee.dueDates.first, DueDateFormatter.noDueDateText)
        XCTAssertEqual(testee.dueDates.last, DueDateFormatter.noDueDateText)
    }

    func test_dueDates_withSubAssignmentsAndBeforeLockDate_shouldHaveMultipleItems() {
        Clock.mockNow(testData.lockDate.addDays(-1))

        testee = makeListItem(.make(
            due_at: testData.dueDate1,
            lock_at: testData.lockDate,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", due_at: testData.dueDate2, lock_at: testData.lockDate),
                .make(tag: "tag2", due_at: testData.dueDate3, lock_at: testData.lockDate)
            ]
        ))

        XCTAssertEqual(testee.dueDates.count, 2)
        XCTAssertEqual(testee.dueDates.first, DueDateFormatter.dateText(testData.dueDate2))
        XCTAssertEqual(testee.dueDates.last, DueDateFormatter.dateText(testData.dueDate3))
    }

    func test_dueDates_withSubAssignmentsAndAfterLockDate_shouldHaveSingleClosedItem() {
        Clock.mockNow(testData.lockDate.addDays(1))

        testee = makeListItem(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", due_at: testData.dueDate2),
                .make(tag: "tag2", due_at: testData.dueDate3, lock_at: testData.lockDate)
            ]
        ))

        XCTAssertEqual(testee.dueDates.count, 1)
        XCTAssertEqual(testee.dueDates.first, DueDateFormatter.availabilityClosedText)
    }

    func test_dueDates_withSubAssignmentsAndOverrides_shouldHaveSingleItem() {
        testee = makeListItem(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", due_at: testData.dueDate2),
                .make(tag: "tag2", due_at: testData.dueDate3, overrides: [.make()])
            ]
        ))

        XCTAssertEqual(testee.dueDates.count, 1)
        XCTAssertEqual(testee.dueDates.first, DueDateFormatter.multipleDueDatesText)
    }

    // MARK: - Needs Grading

    func test_needsGrading_whenTypeIsOtherThanNotGraded() {
        // WHEN count is positive
        testee = makeListItem(.make(
            grading_type: .percent,
            needs_grading_count: 7
        ))
        // THEN
        XCTAssertEqual(testee.needsGrading, "7 Need Grading")

        // WHEN count is zero
        testee = makeListItem(.make(
            grading_type: .percent,
            needs_grading_count: 0
        ))
        // THEN
        XCTAssertEqual(testee.needsGrading, nil)
    }

    func test_needsGrading_whenTypeIsNotGraded() {
        testee = makeListItem(.make(
            grading_type: .not_graded,
            needs_grading_count: 7
        ))

        XCTAssertEqual(testee.needsGrading, nil)
    }

    // MARK: - Points Possible

    func test_pointsPossible_withPointsPossible() {
        testee = makeListItem(.make(
            points_possible: 42
        ))

        XCTAssertEqual(testee.pointsPossible, "42 points")
    }

    func test_pointsPossible_withNoPointsPossible() {
        testee = makeListItem(.make(
            points_possible: nil
        ))

        XCTAssertEqual(testee.pointsPossible, nil)
    }

    // MARK: - Sub Item - Basic properties

    func test_subItemBasicProperties() {
        testee = makeListItem(.make(
            id: ID(testData.assignmentId),
            name: testData.assignmentName,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: testData.checkpointTag1, name: testData.checkpointName1),
                .make(tag: testData.checkpointTag2, name: testData.checkpointName2)
            ]
        ))

        XCTAssertEqual(testee.subItems?.count, 2)

        let firstSubItem = testee.subItems?.first
        XCTAssertEqual(firstSubItem?.tag, testData.checkpointTag1)
        XCTAssertEqual(firstSubItem?.title, testData.checkpointName1)
        XCTAssertEqual(firstSubItem?.id, testData.checkpointTag1)

        let lastSubItem = testee.subItems?.last
        XCTAssertEqual(lastSubItem?.tag, testData.checkpointTag2)
        XCTAssertEqual(lastSubItem?.title, testData.checkpointName2)
        XCTAssertEqual(lastSubItem?.id, testData.checkpointTag2)
    }

    // MARK: - Sub Item - Due date

    func test_subItemDueDate_withDueDate() {
        testee = makeListItem(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(due_at: testData.dueDate2)
            ]
        ))

        XCTAssertEqual(testee.subItems?.first?.dueDate, DueDateFormatter.dateText(testData.dueDate2))
    }

    func test_subItemDueDate_withNoDueDate() {
        testee = makeListItem(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(due_at: nil)
            ]
        ))

        XCTAssertEqual(testee.subItems?.first?.dueDate, DueDateFormatter.noDueDateText)
    }

    func test_subItemDueDate_whenBeforeLockDate() {
        Clock.mockNow(testData.lockDate.addDays(-1))

        testee = makeListItem(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(due_at: testData.dueDate2, lock_at: testData.lockDate)
            ]
        ))

        XCTAssertEqual(testee.subItems?.first?.dueDate, DueDateFormatter.dateText(testData.dueDate2))
    }

    func test_subItemDueDate_whenAfterLockDate() {
        Clock.mockNow(testData.lockDate.addDays(1))

        testee = makeListItem(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(due_at: testData.dueDate2, lock_at: testData.lockDate)
            ]
        ))

        XCTAssertEqual(testee.subItems?.first?.dueDate, DueDateFormatter.availabilityClosedText)
    }

    func test_subItemDueDate_withOverrides() {
        testee = makeListItem(.make(
            due_at: testData.dueDate1,
            has_sub_assignments: true,
            checkpoints: [
                .make(due_at: testData.dueDate2, overrides: [.make()])
            ]
        ))

        XCTAssertEqual(testee.subItems?.first?.dueDate, DueDateFormatter.multipleDueDatesText)
    }

    // MARK: - Sub Item - Points Possible

    func test_subItemPointsPossible() {
        testee = makeListItem(.make(
            points_possible: 42,
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", points_possible: 7),
                .make(tag: "tag2", points_possible: nil)
            ]
        ))

        XCTAssertEqual(testee.subItems?.first?.pointsPossible, "7 points")
        XCTAssertEqual(testee.subItems?.last?.pointsPossible, nil)
    }

    // MARK: - Private helpers

    private func makeListItem(_ apiModel: APIAssignment) -> TeacherAssignmentListItem {
        TeacherAssignmentListItem(assignment: .make(from: apiModel, in: databaseClient))
    }
}
