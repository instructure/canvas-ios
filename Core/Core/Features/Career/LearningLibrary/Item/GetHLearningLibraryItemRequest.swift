//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Foundation

public struct GetHLearningLibraryItemRequest: APIGraphQLPagedRequestable, LearningLibraryItemQueryable {
    public typealias Response = GetHLearningLibraryItemResponse
    public typealias Variables = Input

    // MARK: - Variables

    public struct Input: Codable, Equatable {
        let limit: Int
        let cursor: String?
        let forward: Bool
        let bookmarkedOnly: Bool
        let completedOnly: Bool
        let types: [String]
        let searchTerm: String?
    }

    // MARK: - Properties

    public let variables: Input

    public var path: String { "/graphql" }

    public var headers: [String: String?] = [
        HttpHeader.accept: "application/json"
    ]
    private let types = [
        "COURSE",
        "PROGRAM",
        "PAGE",
        "ASSIGNMENT",
        "QUIZ",
        "EXTERNAL_URL",
        "EXTERNAL_TOOL",
        "FILE"
    ]

    public static let operationName: String = "learningLibraryCollectionItems"

    // MARK: - Init

    public init(
        limit: Int = 100,
        cursor: String? = nil,
        forward: Bool = true,
        bookmarkedOnly: Bool = false,
        completedOnly: Bool = false,
        searchTerm: String? = nil
    ) {
        self.variables = Input(
            limit: limit,
            cursor: cursor,
            forward: forward,
            bookmarkedOnly: bookmarkedOnly,
            completedOnly: completedOnly,
            types: types,
            searchTerm: searchTerm
        )
    }

    // MARK: - Query

    public static var query: String {
            """
            query \(operationName)($limit: Int!, $cursor: String, $forward: Boolean!, $bookmarkedOnly: Boolean!, $completedOnly: Boolean!, $types: [CollectionItemType!], $searchTerm: String) {
              learningLibraryCollectionItems(
                input: {
                  limit: $limit
                  cursor: $cursor
                  forward: $forward
                  types: $types
                  searchTerm: $searchTerm
                  bookmarkedOnly: $bookmarkedOnly
                  completedOnly: $completedOnly
                }
              ) {
                \(itemsQuery)
                pageInfo {
                  nextCursor
                  previousCursor
                  hasNextPage
                  hasPreviousPage
                }
              }
            }
            """
        }

    public func nextPageRequest(from response: GetHLearningLibraryItemResponse) -> GetHLearningLibraryItemRequest? {
        guard response.data?.learningLibraryCollectionItems?.pageInfo?.hasNextPage == true else {
            return nil
        }
        let nextCursor = response.data?.learningLibraryCollectionItems?.pageInfo?.nextCursor
        return GetHLearningLibraryItemRequest(cursor: nextCursor)
    }
}
