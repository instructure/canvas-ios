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

final class CDScoresAssignmentGroupTests: CoreTestCase {
    func testSave() {
        let apiEntity = GetSubmissionScoresResponse.AssignmentGroup(
            id: "group-123",
            name: "Homework",
            groupWeight: 35.5,
            gradesConnection: GetSubmissionScoresResponse.GradesConnection(
                nodes: [
                    GetSubmissionScoresResponse.GradesConnectionNode(
                        currentScore: 88.5,
                        finalScore: 88.5,
                        state: "graded"
                    )
                ]
            ),
            assignmentsConnection: GetSubmissionScoresResponse.AssignmentsConnection(
                nodes: [
                    GetSubmissionScoresResponse.Assignment(
                        id: "assignment-1",
                        name: "Homework 1",
                        pointsPossible: 50.0,
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
                                    score: 45.0,
                                    grade: "A",
                                    submissionStatus: "submitted",
                                    commentsConnection: nil
                                )
                            ]
                        ),
                        submissionTypes: ["online_text_entry"]
                    )
                ]
            )
        )

        let enrollmentId = "enrollment-456"
        let savedEntity = CDHScoresAssignmentGroup.save(apiEntity, enrollmentId: enrollmentId, in: databaseClient)

        XCTAssertEqual(savedEntity.enrollmentID, enrollmentId)
        XCTAssertEqual(savedEntity.id, "group-123")
        XCTAssertEqual(savedEntity.name, "Homework")
        XCTAssertEqual(savedEntity.groupWeight?.doubleValue, 35.5)

        XCTAssertEqual(savedEntity.assignments.count, 1)
        let assignment = savedEntity.assignments.first
        XCTAssertEqual(assignment?.id, "assignment-1")
        XCTAssertEqual(assignment?.name, "Homework 1")

        let fetchedEntity: CDHScoresAssignmentGroup? = databaseClient.first(where: #keyPath(CDHScoresAssignmentGroup.id), equals: "group-123")
        XCTAssertNotNil(fetchedEntity)
        XCTAssertEqual(fetchedEntity?.id, "group-123")
    }

    func testSaveWithExistingEntity() {
        let groupId = "group-123"
        let initialEntity: CDHScoresAssignmentGroup = databaseClient.insert()
        initialEntity.enrollmentID = "enrollment-456"
        initialEntity.id = groupId
        initialEntity.name = "Old Name"
        initialEntity.groupWeight = NSNumber(value: 10.0)
        initialEntity.assignments = []
        try! databaseClient.save()

        let apiEntity = GetSubmissionScoresResponse.AssignmentGroup(
            id: groupId,
            name: "Updated Name",
            groupWeight: 20.0,
            gradesConnection: nil,
            assignmentsConnection: GetSubmissionScoresResponse.AssignmentsConnection(
                nodes: [
                    GetSubmissionScoresResponse.Assignment(
                        id: "assignment-2",
                        name: "New Assignment",
                        pointsPossible: 100.0,
                        htmlUrl: nil,
                        dueAt: nil,
                        submissionsConnection: nil,
                        submissionTypes: nil
                    )
                ]
            )
        )

        let updatedEntity = CDHScoresAssignmentGroup.save(apiEntity, enrollmentId: "enrollment-updated", in: databaseClient)

        XCTAssertEqual(updatedEntity.objectID, initialEntity.objectID)

        // Verify properties were updated
        XCTAssertEqual(updatedEntity.enrollmentID, "enrollment-updated") // Enrollment ID should be updated
        XCTAssertEqual(updatedEntity.name, "Updated Name")
        XCTAssertEqual(updatedEntity.groupWeight?.doubleValue, 20.0)

        XCTAssertEqual(updatedEntity.assignments.count, 1)
        XCTAssertEqual(updatedEntity.assignments.first?.id, "assignment-2")
    }

    func testSaveWithNilValues() {
        let apiEntity = GetSubmissionScoresResponse.AssignmentGroup(
            id: "group-123",
            name: nil,
            groupWeight: nil,
            gradesConnection: nil,
            assignmentsConnection: nil
        )

        let enrollmentId = "enrollment-456"
        let savedEntity = CDHScoresAssignmentGroup.save(apiEntity, enrollmentId: enrollmentId, in: databaseClient)

        XCTAssertEqual(savedEntity.enrollmentID, enrollmentId)
        XCTAssertEqual(savedEntity.id, "group-123")
        XCTAssertNil(savedEntity.name)
        XCTAssertNil(savedEntity.groupWeight)
        XCTAssertEqual(savedEntity.assignments.count, 0)
    }

    func testSaveWithEmptyAssignmentsArray() {
        let apiEntity = GetSubmissionScoresResponse.AssignmentGroup(
            id: "group-123",
            name: "Homework",
            groupWeight: 35.5,
            gradesConnection: nil,
            assignmentsConnection: GetSubmissionScoresResponse.AssignmentsConnection(nodes: [])
        )

        let enrollmentId = "enrollment-456"
        let savedEntity = CDHScoresAssignmentGroup.save(apiEntity, enrollmentId: enrollmentId, in: databaseClient)

        XCTAssertEqual(savedEntity.assignments.count, 0)
    }
}
