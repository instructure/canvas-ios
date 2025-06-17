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

final class GetSubmissionScoresUseCaseTests: CoreTestCase {
    func testRequest() {
        let useCase = GetSubmissionScoresUseCase(userId: "user-123", enrollmentId: "enrollment-456")
        let request = useCase.request

        XCTAssertEqual(request.variables.userId, "user-123")
        XCTAssertEqual(request.variables.enrollmentId, "enrollment-456")
    }

    func testCacheKey() {
        let useCase = GetSubmissionScoresUseCase(userId: "user-123", enrollmentId: "enrollment-456")

        XCTAssertEqual(useCase.cacheKey, "Submission-Scores-enrollment-456")
    }

    func testScope() {
        let useCase = GetSubmissionScoresUseCase(userId: "user-123", enrollmentId: "enrollment-456")

        XCTAssertEqual(useCase.scope, Scope.where(#keyPath(CDHSubmissionScores.enrollmentID), equals: "enrollment-456"))
    }

    func testWrite() {
        let useCase = GetSubmissionScoresUseCase(userId: "user-123", enrollmentId: "enrollment-456")

        let response = GetSubmissionScoresResponse(data: GetSubmissionScoresResponse.DataModel(
            legacyNode: GetSubmissionScoresResponse.LegacyNode(
                id: "enrollment-456",
                grades: GetSubmissionScoresResponse.Grades(finalScore: 85.5, finalGrade: "B"),
                course: GetSubmissionScoresResponse.Course(
                    applyGroupWeights: true,
                    assignmentGroups: [
                        GetSubmissionScoresResponse.AssignmentGroup(
                            id: "group-1",
                            name: "Assignments",
                            groupWeight: 40.0,
                            gradesConnection: GetSubmissionScoresResponse.GradesConnection(
                                nodes: [
                                    GetSubmissionScoresResponse.GradesConnectionNode(
                                        currentScore: 90.0,
                                        finalScore: 90.0,
                                        state: "graded"
                                    )
                                ]
                            ),
                            assignmentsConnection: GetSubmissionScoresResponse.AssignmentsConnection(
                                nodes: [
                                    GetSubmissionScoresResponse.Assignment(
                                        id: "assignment-1",
                                        name: "Assignment 1",
                                        pointsPossible: 100.0,
                                        htmlUrl: URL(string: "https://canvas.instructure.com/assignment/1"),
                                        dueAt: Date(),
                                        submissionsConnection: GetSubmissionScoresResponse.SubmissionNode(
                                            nodes: [
                                                GetSubmissionScoresResponse.Submission(
                                                    state: "graded",
                                                    late: false,
                                                    excused: false,
                                                    missing: false,
                                                    submittedAt: Date(),
                                                    unreadCommentCount: 0,
                                                    score: 90.0,
                                                    grade: "A-",
                                                    submissionStatus: "submitted",
                                                    commentsConnection: GetSubmissionScoresResponse.Comment(
                                                        nodes: [
                                                            GetSubmissionScoresResponse.CommentsConnectionNode(
                                                                id: "comment-1",
                                                                read: true
                                                            )
                                                        ]
                                                    )
                                                )
                                            ]
                                        ),
                                        submissionTypes: ["online_text_entry"]
                                    )
                                ]
                            )
                        )
                    ]
                )
            )
        ))

        useCase.write(response: response, urlResponse: nil, to: databaseClient)

        let scores: [CDHSubmissionScores] = databaseClient.fetch()
        XCTAssertEqual(scores.count, 1)

        let score = scores.first
        XCTAssertEqual(score?.enrollmentID, "enrollment-456")

        let groups = score?.assignmentGroups.compactMap { $0 }
        XCTAssertEqual(groups?.count, 1)

        let group = groups?.first
        XCTAssertEqual(group?.id, "group-1")
        XCTAssertEqual(group?.name, "Assignments")
        XCTAssertEqual(group?.groupWeight?.doubleValue, 40.0)

        let assignments = group?.assignments.compactMap { $0 }
        XCTAssertEqual(assignments?.count, 1)

        let assignment = assignments?.first
        XCTAssertEqual(assignment?.id, "assignment-1")
        XCTAssertEqual(assignment?.name, "Assignment 1")
        XCTAssertEqual(assignment?.pointsPossible, 100.0)
        XCTAssertEqual(assignment?.score?.doubleValue, 90.0)
        XCTAssertEqual(assignment?.state, "graded")
        XCTAssertEqual(assignment?.isLate, false)
        XCTAssertEqual(assignment?.isExcused, false)
        XCTAssertEqual(assignment?.isMissing, false)
        XCTAssertEqual(assignment?.commentsCount?.intValue, 1)
        XCTAssertEqual(assignment?.isRead, true)
    }

    func testWriteWithNilResponse() {
        let useCase = GetSubmissionScoresUseCase(userId: "user-123", enrollmentId: "enrollment-456")

        useCase.write(response: nil, urlResponse: nil, to: databaseClient)

        let scores: [CDHSubmissionScores] = databaseClient.fetch()
        XCTAssertEqual(scores.count, 0)
    }
}
