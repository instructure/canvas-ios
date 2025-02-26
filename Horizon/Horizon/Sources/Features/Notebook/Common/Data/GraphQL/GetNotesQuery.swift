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

import Core
import Foundation
import Combine

class GetNotesQuery: APIGraphQLRequestable {
    public let variables: GetNotesQueryInput

    private let jwt: String

    var path: String {
        "/graphql"
    }

    var headers: [String: String?] {
        [
            "x-apollo-operation-name": "FetchNotes",
            HttpHeader.accept: "application/json",
            HttpHeader.authorization: "Bearer \(jwt)"
        ]
    }

    public init(jwt: String, after: String, reactions: [String]? = nil) {
        self.jwt = jwt
        self.variables = GetNotesQueryInput(
            after: after,
            filter: reactions.map { GetNotesQuery.NoteFilterInput(reactions: $0) }
        )
    }

    public init(jwt: String, before: String, reactions: [String]? = nil) {
        self.jwt = jwt
        self.variables = GetNotesQueryInput(
            before: before,
            filter: reactions.map { GetNotesQuery.NoteFilterInput(reactions: $0) }
        )
    }

    public init(jwt: String, reactions: [String]? = nil) {
        self.jwt = jwt
        self.variables = GetNotesQueryInput(filter: reactions.map { GetNotesQuery.NoteFilterInput(reactions: $0) })
    }

    public static let operationName: String = "FetchNotes"
    public static var query: String {
        """
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
                        createdAt
                        highlightData
                    }
                }
                pageInfo {
                    hasNextPage
                    hasPreviousPage
                }
            }
        }
        """
    }

    typealias Response = RedwoodFetchNotesQueryResponse

    struct GetNotesQueryInput: Codable, Equatable {
        private static let pageSize: Float = 10

        let after: String?
        let before: String?
        let filter: NoteFilterInput?
        let first: Float?
        let last: Float?

        // this is used to navigate to the previous page
        init(before: String, filter: NoteFilterInput? = nil) {
            self.before = before
            self.filter = filter
            self.last = GetNotesQueryInput.pageSize

            self.after = nil
            self.first = nil
        }

        // this is used to navigate to the next page
        init(after: String, filter: NoteFilterInput? = nil) {
            self.after = after
            self.filter = filter
            self.first = GetNotesQueryInput.pageSize

            self.before = nil
            self.last = nil
        }

        // this is used to fetch the first page
        init(filter: NoteFilterInput? = nil) {
            self.filter = filter
            self.first = GetNotesQueryInput.pageSize
            self.last = GetNotesQueryInput.pageSize

            self.after = nil
            self.before = nil
        }
    }

    struct NoteFilterInput: Codable, Equatable {
        let reactions: [String]
    }
}

// MARK: - Codeables

public struct RedwoodFetchNotesQueryResponse: Codable {

    let data: ResponseData

    public struct ResponseData: Codable {
        let notes: ResponseNotes
    }

    public struct ResponseNotes: Codable {
        let edges: [ResponseEdge]
        let pageInfo: PageInfo
    }

    public struct ResponseEdge: Codable {
        let node: RedwoodNote
        let cursor: String
    }

    public struct PageInfo: Codable {
        let hasNextPage: Bool
        let hasPreviousPage: Bool
    }
}
