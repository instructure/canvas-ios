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

final class GetNotesQuery: APIGraphQLPagedRequestable {
    typealias Response = RedwoodFetchNotesQueryResponse

    public let variables: GetNotesQueryInput
    public static let operationName: String = "FetchNotes"
    var path: String { "/graphql" }
    var headers: [String: String?] {
        [
            "x-apollo-operation-name": "FetchNotes",
            HttpHeader.accept: "application/json"
        ]
    }

    // For geting all notes
    public init() {
        self.variables = GetNotesQueryInput(before: nil, filter: nil)
    }

    public init(filter: NotebookQueryFilter) {
        self.variables = GetNotesQueryInput(
            before: filter.startCursor,
            filter: GetNotesQuery.NoteFilterInput.build(
                courseId: filter.courseId,
                objectId: filter.pageId,
                reactions: filter.reactions
            )
        )
    }

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

    func nextPageRequest(from response: RedwoodFetchNotesQueryResponse) -> GetNotesQuery? {
        guard response.data.notes.pageInfo.hasPreviousPage else {
            return nil
        }
        return GetNotesQuery(filter: .init(startCursor: response.data.notes.pageInfo.startCursor))
    }
}

// MARK: - Filter Models

extension GetNotesQuery {
    struct GetNotesQueryInput: Codable, Equatable {
        private static let pageSize: Float = 100 // Max value is 1000

        let after: String?
        let before: String?
        let filter: NoteFilterInput?
        let first: Float?
        let last: Float?

        // this is used to navigate to the previous page
        init(before: String?, filter: NoteFilterInput? = nil) {
            self.before = before
            self.filter = filter
            self.last = GetNotesQueryInput.pageSize

            self.after = nil
            self.first = nil
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
            let isEmptyCourse = (courseId == nil)
            let isEmptyReactions = (reactions == nil || reactions?.isEmpty == true)
            let isEmptyObjectId = (objectId == nil)

            // If all filters are empty → return nil
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
