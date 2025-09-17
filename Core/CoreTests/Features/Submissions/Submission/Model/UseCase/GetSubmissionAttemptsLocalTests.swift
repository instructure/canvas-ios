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

class GetSubmissionAttemptsLocalTests: CoreTestCase {

    func test_init_createsScopeWithCorrectPredicate() {
        let useCase = GetSubmissionAttemptsLocal(assignmentId: "123", userId: "456")

        let expectedPredicates = [
            NSPredicate(key: #keyPath(Submission.assignmentID), equals: "123"),
            NSPredicate(key: #keyPath(Submission.userID), equals: "456"),
            NSPredicate(format: "%K != nil", #keyPath(Submission.submittedAt))
        ]
        let expectedCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: expectedPredicates)

        XCTAssertEqual(useCase.scope.predicate, expectedCompoundPredicate)
        XCTAssertEqual(useCase.scope.order.count, 1)
        XCTAssertEqual(useCase.scope.order.first?.key, #keyPath(Submission.attempt))
        XCTAssertTrue(useCase.scope.order.first?.ascending ?? false)
    }

    func test_scope_returnsSubmissionsWithSubmittedAtOnly() {
        let submissionWithDate = Submission.save(.make(
            assignment_id: "123",
            attempt: 1,
            submitted_at: Date(),
            user_id: "456"
        ), in: databaseClient)

        let submissionWithoutDate = Submission.save(.make(
            assignment_id: "123",
            attempt: 2,
            submitted_at: nil,
            user_id: "456"
        ), in: databaseClient)

        let useCase = GetSubmissionAttemptsLocal(assignmentId: "123", userId: "456")
        let results: [Submission] = databaseClient.fetch(scope: useCase.scope)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, submissionWithDate)
        XCTAssertNotEqual(results.first, submissionWithoutDate)
    }

    func test_scope_filtersCorrectAssignmentAndUser() {
        let correctSubmission = Submission.save(.make(
            assignment_id: "123",
            submitted_at: Date(),
            user_id: "456"
        ), in: databaseClient)

        Submission.save(.make(
            assignment_id: "999",
            submitted_at: Date(),
            user_id: "456"
        ), in: databaseClient)

        let useCase = GetSubmissionAttemptsLocal(assignmentId: "123", userId: "456")
        let results: [Submission] = databaseClient.fetch(scope: useCase.scope)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, correctSubmission)
    }

    func test_scope_ordersSubmissionsByAttempt() {
        let submission2 = Submission.save(.make(
            assignment_id: "123",
            attempt: 2,
            submitted_at: Date(),
            user_id: "456"
        ), in: databaseClient)

        let submission1 = Submission.save(.make(
            assignment_id: "123",
            attempt: 1,
            submitted_at: Date(),
            user_id: "456"
        ), in: databaseClient)

        let useCase = GetSubmissionAttemptsLocal(assignmentId: "123", userId: "456")
        let results: [Submission] = databaseClient.fetch(scope: useCase.scope)

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0], submission1)
        XCTAssertEqual(results[1], submission2)
    }

    func test_scope_returnsEmptyArrayWhenNoMatchingSubmissions() {
        Submission.save(.make(
            assignment_id: "999",
            submitted_at: Date(),
            user_id: "999"
        ), in: databaseClient)

        let useCase = GetSubmissionAttemptsLocal(assignmentId: "123", userId: "456")
        let results: [Submission] = databaseClient.fetch(scope: useCase.scope)

        XCTAssertEqual(results.count, 0)
    }

    func test_scope_excludesSubmissionsWithoutSubmittedAt() {
        Submission.save(.make(
            assignment_id: "123",
            submitted_at: nil,
            user_id: "456"
        ), in: databaseClient)

        let useCase = GetSubmissionAttemptsLocal(assignmentId: "123", userId: "456")
        let results: [Submission] = databaseClient.fetch(scope: useCase.scope)

        XCTAssertEqual(results.count, 0)
    }
}
