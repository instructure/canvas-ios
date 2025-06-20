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

final class CDHScoresAssignmentTests: CoreTestCase {
    func testSaveWithFullSubmission() {
        let dueDate = Date()
        let submittedDate = Date().addingTimeInterval(-3600)

        let apiEntity = GetHSubmissionScoresResponse.Assignment(
            id: "assignment-123",
            name: "Quiz 1",
            pointsPossible: 50.0,
            htmlUrl: URL(string: "https://canvas.instructure.com/assignment/123"),
            dueAt: dueDate,
            submissionsConnection: GetHSubmissionScoresResponse.SubmissionNode(
                nodes: [
                    GetHSubmissionScoresResponse.Submission(
                        state: "graded",
                        late: true,
                        excused: false,
                        missing: false,
                        submittedAt: submittedDate,
                        unreadCommentCount: 2,
                        score: 45.0,
                        grade: "A",
                        submissionStatus: "submitted",
                        commentsConnection: GetHSubmissionScoresResponse.Comment(
                            nodes: [
                                GetHSubmissionScoresResponse.CommentsConnectionNode(id: "comment-1", read: true),
                                GetHSubmissionScoresResponse.CommentsConnectionNode(id: "comment-2", read: false)
                            ]
                        )
                    )
                ]
            ),
            submissionTypes: ["online_quiz"]
        )

        let savedEntity = CDHScoresAssignment.save(apiEntity, in: databaseClient)

        XCTAssertEqual(savedEntity.id, "assignment-123")
        XCTAssertEqual(savedEntity.name, "Quiz 1")
        XCTAssertEqual(savedEntity.pointsPossible, 50.0)
        XCTAssertEqual(savedEntity.htmlUrl?.absoluteString, "https://canvas.instructure.com/assignment/123")
        XCTAssertEqual(savedEntity.dueAt, dueDate)
        XCTAssertEqual(savedEntity.state, "graded")
        XCTAssertEqual(savedEntity.isLate, true)
        XCTAssertEqual(savedEntity.isExcused, false)
        XCTAssertEqual(savedEntity.isMissing, false)
        XCTAssertEqual(savedEntity.submittedAt, submittedDate)
        XCTAssertEqual(savedEntity.score?.doubleValue, 45.0)
        XCTAssertEqual(savedEntity.commentsCount?.intValue, 2)
        XCTAssertEqual(savedEntity.isRead, false)

        let fetchedEntity: CDHScoresAssignment? = databaseClient.first(where: #keyPath(CDHScoresAssignment.id), equals: "assignment-123")
        XCTAssertNotNil(fetchedEntity)
        XCTAssertEqual(fetchedEntity?.id, "assignment-123")
    }

    func testSaveWithExistingEntity() {
        let assignmentId = "assignment-123"
        let initialEntity: CDHScoresAssignment = databaseClient.insert()
        initialEntity.id = assignmentId
        initialEntity.name = "Old Name"
        initialEntity.pointsPossible = 10.0
        initialEntity.score = NSNumber(value: 8.0)
        initialEntity.isLate = false
        initialEntity.commentsCount = NSNumber(value: 0)
        initialEntity.isRead = true
        initialEntity.isExcused = false
        initialEntity.isMissing = false
        try! databaseClient.save()

        let apiEntity = GetHSubmissionScoresResponse.Assignment(
            id: assignmentId,
            name: "Updated Name",
            pointsPossible: 20.0,
            htmlUrl: URL(string: "https://canvas.instructure.com/assignment/123"),
            dueAt: Date(),
            submissionsConnection: GetHSubmissionScoresResponse.SubmissionNode(
                nodes: [
                    GetHSubmissionScoresResponse.Submission(
                        state: "graded",
                        late: true,
                        excused: false,
                        missing: false,
                        submittedAt: Date(),
                        unreadCommentCount: 0,
                        score: 18.0,
                        grade: "A",
                        submissionStatus: "submitted",
                        commentsConnection: nil
                    )
                ]
            ),
            submissionTypes: ["online_text_entry"]
        )

        let updatedEntity = CDHScoresAssignment.save(apiEntity, in: databaseClient)

        XCTAssertEqual(updatedEntity.objectID, initialEntity.objectID)

        XCTAssertEqual(updatedEntity.name, "Updated Name")
        XCTAssertEqual(updatedEntity.pointsPossible, 20.0)
        XCTAssertEqual(updatedEntity.score?.doubleValue, 18.0)
        XCTAssertEqual(updatedEntity.isLate, true)
    }

    func testSaveWithNoSubmission() {
        let apiEntity = GetHSubmissionScoresResponse.Assignment(
            id: "assignment-123",
            name: "Unsubmitted Assignment",
            pointsPossible: 100.0,
            htmlUrl: URL(string: "https://canvas.instructure.com/assignment/123"),
            dueAt: Date(),
            submissionsConnection: nil,
            submissionTypes: ["online_text_entry"]
        )

        let savedEntity = CDHScoresAssignment.save(apiEntity, in: databaseClient)

        XCTAssertEqual(savedEntity.id, "assignment-123")
        XCTAssertEqual(savedEntity.name, "Unsubmitted Assignment")
        XCTAssertNil(savedEntity.score)
        XCTAssertNil(savedEntity.state)
        XCTAssertEqual(savedEntity.isLate, false)
        XCTAssertEqual(savedEntity.isExcused, false)
        XCTAssertEqual(savedEntity.isMissing, false)
        XCTAssertNil(savedEntity.submittedAt)
        XCTAssertEqual(savedEntity.commentsCount?.intValue, 0)
        XCTAssertEqual(savedEntity.isRead, true)
    }

    func testSaveWithEmptySubmissionsArray() {
        let apiEntity = GetHSubmissionScoresResponse.Assignment(
            id: "assignment-123",
            name: "Assignment",
            pointsPossible: 100.0,
            htmlUrl: nil,
            dueAt: nil,
            submissionsConnection: GetHSubmissionScoresResponse.SubmissionNode(nodes: []),
            submissionTypes: nil
        )

        let savedEntity = CDHScoresAssignment.save(apiEntity, in: databaseClient)

        XCTAssertEqual(savedEntity.id, "assignment-123")
        XCTAssertNil(savedEntity.score)
        XCTAssertNil(savedEntity.state)
        XCTAssertEqual(savedEntity.isLate, false)
        XCTAssertEqual(savedEntity.isExcused, false)
        XCTAssertEqual(savedEntity.isMissing, false)
    }

    func testSaveWithNilValues() {
        let apiEntity = GetHSubmissionScoresResponse.Assignment(
            id: "assignment-123",
            name: nil,
            pointsPossible: nil,
            htmlUrl: nil,
            dueAt: nil,
            submissionsConnection: nil,
            submissionTypes: nil
        )

        let savedEntity = CDHScoresAssignment.save(apiEntity, in: databaseClient)

        XCTAssertEqual(savedEntity.id, "assignment-123")
        XCTAssertNil(savedEntity.name)
        XCTAssertEqual(savedEntity.pointsPossible, 0.0)
        XCTAssertNil(savedEntity.htmlUrl)
        XCTAssertNil(savedEntity.dueAt)
    }
}
