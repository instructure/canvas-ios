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

@testable import Core
@testable import Teacher
import TestsFoundation
import XCTest

class SubmissionCommentFilterTests: TeacherTestCase {

    private let testee = SubmissionCommentFilterLive()

    func test_filterComments_withAssignmentEnhancementsDisabled_returnsAllComments() {
        let comments = makeTestComments()
        let result = testee.filterComments(comments, for: 1, isAssignmentEnhancementsEnabled: false)

        XCTAssertEqual(result.count, comments.count)
    }

    func test_filterComments_withAssignmentEnhancementsEnabled_nilAttempt_returnsOnlyNilAttemptComments() {
        let comments = makeTestComments()
        let result = testee.filterComments(comments, for: nil, isAssignmentEnhancementsEnabled: true)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, "comment-nil")
    }

    func test_filterComments_withAssignmentEnhancementsEnabled_attempt0_includesNilAndAttempt0() {
        let comments = makeTestComments()
        let result = testee.filterComments(comments, for: 0, isAssignmentEnhancementsEnabled: true)

        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains { $0.id == "comment-nil" })
        XCTAssertTrue(result.contains { $0.id == "comment-0" })
    }

    func test_filterComments_withAssignmentEnhancementsEnabled_attempt1_includesNilAttempt0AndAttempt1() {
        let comments = makeTestComments()
        let result = testee.filterComments(comments, for: 1, isAssignmentEnhancementsEnabled: true)

        XCTAssertEqual(result.count, 3)
        XCTAssertTrue(result.contains { $0.id == "comment-nil" })
        XCTAssertTrue(result.contains { $0.id == "comment-0" })
        XCTAssertTrue(result.contains { $0.id == "comment-1" })
    }

    func test_filterComments_withAssignmentEnhancementsEnabled_attempt2_includesOnlyNilAndAttempt2() {
        let comments = makeTestComments()
        let result = testee.filterComments(comments, for: 2, isAssignmentEnhancementsEnabled: true)

        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains { $0.id == "comment-nil" })
        XCTAssertTrue(result.contains { $0.id == "comment-2" })
    }

    func test_filterComments_withAssignmentEnhancementsEnabled_attempt3_includesOnlyNilAndAttempt3() {
        let comments = makeTestComments()
        let result = testee.filterComments(comments, for: 3, isAssignmentEnhancementsEnabled: true)

        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains { $0.id == "comment-nil" })
        XCTAssertTrue(result.contains { $0.id == "comment-3" })
    }

    private func makeTestComments() -> [SubmissionComment] {
        return [
            makeTestComment(id: "comment-nil", attempt: nil),
            makeTestComment(id: "comment-0", attempt: 0),
            makeTestComment(id: "comment-1", attempt: 1),
            makeTestComment(id: "comment-2", attempt: 2),
            makeTestComment(id: "comment-3", attempt: 3)
        ]
    }

    private func makeTestComment(id: String, attempt: Int?) -> SubmissionComment {
        let comment = SubmissionComment(context: databaseClient)
        comment.id = id
        comment.attemptFromAPI = attempt.map(NSNumber.init)
        return comment
    }
}
