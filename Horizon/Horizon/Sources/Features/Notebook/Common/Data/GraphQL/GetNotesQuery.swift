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

final class GetNotesQuery: APIGraphQLPagedRequestable, RedwoodProxyRequestable {
    typealias Response = RedwoodFetchNotesQueryResponse

    public let innerVariables: FetchNotesVariables
    public static let operationName: String = "RedwoodGetNotes"

    var path: String { "/graphql" }
    var shouldAddNoVerifierQuery: Bool = false
    var headers: [String: String?] {
        [
            "x-apollo-operation-name": GetNotesQuery.operationName,
            HttpHeader.accept: "application/json"
        ]
    }

    // MARK: - Init

    public init() {
        self.innerVariables = FetchNotesVariables(before: nil, filter: nil)
    }

    public init(filter: NotebookQueryFilter) {
        self.innerVariables = FetchNotesVariables(
            before: filter.startCursor,
            filter: NoteFilterInput.build(
                courseId: filter.courseId,
                objectId: filter.pageId,
                reactions: filter.reactions
            )
        )
    }

    private init(innerVariables: FetchNotesVariables) {
        self.innerVariables = innerVariables
    }

    public static var innerOperationName: String = "FetchNotes"

    public static var innerQuery: String {
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
                        updatedAt
                        highlightData
                    }
                }
                pageInfo {
                    endCursor
                    startCursor
                    hasNextPage
                    hasPreviousPage
                }
            }
        }
        """
    }

    // MARK: - Pagination

    func nextPageRequest(from response: RedwoodFetchNotesQueryResponse) -> GetNotesQuery? {
        guard response.data.executeRedwoodQuery.data.notes.pageInfo.hasPreviousPage else {
            return nil
        }

        // We reconstruct variables for pagination logic based on the cursor
        // Note: This matches the logic of your previous implementation assuming
        // implicit state or simplified cursor movement.
        let nextVars = FetchNotesVariables(
            before: response.data.executeRedwoodQuery.data.notes.pageInfo.startCursor,
            filter: nil
        )
        return GetNotesQuery(innerVariables: nextVars)
    }
}

// MARK: - Models

extension GetNotesQuery {
    struct FetchNotesVariables: CodableEquatable {
        private static let pageSize: Float = 100

        let after: String?
        let before: String?
        let filter: NoteFilterInput?
        let first: Float?
        let last: Float?

        init(before: String?, filter: NoteFilterInput? = nil) {
            self.before = before
            self.filter = filter
            self.last = FetchNotesVariables.pageSize
            self.after = nil
            self.first = nil
        }
    }

    // MARK: Filter Logic
    struct NoteFilterInput: CodableEquatable {
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
            let isEmptyCourse = (courseId == nil)
            let isEmptyReactions = (reactions == nil || reactions?.isEmpty == true)
            let isEmptyObjectId = (objectId == nil)

            if isEmptyCourse && isEmptyReactions && isEmptyObjectId {
                return nil
            }

            return .init(
                courseId: courseId,
                reactions: reactions,
                learningObject: LearningObjectFilter.build(id: objectId)
            )
        }
    }

    struct LearningObjectFilter: CodableEquatable {
        let type: String
        let id: String

        private init(type: String, id: String) {
            self.type = type
            self.id = id
        }

        static func build(id: String?) -> LearningObjectFilter? {
            guard let id = id else { return nil }
            return .init(type: APIModuleItemType.page.rawValue, id: id)
        }
    }
}
