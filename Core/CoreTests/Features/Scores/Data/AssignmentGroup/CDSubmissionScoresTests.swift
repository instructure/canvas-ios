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

final class CDSubmissionScoresTests: CoreTestCase {
    func testSave() {
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

        let enrollmentId = "enrollment-456"
        let savedEntity = CDHSubmissionScores.save(response, enrollmentId: enrollmentId, in: databaseClient)

        XCTAssertEqual(savedEntity.enrollmentID, enrollmentId)
        XCTAssertEqual(savedEntity.assignmentGroups.count, 1)

        let group = savedEntity.assignmentGroups.first
        XCTAssertEqual(group?.id, "group-1")
        XCTAssertEqual(group?.name, "Assignments")
        XCTAssertEqual(group?.groupWeight?.doubleValue, 40.0)

        let fetchedEntity: CDHSubmissionScores? = databaseClient.first(where: #keyPath(CDHSubmissionScores.enrollmentID), equals: enrollmentId)
        XCTAssertNotNil(fetchedEntity)
        XCTAssertEqual(fetchedEntity?.enrollmentID, enrollmentId)
    }

    func testSaveWithExistingEntity() {
        let enrollmentId = "enrollment-456"
        let initialEntity: CDHSubmissionScores = databaseClient.insert()
        initialEntity.enrollmentID = enrollmentId
        initialEntity.assignmentGroups = []
        try! databaseClient.save()

        let response = GetSubmissionScoresResponse(data: GetSubmissionScoresResponse.DataModel(
            legacyNode: GetSubmissionScoresResponse.LegacyNode(
                id: enrollmentId,
                grades: nil,
                course: GetSubmissionScoresResponse.Course(
                    applyGroupWeights: false,
                    assignmentGroups: [
                        GetSubmissionScoresResponse.AssignmentGroup(
                            id: "group-2",
                            name: "Updated Group",
                            groupWeight: 60.0,
                            gradesConnection: nil,
                            assignmentsConnection: nil
                        )
                    ]
                )
            )
        ))

        let updatedEntity = CDHSubmissionScores.save(response, enrollmentId: enrollmentId, in: databaseClient)

        XCTAssertEqual(updatedEntity.objectID, initialEntity.objectID)

        XCTAssertEqual(updatedEntity.assignmentGroups.count, 1)
        XCTAssertEqual(updatedEntity.assignmentGroups.first?.id, "group-2")
        XCTAssertEqual(updatedEntity.assignmentGroups.first?.name, "Updated Group")
    }

    func testSaveWithNoAssignmentGroups() {
        let response = GetSubmissionScoresResponse(data: GetSubmissionScoresResponse.DataModel(
            legacyNode: GetSubmissionScoresResponse.LegacyNode(
                id: "enrollment-456",
                grades: nil,
                course: GetSubmissionScoresResponse.Course(
                    applyGroupWeights: false,
                    assignmentGroups: nil
                )
            )
        ))

        let enrollmentId = "enrollment-456"
        let entity = CDHSubmissionScores.save(response, enrollmentId: enrollmentId, in: databaseClient)

        XCTAssertEqual(entity.assignmentGroups.count, 0)
    }
}
