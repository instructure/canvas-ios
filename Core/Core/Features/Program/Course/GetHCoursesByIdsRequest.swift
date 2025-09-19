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

import Foundation

public struct GetHCoursesByIdsRequest: APIGraphQLRequestable {
    public typealias Response = GetHCoursesByIdsResponse
    public typealias Variables = Input

    public struct Input: Codable, Equatable {
        let userId: String
        let ids: [String]
    }

    public static let operationName = "GetCoursesByIds"
    public let variables: Input

    // MARK: - Init

    public init(courseIDs: [String], userId: String) {
        self.variables = Input(userId: userId, ids: courseIDs)
    }

    public static let query: String = """
            query \(operationName)($ids: [ID!], $userId: ID!) {
              courses(ids: $ids) {
                _id
                name
                usersConnection(filter: { userIds: [$userId] }) {
                  nodes {
                    courseProgression {
                      requirements {
                        completed
                        completionPercentage
                      }
                    }
                  }
                }
                modulesConnection {
                  edges {
                    node {
                      id
                      name
                      moduleItems {
                        published
                        _id
                        estimatedDuration
                      }
                    }
                  }
                }
              }
            }
    """
}
