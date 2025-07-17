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

struct CedarSummarizeContentMutation: APIGraphQLRequestable {
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
        numParagraphs: Int = 1
    ) {
        self.variables = Variables(content: content, numParagraphs: numParagraphs)
    }

    public static let operationName: String = "SummarizeContent"
    public static var query: String = """
        mutation \(operationName)($content: String!, $numParagraphs: Float!) {
            summarizeContent(input: { content: $content, numParagraphs: $numParagraphs}) {
                summarization
            }
        }
    """

    typealias Response = CedarSummarizeContentMutationResponse

    struct Input: Codable, Equatable {
        let content: String
        let numParagraphs: Int
    }
}

// MARK: - Codeables

struct CedarSummarizeContentMutationResponse: Codable {
    struct SummarizeContent: Codable {
        let summarization: [String]
    }
    struct ResponseData: Codable {
        let summarizeContent: SummarizeContent
    }

    let data: ResponseData
}
