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

    public init(jwt: String, after: String? = nil) {
        self.jwt = jwt
        self.variables = GetNotesQueryInput(after: after)
    }

    public static let operationName: String = "FetchNotes"
    public static var query: String = """
    query \(operationName) {
        notes (after: $after) {
            nodes {
                id
                courseId
                objectId
                objectType
                userText
                reaction
                createdAt
            }
            pageInfo {
                hasNextPage
                endCursor
            }
        }
    }
    """

    typealias Response = RedwoodFetchNotesQueryResponse

    struct GetNotesQueryInput: Codable, Equatable {
        let after: String?
    }
}

// MARK: - Codeables

struct RedwoodFetchNotesQueryResponse: Codable {

    let data: ResponseData

    struct ResponseData: Codable {
        let notes: ResponseNode
    }

    struct ResponseNode: Codable {
        let nodes: [RedwoodNote]
        let pageInfo: PageInfo
    }

    struct PageInfo: Codable {
        let hasNextPage: Bool
        let endCursor: String?
    }
}
