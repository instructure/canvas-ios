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

struct PineQueryMutation: APIGraphQLRequestable {
    let variables: Variables

    var path: String {
        "/graphql"
    }

    var headers: [String: String?] {
        [
            "x-apollo-operation-name": "\(Self.operationName)",
            HttpHeader.accept: "application/json"
        ]
    }

    public init(messages: [DomainServiceConversationMessage], courseID: String) {
        self.variables = Variables(
            input: RagQueryInput(
                messages: messages,
                source: "canvas",
                metadata: Metadata(courseId: courseID)
            )
        )
    }

    public static let operationName: String = "ChatPrompt"
    public static var query: String = """
        mutation \(operationName)($input: RagQueryInput!) {
            query(input: $input) {
                response
            }
        }
    """

    typealias Response = RagData

    struct Variables: Codable, Equatable {
        let input: RagQueryInput
    }

    struct RagQueryInput: Codable, Equatable {
        let messages: [DomainServiceConversationMessage]
        let source: String
        let metadata: Metadata
    }

    struct RagData: Codable {
        let data: RagQuery
    }

    struct RagQuery: Codable {
        let query: RagResponse
    }

    struct RagResponse: Codable {
        let response: String
    }

    struct Metadata: Codable, Equatable {
        let courseId: String
    }
}
