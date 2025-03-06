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

class CedarAnswerPromptMutation: APIGraphQLRequestable {
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
        prompt: String,
        model: AIModel = .claude3Sonnet20240229V10
    ) {
        self.variables = Variables(model: model.rawValue, prompt: prompt)
    }

    public static let operationName: String = "AnswerPrompt"
    public static var query: String = """
        mutation \(operationName)($model: String!, $prompt: String!) {
            answerPrompt(input: { model: $model, prompt: $prompt })
        }
    """

    typealias Response = CedarAnswerPromptMutationResponse

    struct Input: Codable, Equatable {
        let model: String
        let prompt: String
    }
}

// MARK: - Codeables

struct CedarAnswerPromptMutationResponse: Codable {
    struct ResponseData: Codable {
        let answerPrompt: String
    }

    let data: ResponseData
}
