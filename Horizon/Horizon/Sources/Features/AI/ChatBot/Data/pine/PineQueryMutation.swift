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

class PineQueryMutation: APIGraphQLRequestable {
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

    public init(messages: [MessageInput]) {
        self.variables = Variables(
                input: RagQueryInput(
                messages: messages,
                source: "canvas",
                metadata: ""
            )
        )
    }

    public static let operationName: String = "query"
    public static var query: String = """
        mutation \(operationName)($input: RagQueryInput!) {
            \(operationName)(input: $input) {
                response
            }
        }
    """

    typealias Response = RagResponse

    struct Variables: Codable, Equatable {
        let input: RagQueryInput
    }

    struct RagQueryInput: Codable, Equatable {
        let messages: [MessageInput]
        let source: String
        let metadata: String
    }

    struct MessageInput: Codable, Equatable {
        let role: Role
        let text: String

        init(text: String, role: Role) {
            self.text = text
            self.role = role
        }
    }

    struct RagResponse: Codable {
        let response: String
    }

    enum Role: String, Codable {
        case Assistant
        case User
    }
}
