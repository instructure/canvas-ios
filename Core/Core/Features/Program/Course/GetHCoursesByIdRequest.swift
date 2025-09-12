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

struct GetHCoursesByIdRequest: APIGraphQLRequestable {
    public typealias Response = GetHCoursesByIdsResponse
    public typealias Variables = Input

    public struct Input: Codable, Equatable {
        let id: String
    }

    public static let operationName = "GetCoursesById"
    public let variables: Input

    // MARK: - Init

    public init(courseID: String) {
        self.variables = Input(id: courseID)
    }

    public static let query: String = """
            query \(operationName)($id: ID!) {
              course(id: $id) {
                _id
                name
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
