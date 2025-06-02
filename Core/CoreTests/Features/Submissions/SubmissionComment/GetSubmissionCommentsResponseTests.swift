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

class GetSubmissionCommentsResponseTests: CoreTestCase {
    func testDecodingCompleteResponse() throws {
        let jsonString = """
        {
            "data": {
                "submission": {
                    "id": "submission-123",
                    "unreadCommentCount": 2,
                    "commentsConnection": {
                        "pageInfo": {
                            "endCursor": "end-cursor",
                            "startCursor": "start-cursor",
                            "hasPreviousPage": false,
                            "hasNextPage": true
                        },
                        "edges": [
                            {
                                "node": {
                                    "id": "comment-1",
                                    "attempt": 1,
                                    "author": {
                                        "_id": "author-1",
                                        "avatarUrl": "https://example.com/avatar1.jpg",
                                        "shortName": "Test Author 1"
                                    },
                                    "comment": "This is the first comment",
                                    "read": true,
                                    "updatedAt": "2025-01-01T12:00:00Z",
                                    "createdAt": "2025-01-01T12:00:00Z"
                                }
                            },
                            {
                                "node": {
                                    "id": "comment-2",
                                    "attempt": 2,
                                    "author": {
                                        "_id": "author-2",
                                        "avatarUrl": "https://example.com/avatar2.jpg",
                                        "shortName": "Test Author 2"
                                    },
                                    "comment": "This is the second comment",
                                    "read": false,
                                    "updatedAt": "2025-01-02T12:00:00Z",
                                    "createdAt": "2025-01-02T12:00:00Z"
                                }
                            }
                        ]
                    }
                }
            }
        }
        """

        let jsonData = jsonString.data(using: .utf8)!

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(GetSubmissionCommentsResponse.self, from: jsonData)

        XCTAssertNotNil(response.data)
        XCTAssertNotNil(response.data?.submission)
        XCTAssertEqual(response.data?.submission?.id, "submission-123")
        XCTAssertEqual(response.data?.submission?.unreadCommentCount, 2)

        let pageInfo = response.data?.submission?.commentsConnection?.pageInfo
        XCTAssertEqual(pageInfo?.endCursor, "end-cursor")
        XCTAssertEqual(pageInfo?.startCursor, "start-cursor")
        XCTAssertEqual(pageInfo?.hasPreviousPage, false)
        XCTAssertEqual(pageInfo?.hasNextPage, true)

        let edges = response.data?.submission?.commentsConnection?.edges
        XCTAssertEqual(edges?.count, 2)

        let firstComment = edges?.first?.node
        XCTAssertEqual(firstComment?.id, "comment-1")
        XCTAssertEqual(firstComment?.attempt, 1)
        XCTAssertEqual(firstComment?.author?.id, "author-1")
        XCTAssertEqual(firstComment?.author?.avatarURL, "https://example.com/avatar1.jpg")
        XCTAssertEqual(firstComment?.author?.shortName, "Test Author 1")
        XCTAssertEqual(firstComment?.comment, "This is the first comment")
        XCTAssertEqual(firstComment?.read, true)
        XCTAssertEqual(firstComment?.createdAt, dateFormatter.date(from: "2025-01-01T12:00:00Z"))

        let secondComment = edges?.last?.node
        XCTAssertEqual(secondComment?.id, "comment-2")
        XCTAssertEqual(secondComment?.attempt, 2)
        XCTAssertEqual(secondComment?.author?.id, "author-2")
        XCTAssertEqual(secondComment?.author?.avatarURL, "https://example.com/avatar2.jpg")
        XCTAssertEqual(secondComment?.author?.shortName, "Test Author 2")
        XCTAssertEqual(secondComment?.comment, "This is the second comment")
        XCTAssertEqual(secondComment?.read, false)
        XCTAssertEqual(secondComment?.createdAt, dateFormatter.date(from: "2025-01-02T12:00:00Z"))
    }

    func testDecodingPartialResponse() throws {
        let jsonString = """
        {
            "data": {
                "submission": {
                    "id": "submission-123",
                    "commentsConnection": {
                        "edges": [
                            {
                                "node": {
                                    "id": "comment-1",
                                    "author": {
                                        "_id": "author-1",
                                        "shortName": "Test Author 1"
                                    },
                                    "comment": "This is a comment"
                                }
                            }
                        ]
                    }
                }
            }
        }
        """

        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(GetSubmissionCommentsResponse.self, from: jsonData)

        XCTAssertNotNil(response.data)
        XCTAssertNotNil(response.data?.submission)
        XCTAssertEqual(response.data?.submission?.id, "submission-123")
        XCTAssertNil(response.data?.submission?.unreadCommentCount)

        let edges = response.data?.submission?.commentsConnection?.edges
        XCTAssertEqual(edges?.count, 1)

        let comment = edges?.first?.node
        XCTAssertEqual(comment?.id, "comment-1")
        XCTAssertNil(comment?.attempt)
        XCTAssertEqual(comment?.author?.id, "author-1")
        XCTAssertNil(comment?.author?.avatarURL)
        XCTAssertEqual(comment?.author?.shortName, "Test Author 1")
        XCTAssertEqual(comment?.comment, "This is a comment")
        XCTAssertNil(comment?.read)
        XCTAssertNil(comment?.createdAt)
        XCTAssertNil(comment?.updatedAt)
    }

    func testEmptyResponse() throws {
        let jsonString = """
        {
            "data": {
                "submission": null
            }
        }
        """

        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()

        let response = try decoder.decode(GetSubmissionCommentsResponse.self, from: jsonData)

        XCTAssertNotNil(response.data)
        XCTAssertNil(response.data?.submission)
    }
}
