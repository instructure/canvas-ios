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
@testable import Student
import TestsFoundation

final class StudentSubAssignmentsCardViewModelTests: StudentTestCase {

    private static let testData = (
        tag1: "tag1",
        tag2: "tag2",
        name1: "name 1",
        name2: "name 2",
    )
    private lazy var testData = Self.testData

    private var testee: StudentSubAssignmentsCardViewModel!

    // MARK: - Assignment hasSubAssignments

    func test_items_whenAssignmentHasSubAssignments_shouldNotBeEmpty() {
        testee = makeViewModel(
            assignment: .make(
                has_sub_assignments: true,
                checkpoints: [.make()]
            )
        )

        XCTAssertEqual(testee.items.count, 1)
    }

    func test_items_whenAssignmentHasNoSubAssignments_shouldBeEmpty() {
        testee = makeViewModel(
            assignment: .make(
                has_sub_assignments: false,
                checkpoints: [.make()]
            )
        )

        XCTAssertEqual(testee.items, [])
    }

    // MARK: - Basic properties

    func test_basicProperties() {
        testee = makeViewModel(
            assignment: .make(
                has_sub_assignments: true,
                checkpoints: [
                    .make(tag: testData.tag1, name: testData.name1),
                    .make(tag: testData.tag2, name: testData.name2)
                ]
            )
        )

        XCTAssertEqual(testee.items.count, 2)
        XCTAssertEqual(testee.items.first?.id, testData.tag1)
        XCTAssertEqual(testee.items.first?.title, testData.name1)
        XCTAssertEqual(testee.items.last?.id, testData.tag2)
        XCTAssertEqual(testee.items.last?.title, testData.name2)
    }

    // MARK: - Status

    func test_itemStatus_shouldMatchSubAssignmentSubmissionStatus() {
        testee = makeViewModel(
            assignment: .make(
                has_sub_assignments: true,
                checkpoints: [
                    .make(tag: testData.tag1),
                    .make(tag: testData.tag2)
                ]
            ),
            submission: .make(
                has_sub_assignment_submissions: true,
                sub_assignment_submissions: [
                    .make(sub_assignment_tag: testData.tag1, submitted_at: Date.make(year: 2021)),
                    .make(sub_assignment_tag: testData.tag2, missing: true)
                ]
            )
        )

        XCTAssertEqual(testee.items.first?.submissionStatus, .submitted)
        XCTAssertEqual(testee.items.last?.submissionStatus, .missing)
    }

    // MARK: - Score

    func test_itemScore() throws {
        testee = makeViewModel(
            assignment: .make(
                has_sub_assignments: true,
                checkpoints: [
                    .make(tag: "tag0", points_possible: 20),
                    .make(tag: "tag1", points_possible: 21),
                    .make(tag: "tag2", points_possible: nil),
                    .make(tag: "tag3", points_possible: 23)
                ]
            ),
            submission: .make(
                has_sub_assignment_submissions: true,
                sub_assignment_submissions: [
                    .make(sub_assignment_tag: "tag0", score: 7),
                    .make(sub_assignment_tag: "tag1", score: nil),
                    .make(sub_assignment_tag: "tag2", score: 7),
                    .make(sub_assignment_tag: "tag3", excused: true, score: 7)
                ]
            )
        )

        guard testee.items.count == 4 else { throw InvalidCountError() }

        XCTAssertEqual(testee.items[0].score, "7 / 20")
        XCTAssertEqual(testee.items[1].score, "- / 21")
        XCTAssertEqual(testee.items[2].score, nil)
        XCTAssertEqual(testee.items[3].score, nil)

        XCTAssertEqual(testee.items[0].scoreA11yLabel, "Grade, 7 out of 20")
        XCTAssertEqual(testee.items[1].scoreA11yLabel, "Grade, - out of 21")
        XCTAssertEqual(testee.items[2].scoreA11yLabel, nil)
        XCTAssertEqual(testee.items[3].scoreA11yLabel, nil)
    }

    // MARK: - Private helpers

    private func makeViewModel(
        assignment: APIAssignment,
        submission: APISubmission? = nil
    ) -> StudentSubAssignmentsCardViewModel {
        let submissionModel = submission.map { Submission.make(from: $0, in: databaseClient) }
        return StudentSubAssignmentsCardViewModel(
            assignment: Assignment.make(from: assignment, in: databaseClient),
            submission: submissionModel
        )
    }
}
