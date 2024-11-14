//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public struct GetCoursesProgressionRequest: APIGraphQLRequestable {

    public typealias Response = GetCoursesProgressionResponse
    public let variables: Input

    public struct Input: Codable, Equatable {
        var userId: String
    }

    public init(userId: String) {
        variables = Input(userId: userId)
    }
    public static let operationName = "courseProgressionQuery"

    public static var query: String = """
            query \(operationName)($userId: ID!) {
              user: legacyNode(_id: $userId, type: User) {
                ... on User {
                  enrollments(currentOnly: true) {
                    course {
                      _id
                      name
                      usersConnection(filter: { userIds: [$userId] }) {
                        nodes {
                          courseProgression {
                            requirements {
                              completed
                              completionPercentage
                              total
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
"""
}
