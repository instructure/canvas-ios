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

public struct LearningLibraryBookMarkRequest: APIGraphQLRequestable {
    public typealias Response = LearningLibraryBookMarkResponse
    public typealias Variables = Input

    public struct Input: Codable, Equatable {
        let input: CollectionItemInput

        public struct CollectionItemInput: Codable, Equatable {
            let collectionItemId: String
        }
    }

    // MARK: - Properties

    public let variables: Input
    public var path: String { "/graphql" }
    public static let operationName: String = "ToggleCollectionItemBookmark"
    public var headers: [String: String?] = [
        HttpHeader.accept: "application/json"
    ]

    public init(id: String) {
        self.variables = .init(
            input: .init(collectionItemId: id)
        )
    }

    public static var query: String {
        """
        mutation \(operationName)($input: ToggleCollectionItemBookmarkInput!) {
          toggleCollectionItemBookmark(input: $input) {
            isBookmarked
          }
        }
        """
    }
}
