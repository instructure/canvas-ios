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

class CedarTranslateTextMutation: APIGraphQLRequestable {
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
        content: String,
        targetLanguage: String = "es",
        sourceLanguage: String = "en"
    ) {
        self.variables = Variables(
            content: content,
            targetLanguage: targetLanguage,
            sourceLanguage: sourceLanguage
        )
    }

    public static let operationName: String = "TranslateText"
    public static var query: String = """
        mutation \(operationName)($content: String!, $targetLanguage: String!, $sourceLanguage: String!) {
            translateText(input: { content: $content, targetLanguage: $targetLanguage, sourceLanguage: $sourceLanguage }) {
                sourceLanguage
                translation
            }
        }
    """

    typealias Response = CedarTranslateTextMutationResponse

    struct Input: Codable, Equatable {
        let content: String
        let targetLanguage: String
        let sourceLanguage: String
    }
}

// MARK: - Codeables

struct CedarTranslateTextMutationResponse: Codable {
    struct TranslateText: Codable {
        let sourceLanguage: String
        let translation: String
    }

    let data: TranslateText
}
