//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
@testable import Horizon

final class GetNotesQueryTests: XCTestCase {
    func test_path() {
        XCTAssertEqual(GetNotesQuery().path, "/graphql")
    }

    func test_headers() {

        XCTAssertEqual(GetNotesQuery().headers["x-apollo-operation-name"], "RedwoodGetNotes")
        XCTAssertEqual(GetNotesQuery().headers["Accept"], "application/json")
    }

    func test_query_isCorrect() {
        let expected = """
            mutation RedwoodGetNotes($input: RedwoodQueryInput!) {
                executeRedwoodQuery(input: $input) {
                    data
                    errors
                }
            }
            """

        XCTAssertEqual(GetNotesQuery.query, expected)
    }

    func test_innerQuery_isCorrect() {
        let expected = """
        query FetchNotes($filter: NoteFilterInput, $first: Float, $last: Float, $after: String, $before: String) {
            notes(filter: $filter, first: $first, last: $last, after: $after, before: $before) {
                edges {
                    cursor
                    node {
                        id
                        courseId
                        objectId
                        objectType
                        userText
                        reaction
                        updatedAt
                        highlightData
                    }
                }
                pageInfo {
                    endCursor
                    startCursor
                    hasNextPage
                    hasPreviousPage
                }
            }
        }
        """

        XCTAssertEqual(GetNotesQuery.innerQuery, expected)
    }

    func test_variables_areWrappedCorrectly() {
        let query = GetNotesQuery()

        let expected = RedwoodProxyInput(
            input: RedwoodProxyPayload(
                query: GetNotesQuery.innerQuery,
                variables: GetNotesQuery.FetchNotesVariables(
                    before: nil,
                    filter: nil
                ),
                operationName: GetNotesQuery.innerOperationName
            )
        )

        XCTAssertEqual(query.variables, expected)
    }

    func test_initWithFilter_setsCorrectVariables() {
        let filter = NotebookQueryFilter(
            startCursor: "cursor123",
            reactions: ["like"],
            courseId: "course_1",
            pageId: "page_1"
        )

        let query = GetNotesQuery(filter: filter)

        XCTAssertEqual(query.innerVariables.before, "cursor123")
        XCTAssertEqual(query.innerVariables.filter?.courseId, "course_1")
        XCTAssertEqual(query.innerVariables.filter?.learningObject?.id, "page_1")
        XCTAssertEqual(query.innerVariables.filter?.reactions, ["like"])
    }

    func test_nextPageRequest_returnsNil_whenNoPreviousPage() {
        let response = RedwoodFetchNotesQueryResponse.mock(
            hasPreviousPage: false
        )

        let query = GetNotesQuery()
        let next = query.nextPageRequest(from: response)

        XCTAssertNil(next)
    }

    func test_nextPageRequest_returnsNextQuery_whenPreviousPageExists() {
        let response = RedwoodFetchNotesQueryResponse.mock(
            hasPreviousPage: true,
            startCursor: "next_cursor"
        )

        let query = GetNotesQuery()
        let next = query.nextPageRequest(from: response)

        XCTAssertEqual(next?.innerVariables.before, "next_cursor")
    }
}

extension RedwoodFetchNotesQueryResponse {
    static func mock(
        hasPreviousPage: Bool,
        startCursor: String = "cursor"
    ) -> Self {
        RedwoodFetchNotesQueryResponse(
            data: .init(
                executeRedwoodQuery: .init(
                    data: .init(
                        notes: .init(
                            edges: [],
                            pageInfo: .init(
                                hasNextPage: true,
                                hasPreviousPage: hasPreviousPage,
                                endCursor: nil,
                                startCursor: startCursor
                            )
                        )
                    )
                )
            )
        )
    }
}
