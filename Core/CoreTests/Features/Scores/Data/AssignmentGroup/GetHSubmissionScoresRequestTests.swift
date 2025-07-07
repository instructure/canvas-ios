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

@testable import Core
import XCTest

final class GetHSubmissionScoresRequestTests: CoreTestCase {
    func testInit() {
        let request = GetHSubmissionScoresRequest(userId: "user-123", enrollmentId: "enrollment-456")

        XCTAssertEqual(request.variables.userId, "user-123")
        XCTAssertEqual(request.variables.enrollmentId, "enrollment-456")
    }

    func testInputEquatable() {
        let input1 = GetHSubmissionScoresRequest.Input(userId: "user-123", enrollmentId: "enrollment-456")
        let input2 = GetHSubmissionScoresRequest.Input(userId: "user-123", enrollmentId: "enrollment-456")
        let input3 = GetHSubmissionScoresRequest.Input(userId: "user-789", enrollmentId: "enrollment-456")

        XCTAssertEqual(input1, input2)
        XCTAssertNotEqual(input1, input3)
    }

    func testQuery() {
        let query = GetHSubmissionScoresRequest.query
        XCTAssertTrue(query.contains("query GetSubmissionScoresForCourse($enrollmentId: ID!, $userId: ID!)"))
        XCTAssertTrue(query.contains("legacyNode(_id: $enrollmentId, type: Enrollment)"))
        XCTAssertTrue(query.contains("grades {"))
        XCTAssertTrue(query.contains("assignmentGroups {"))
        XCTAssertTrue(query.contains("gradesConnection(filter: { enrollmentIds: [$enrollmentId] })"))
        XCTAssertTrue(query.contains("submissionsConnection(filter: { includeUnsubmitted: true, userId: $userId })"))
    }
}
