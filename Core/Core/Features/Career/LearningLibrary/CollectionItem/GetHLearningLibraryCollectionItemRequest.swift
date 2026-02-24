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

public struct GetHLearningLibraryCollectionItemRequest: APIGraphQLRequestable, LearningLibraryItemQueryable {
    public typealias Response = GetHLearningLibraryCollectionItemResponse
    public typealias Variables = Input

    // MARK: - Variables

    public struct Input: Codable, Equatable {
        let id: String
    }

    // MARK: - Properties

    public let variables: Input

    public var path: String { "/graphql" }

    public var headers: [String: String?] = [
        HttpHeader.accept: "application/json"
    ]

    public static let operationName: String = "GetEnrolledLearningLibraryCollection"

    // MARK: - Init

    public init(id: String) {
        self.variables = Input(id: id)
    }

    // MARK: - Query

    public static var query: String {
        """
        query \(operationName)($id: String!) {
          enrolledLearningLibraryCollection(id: $id) {
            id
            name
            publicName
            description
            createdAt
            updatedAt
            \(itemsQuery)
          }
        }
        """
    }
}
