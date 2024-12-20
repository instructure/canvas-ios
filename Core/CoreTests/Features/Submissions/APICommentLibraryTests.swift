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

    let request = APICommentLibraryRequest(userId: "1")

    func testRequest() {
        let operationName = "CommentLibraryQuery"
        let query = """
            query \(operationName)($userId: ID!) {
                user: legacyNode(_id: $userId, type: User) {
                    ... on User {
                        id: _id
                        commentBankItems: commentBankItemsConnection(query: "") {
                            nodes {
                                comment: comment
                                id: _id
                            }
                        }
                    }
                }
            }
            """
        XCTAssertEqual(request.body?.query, query)
        XCTAssertEqual(request.variables.userId, "1")
    }

    func testResponse() {
        let comments = [APICommentLibraryResponse.CommentBankItem(id: "1", comment: "First comment"),
                        APICommentLibraryResponse.CommentBankItem(id: "2", comment: "Second comment") ]
        let data = APICommentLibraryResponse.Data.init(user: .init(id: "1", commentBankItems: .init(nodes: comments )))
        let response =  APICommentLibraryResponse(data: data)
        api.mock(APICommentLibraryRequest(userId: "1"), value: response)
        api.makeRequest(request) { response, _, _  in
            XCTAssertEqual(response?.data, data)
            XCTAssertEqual(response?.comments[0].id, "1")
            XCTAssertEqual(response?.comments[0].comment, "First comment")
            XCTAssertEqual(response?.comments[1].id, "2")
            XCTAssertEqual(response?.comments[1].comment, "Second comment")
        }
    }
}
