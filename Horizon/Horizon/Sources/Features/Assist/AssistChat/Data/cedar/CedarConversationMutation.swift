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

struct CedarConversationMutation: APIGraphQLRequestable {
    let variables: Input

    var path: String {
        "/graphql"
    }

    var headers: [String: String?] {
        [
            "x-apollo-operation-name": "\(Self.operationName)",
            HttpHeader.accept: "application/json"
        ]
    }

    public init(
        systemPrompt: String,
        messages: [DomainServiceConversationMessage]
    ) {
        self.variables = Variables(
            messages: messages,
            systemPrompt: systemPrompt
        )
    }

    public static let operationName: String = "Conversation"
    public static var query: String = """
        mutation \(operationName)($systemPrompt: String!, $messages: [MessageInput!]!) {
            conversation(input: { systemPrompt: $systemPrompt, messages: $messages } ) {
                response
            }
        }
    """

    typealias Response = CedarConversationMutationResponse

    struct Input: Codable, Equatable {
        let messages: [DomainServiceConversationMessage]
        let systemPrompt: String
    }
}

// MARK: - Codeables

struct CedarConversationMutationResponse: Codable {
    struct Conversation: Codable, Equatable {
        let response: String
    }

    struct ResponseData: Codable, Equatable {
        let conversation: Conversation
    }

    let data: ResponseData
}
