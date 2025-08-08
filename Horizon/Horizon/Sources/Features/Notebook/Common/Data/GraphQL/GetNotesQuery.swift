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

    var path: String {
        "/graphql"
    }

    var headers: [String: String?] {
        [
            "x-apollo-operation-name": "FetchNotes",
            HttpHeader.accept: "application/json"
        ]
    }

    public init(
        after: String,
        reactions: [String]? = nil,
        courseId: String? = nil,
        objectId: String? = nil
    ) {
        let filter = GetNotesQuery.NoteFilterInput.build(
            courseId: courseId,
            objectId: objectId,
            reactions: reactions
        )

        self.variables = GetNotesQueryInput(
            after: after,
            filter: filter
        )
    }

    public init(
        before: String,
        reactions: [String]? = nil,
        courseId: String? = nil,
        objectId: String? = nil
    ) {
        self.variables = GetNotesQueryInput(
            before: before,
            filter: GetNotesQuery.NoteFilterInput.build(
                courseId: courseId,
                objectId: objectId,
                reactions: reactions
            )
        )
    }

    public init(
        reactions: [String]? = nil,
        courseId: String? = nil,
        objectId: String? = nil
    ) {
        self.variables = GetNotesQueryInput(
            filter: GetNotesQuery.NoteFilterInput.build(
                courseId: courseId,
                objectId: objectId,
                reactions: reactions
            )
        )
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
        private static let pageSize: Float = 1000

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
        let reactions: [String]?
        let courseId: String?
        let learningObject: LearningObjectFilter?

        private init(
            courseId: String? = nil,
            reactions: [String]? = nil,
            learningObject: LearningObjectFilter? = nil
        ) {
            self.courseId = courseId
            self.reactions = reactions
            self.learningObject = learningObject
        }

        static func build(
            courseId: String? = nil,
            objectId: String? = nil,
            reactions: [String]? = nil
        ) -> NoteFilterInput? {
            if courseId == nil && (reactions == nil || reactions?.isEmpty == true) {
                return nil
            }

            return .init(
                courseId: courseId,
                reactions: reactions,
                learningObject: GetNotesQuery.LearningObjectFilter.build(id: objectId)
            )
        }
    }

    struct LearningObjectFilter: Codable, Equatable {
        let type: String
        let id: String

        private init(type: String, id: String) {
            self.type = type
            self.id = id
        }

        static func build(id: String?) -> LearningObjectFilter? {
            guard let id = id else {
                return nil
            }
            return .init(type: APIModuleItemType.page.rawValue, id: id)
        }
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
