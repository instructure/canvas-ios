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

final class GetHSubmissionScoresResponseTests: CoreTestCase {
    func testDecodingFullResponse() {
        guard let jsonData = jsonString.data(using: .utf8) else {
            XCTFail("Failed to convert JSON string to Data")
            return
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let response = try decoder.decode(GetHSubmissionScoresResponse.self, from: jsonData)

            XCTAssertEqual(response.data?.legacyNode?.id, "enrollment-123")
            XCTAssertEqual(response.data?.legacyNode?.grades?.finalScore, 85.5)
            XCTAssertEqual(response.data?.legacyNode?.grades?.finalGrade, "B")

            XCTAssertEqual(response.data?.legacyNode?.course?.applyGroupWeights, true)

            let assignmentGroup = response.data?.legacyNode?.course?.assignmentGroups?.first
            XCTAssertEqual(assignmentGroup?.id, "group-1")
            XCTAssertEqual(assignmentGroup?.name, "Assignments")
            XCTAssertEqual(assignmentGroup?.groupWeight, 40.0)

            let gradesNode = assignmentGroup?.gradesConnection?.nodes?.first
            XCTAssertEqual(gradesNode?.currentScore, 90.0)
            XCTAssertEqual(gradesNode?.finalScore, 90.0)
            XCTAssertEqual(gradesNode?.state, "graded")

            let assignment = assignmentGroup?.assignmentsConnection?.nodes?.first
            XCTAssertEqual(assignment?.id, "assignment-1")
            XCTAssertEqual(assignment?.name, "Assignment 1")
            XCTAssertEqual(assignment?.pointsPossible, 100.0)
            XCTAssertEqual(assignment?.htmlUrl?.absoluteString, "https://canvas.instructure.com/assignment/1")

            let submission = assignment?.submissionsConnection?.nodes?.first
            XCTAssertEqual(submission?.state, "graded")
            XCTAssertEqual(submission?.late, false)
            XCTAssertEqual(submission?.score, 90.0)
            XCTAssertEqual(submission?.grade, "A-")

            let comment = submission?.commentsConnection?.nodes?.first
            XCTAssertEqual(comment?.id, "comment-1")
            XCTAssertEqual(comment?.read, true)

        } catch {
            XCTFail("Failed to decode JSON: \(error)")
        }
    }

    func testDecodingMinimalResponse() {
        let jsonString = """
        {
            "data": {
                "legacyNode": {
                    "id": "enrollment-123"
                }
            }
        }
        """

        guard let jsonData = jsonString.data(using: .utf8) else {
            XCTFail("Failed to convert JSON string to Data")
            return
        }

        do {
            let response = try JSONDecoder().decode(GetHSubmissionScoresResponse.self, from: jsonData)

            XCTAssertEqual(response.data?.legacyNode?.id, "enrollment-123")
            XCTAssertNil(response.data?.legacyNode?.grades)
            XCTAssertNil(response.data?.legacyNode?.course)

        } catch {
            XCTFail("Failed to decode minimal JSON: \(error)")
        }
    }

    let jsonString = """
    {
        "data": {
            "legacyNode": {
                "id": "enrollment-123",
                "grades": {
                    "finalScore": 85.5,
                    "finalGrade": "B"
                },
                "course": {
                    "applyGroupWeights": true,
                    "assignmentGroups": [
                        {
                            "_id": "group-1",
                            "name": "Assignments",
                            "groupWeight": 40.0,
                            "gradesConnection": {
                                "nodes": [
                                    {
                                        "currentScore": 90.0,
                                        "finalScore": 90.0,
                                        "state": "graded"
                                    }
                                ]
                            },
                            "assignmentsConnection": {
                                "nodes": [
                                    {
                                        "_id": "assignment-1",
                                        "name": "Assignment 1",
                                        "pointsPossible": 100.0,
                                        "dueAt": "2023-01-01T12:00:00Z",
                                        "htmlUrl": "https://canvas.instructure.com/assignment/1",
                                        "submissionsConnection": {
                                            "nodes": [
                                                {
                                                    "state": "graded",
                                                    "late": false,
                                                    "excused": false,
                                                    "missing": false,
                                                    "submittedAt": "2023-01-01T10:00:00Z",
                                                    "unreadCommentCount": 0,
                                                    "score": 90.0,
                                                    "grade": "A-",
                                                    "submissionStatus": "submitted",
                                                    "commentsConnection": {
                                                        "nodes": [
                                                            {
                                                                "_id": "comment-1",
                                                                "read": true
                                                            }
                                                        ]
                                                    }
                                                }
                                            ]
                                        },
                                        "submissionTypes": ["online_text_entry"]
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        }
    }
    """
}
