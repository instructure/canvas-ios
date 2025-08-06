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
            "x-feature-slug": "canvas-career-ios",
            HttpHeader.accept: "application/json"
        ]
    }

    public init(
        messages: [DomainServiceConversationMessage],
        courseID: String,
        sourceID: String? = nil,
        sourceType: LearningObjectFilterType? = nil
    ) {
        self.variables = Variables(
            input: CourseRagQueryInput(
                messages: messages,
                courseId: courseID,
                learningObjectFilters: LearningObjectFilter(id: sourceID, type: sourceType).map { [$0] }
            )
        )
    }

    public static let operationName: String = "CourseRAGQuery"
    public static var query: String = """
        mutation \(operationName)($input: CourseRagQueryInput!) {
            courseQuery(input: $input) {
                response
                citations {
                    sourceType
                    sourceId
                    metadata
                }
            }
        }
    """

    typealias Response = RagData

    enum LearningObjectFilterType: String, Codable, Equatable {
        case File
        case Page
    }

    struct Variables: Codable, Equatable {
        let input: CourseRagQueryInput
    }

    struct LearningObjectFilter: Codable, Equatable {
        let id: String
        let type: LearningObjectFilterType

        init?(id: String?, type: LearningObjectFilterType?) {
            guard let id = id, let type = type else { return nil }
            self.id = id
            self.type = type
        }
    }

    struct CourseRagQueryInput: Codable, Equatable {
        let messages: [DomainServiceConversationMessage]
        let courseId: String
        let learningObjectFilters: [LearningObjectFilter]?
    }

    struct RagData: Codable {
        let data: RagQuery
    }

    struct RagQuery: Codable {
        let courseQuery: RagResponse
    }

    struct RagResponse: Codable {
        let response: String
        let citations: [RagCitation]
    }

    struct RagCitation: Codable {
        let sourceType: String
        let sourceId: String
        let metadata: [String: String]
    }
}

extension AssistChatInteractor.AssetType {
    var learningObjectFilterType: PineQueryMutation.LearningObjectFilterType? {
        PineQueryMutation.LearningObjectFilterType(rawValue: self.rawValue)
    }
}
