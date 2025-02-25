//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Foundation
import XCTest
@testable import Core

class APICommentLibraryTests: CoreTestCase {

    func testRequest() {
        let operationName = "CommentLibraryQuery"
        let query = """
            query \(operationName)($query: String, $userId: ID!, $pageSize: Int!, $cursor: String) {
                user: legacyNode(_id: $userId, type: User) {
                    ... on User {
                        id: _id
                        commentBankItems: commentBankItemsConnection(query: $query, first: $pageSize, after: $cursor) {
                            nodes {
                                comment: comment
                                id: _id
                            }
                            pageInfo {
                                endCursor
                                hasNextPage
                            }
                        }
                    }
                }
            }
            """

        let request = APICommentLibraryRequest(userId: "1")

        XCTAssertEqual(request.body?.query, query)
        XCTAssertEqual(request.variables.userId, "1")
        XCTAssertEqual(request.variables.pageSize, 20)
        XCTAssertNil(request.variables.cursor)
    }

    func testResponse() {
        let mockedResponse = makeResponse(pageInfo: nil)
        let request = APICommentLibraryRequest(userId: "1")

        api.mock(request, value: mockedResponse)
        api.makeRequest(request) { response, _, _  in
            XCTAssertEqual(response?.data, mockedResponse.data)
            XCTAssertEqual(response?.comments[0].id, "1")
            XCTAssertEqual(response?.comments[0].comment, "First comment")
            XCTAssertEqual(response?.comments[1].id, "2")
            XCTAssertEqual(response?.comments[1].comment, "Second comment")
        }
    }

    func test_next_page() throws {
        let response = makeResponse(
            pageInfo: APIPageInfo(endCursor: "next_cursor", hasNextPage: true)
        )

        let nextRequest = try XCTUnwrap(
            APICommentLibraryRequest(userId: "1").nextPageRequest(from: response)
        )

        XCTAssertEqual(nextRequest.variables.cursor, "next_cursor")
    }

    func test_no_next_page() throws {
        // Case 1
        var response = makeResponse(
            pageInfo: APIPageInfo(endCursor: "next_cursor", hasNextPage: false)
        )
        var nextRequest = APICommentLibraryRequest(userId: "1")
            .nextPageRequest(from: response)
        XCTAssertNil(nextRequest)

        // Case 2
        response = makeResponse(pageInfo: nil)
        nextRequest = APICommentLibraryRequest(userId: "1")
            .nextPageRequest(from: response)
        XCTAssertNil(nextRequest)
    }

    private func makeResponse(pageInfo: APIPageInfo?) -> APICommentLibraryResponse {
        let comments = [APICommentLibraryResponse.CommentBankItem(id: "1", comment: "First comment"),
                        APICommentLibraryResponse.CommentBankItem(id: "2", comment: "Second comment") ]
        let data = APICommentLibraryResponse.Data
            .init(
                user: .init(
                    id: "1",
                    commentBankItems: .init(
                        nodes: comments,
                        pageInfo: pageInfo
                    )
                )
            )
        return APICommentLibraryResponse(data: data)
    }
}
