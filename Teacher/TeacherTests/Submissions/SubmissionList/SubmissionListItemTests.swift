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
import TestsFoundation
@testable import Core
@testable import Teacher

class SubmissionListItemTests: TeacherTestCase {

    enum TestConstants {
        static let assignmentID = "12345"
        static let courseID = "67890"
        static let submissionID = "87329"

        static var context: Context {
            return .course(courseID)
        }
    }

    func testMakingFromSubmission() {
        // Given
        let assignment = databaseClient.fetchFirstOrInsert(\Assignment.id, equals: TestConstants.assignmentID)
        assignment.id = TestConstants.assignmentID
        assignment.courseID = TestConstants.courseID
        assignment.name = "Test Assignment"

        let submission = databaseClient.fetchFirstOrInsert(\Submission.id, equals: TestConstants.submissionID)
        submission.assignmentID = TestConstants.assignmentID
        submission.userID = "u23244"
        submission.groupID = "g87323"
        submission.groupName = "Example Group"
        submission.user = User.save(
            .make(
                id: ID("u23244"),
                name: "Smith",
                avatar_url: URL(string: "https://example.com/avatar"),
                pronouns: "he/him"
            ),
            in: databaseClient
        )

        submission.workflowState = .graded
        submission.score = 85

        // When
        let item = SubmissionListItem(submission: submission, assignment: assignment)

        // Then
        let expectedGrade = GradeFormatter.shortString(for: assignment, submission: submission)

        XCTAssertEqual(item.originalUserID, "u23244")
        XCTAssertEqual(item.groupID, "g87323")
        XCTAssertEqual(item.groupName, "Example Group")
        XCTAssertEqual(item.status, .graded)
        XCTAssertEqual(item.needsGrading, false)
        XCTAssertEqual(item.user?.id, "u23244")
        XCTAssertEqual(item.user?.name, "Smith")
        XCTAssertEqual(item.user?.avatarURL, URL(string: "https://example.com/avatar"))
        XCTAssertEqual(item.gradeFormatted, expectedGrade)
    }
}
