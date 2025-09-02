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

import Combine
@testable import Core
@testable import Teacher
import TestsFoundation
import XCTest

class SubmissionCommentsInteractorTests: TeacherTestCase {

    private enum TestConstants {
        static let assignmentId = "some assignmentId"
        static let courseId = "some courseId"
        static let submissionUserId = "some submissionUserId"
        static let date = Date.make(year: 2048, month: 1, day: 1)
    }

    private var testee: SubmissionCommentsInteractorLive!

    override func setUp() {
        super.setUp()

        testee = makeInteractor()
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    // MARK: - Get methods

    func test_getSubmissionAttempts() {
        makeSubmission(id: "s1", attempt: 1)
        makeSubmission(id: "s2", attempt: 2)

        XCTAssertFirstValue(testee.getSubmissionAttempts()) { submissions in
            XCTAssertEqual(submissions.map(\.id), ["s1", "s2"])
        }
    }

    func test_getComments() {
        api.mock(
            GetSubmissionComments(
                context: .course(TestConstants.courseId),
                assignmentID: TestConstants.assignmentId,
                userID: TestConstants.submissionUserId
            ),
            value: .make(
                assignment_id: TestConstants.assignmentId,
                submission_comments: [
                    .make(id: "c1", created_at: TestConstants.date.addHours(1)),
                    .make(id: "c2", created_at: TestConstants.date.addHours(2))
                ],
                user_id: TestConstants.submissionUserId
            )
        )

        XCTAssertFirstValue(testee.getComments()) { comments in
            XCTAssertEqual(comments.map(\.id), ["c2", "c1"])
        }
    }

    func test_getIsAssignmentEnhancementsEnabled() {
        api.mock(
            GetEnabledFeatureFlags(context: .course(TestConstants.courseId)),
            value: ["assignments_2_student"]
        )

        XCTAssertFirstValue(testee.getIsAssignmentEnhancementsEnabled()) { isEnabled in
            XCTAssertEqual(isEnabled, true)
        }
    }

    func test_getIsCommentLibraryEnabled() {
        api.mock(
            GetUserSettings(userID: "self"),
            value: .make(comment_library_suggestions_enabled: true)
        )

        XCTAssertFirstValue(testee.getIsCommentLibraryEnabled()) { isEnabled in
            XCTAssertEqual(isEnabled, true)
        }
    }

    // MARK: - Private helpers

    private func makeInteractor(
        isGroupAssignment: Bool = false
    ) -> SubmissionCommentsInteractorLive {
        SubmissionCommentsInteractorLive(
            courseId: TestConstants.courseId,
            assignmentId: TestConstants.assignmentId,
            submissionUserId: TestConstants.submissionUserId,
            isGroupAssignment: isGroupAssignment,
            env: environment
        )
    }

    @discardableResult
    private func makeSubmission(id: String, attempt: Int?) -> Submission {
        Submission.save(
            .make(
                assignment_id: TestConstants.assignmentId,
                attempt: attempt,
                id: .init(id),
                submitted_at: TestConstants.date,
                user_id: TestConstants.submissionUserId
            ),
            in: databaseClient
        )
    }
}
