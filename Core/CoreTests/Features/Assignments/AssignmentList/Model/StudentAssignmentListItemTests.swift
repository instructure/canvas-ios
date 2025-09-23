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

final class StudentAssignmentListItemTests: CoreTestCase {

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

    private var testee: StudentAssignmentListItem!
    private var dueDateTextsProvider: AssignmentDueDateTextsProviderMock!

    override func setUp() {
        super.setUp()
        dueDateTextsProvider = .init()
    }

    override func tearDown() {
        testee = nil
        dueDateTextsProvider = nil
        Clock.reset()
        super.tearDown()
    }

    // MARK: - Basic properties

    func test_basicProperties_withNoSubAssignments() {
        testee = makeListItem(.make(
            html_url: testData.htmlURL,
            id: ID(testData.assignmentId),
            name: testData.assignmentName,
            has_sub_assignments: false
        ))

        XCTAssertEqual(testee.id, testData.assignmentId)
        XCTAssertEqual(testee.title, testData.assignmentName)
        XCTAssertEqual(testee.route, testData.htmlURL)
        XCTAssertEqual(testee.subItems, nil)
    }

    func test_basicProperties_withSubAssignments() {
        testee = makeListItem(.make(
            html_url: testData.htmlURL,
            id: ID(testData.assignmentId),
            name: testData.assignmentName,
            has_sub_assignments: true,
            checkpoints: [.make()]
        ))

        XCTAssertEqual(testee.id, testData.assignmentId)
        XCTAssertEqual(testee.title, testData.assignmentName)
        XCTAssertEqual(testee.route, testData.htmlURL)
        XCTAssertEqual(testee.subItems?.count, 1)
    }

    // MARK: - Due dates

    func test_dueDates_shouldCallDueDateTextsProviderAndUseItsResult() {
        dueDateTextsProvider.formattedDueDatesResult = ["dd1", "dd2"]
        testee = makeListItem(.make(
            id: ID(testData.assignmentId)
        ))

        XCTAssertEqual(dueDateTextsProvider.formattedDueDatesCallsCount, 1)
        XCTAssertEqual(dueDateTextsProvider.formattedDueDatesInput?.id, testData.assignmentId)
        XCTAssertEqual(testee.dueDates.count, 2)
        XCTAssertEqual(testee.dueDates.first, "dd1")
        XCTAssertEqual(testee.dueDates.last, "dd2")
    }

    // MARK: - Status

    func test_status_withNoSubAssignments_shouldMatchSubmissionStatus() {
        testee = makeListItem(.make(
            submission: .make(excused: true),
            has_sub_assignments: false
        ))

        XCTAssertEqual(testee.submissionStatus, .init(status: .excused))
    }

    func test_status_withSubAssignments_shouldMatchSubmissionStatus() {
        testee = makeListItem(.make(
            submission: .make(excused: true),
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1"),
                .make(tag: "tag2")
            ]
        ))

        XCTAssertEqual(testee.submissionStatus, .init(status: .excused))
    }

    // MARK: - Score

    func test_score_withNoSubAssignments() {
        // WHEN has pointsPossible, has score
        testee = makeListItem(.make(
            points_possible: 100,
            submission: .make(score: 42)
        ))
        // THEN
        XCTAssertEqual(testee.score, "42 / 100")

        // WHEN has pointsPossible, has no score
        testee = makeListItem(.make(
            points_possible: 100,
            submission: .make(score: nil)
        ))
        // THEN
        XCTAssertEqual(testee.score, "- / 100")

        // WHEN has no pointsPossible, has score
        testee = makeListItem(.make(
            points_possible: nil,
            submission: .make(score: 42)
        ))
        // THEN
        XCTAssertEqual(testee.score, nil)

        // WHEN excused
        testee = makeListItem(.make(
            points_possible: 100,
            submission: .make(excused: true, score: 42)
        ))
        // THEN
        XCTAssertEqual(testee.score, nil)
    }

    func test_score_withSubAssignments_shouldIgnoreSubAssignmentValues() {
        // WHEN has pointsPossible, has score
        testee = makeListItem(.make(
            points_possible: 100,
            submission: .make(
                score: 42,
                has_sub_assignment_submissions: true,
                sub_assignment_submissions: [
                    .make(sub_assignment_tag: "tag1", score: 7),
                    .make(sub_assignment_tag: "tag2", score: 12)
                ]
            ),
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", points_possible: 10),
                .make(tag: "tag2", points_possible: 20)
            ]
        ))
        // THEN
        XCTAssertEqual(testee.score, "42 / 100")

        // WHEN has pointsPossible, has no score
        testee = makeListItem(.make(
            points_possible: 100,
            submission: .make(
                score: nil,
                has_sub_assignment_submissions: true,
                sub_assignment_submissions: [
                    .make(sub_assignment_tag: "tag1", score: 7),
                    .make(sub_assignment_tag: "tag2", score: 12)
                ]
            ),
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1", points_possible: 10),
                .make(tag: "tag2", points_possible: 20)
            ]
        ))
        // THEN
        XCTAssertEqual(testee.score, "- / 100")
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

    // MARK: - Sub Item - Status

    func test_subItemStatus_shouldMatchSubAssignmentSubmissionStatus() {
        testee = makeListItem(.make(
            submission: .make(
                excused: true,
                has_sub_assignment_submissions: true,
                sub_assignment_submissions: [
                    .make(sub_assignment_tag: "tag1", submitted_at: testData.dueDate1),
                    .make(sub_assignment_tag: "tag2", missing: true)
                ]
            ),
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag1"),
                .make(tag: "tag2")
            ]
        ))

        XCTAssertEqual(testee.submissionStatus, .init(status: .excused))
        XCTAssertEqual(testee.subItems?.first?.submissionStatus, .init(status: .submitted))
        XCTAssertEqual(testee.subItems?.last?.submissionStatus, .init(status: .missing))
    }

    // MARK: - Sub Item - Score

    func test_subItemScore() throws {
        testee = makeListItem(.make(
            points_possible: 100,
            submission: .make(
                score: 42,
                has_sub_assignment_submissions: true,
                sub_assignment_submissions: [
                    .make(sub_assignment_tag: "tag0", score: 7),
                    .make(sub_assignment_tag: "tag1", score: nil),
                    .make(sub_assignment_tag: "tag2", score: 7),
                    .make(sub_assignment_tag: "tag3", excused: true, score: 7)
                ]
            ),
            has_sub_assignments: true,
            checkpoints: [
                .make(tag: "tag0", points_possible: 20),
                .make(tag: "tag1", points_possible: 21),
                .make(tag: "tag2", points_possible: nil),
                .make(tag: "tag3", points_possible: 23)
            ]
        ))

        guard testee.subItems?.count == 4 else { throw InvalidCountError() }

        XCTAssertEqual(testee.subItems?[0].score, "7 / 20")
        XCTAssertEqual(testee.subItems?[1].score, "- / 21")
        XCTAssertEqual(testee.subItems?[2].score, nil)
        XCTAssertEqual(testee.subItems?[3].score, nil)
    }

    // MARK: - Private helpers

    private func makeListItem(
        _ apiModel: APIAssignment,
        userId: String? = nil
    ) -> StudentAssignmentListItem {
        StudentAssignmentListItem(
            assignment: .make(from: apiModel, in: databaseClient),
            userId: userId,
            dueDateTextsProvider: dueDateTextsProvider
        )
    }
}
