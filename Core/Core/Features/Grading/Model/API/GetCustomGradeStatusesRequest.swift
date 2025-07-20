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

public struct GetCustomGradeStatusesRequest: APIGraphQLRequestable {

    public let variables: Variables

    public init(courseID: String) {
        variables = Variables(courseID: courseID)
    }

    public static let operationName = "GetCustomGradeStatuses"
    public static let query = """
        query \(operationName)($courseID: ID!) {
          course(id: $courseID) {
            customGradeStatusesConnection {
              nodes {
                name
                _id
              }
            }
          }
        }
        """
}

// MARK: - Sub-types

public extension GetCustomGradeStatusesRequest {

    struct Variables: Codable, Equatable {
        let courseID: String
    }

    struct Response: Codable, Equatable {
        public let data: Data

        public struct Data: Codable, Equatable {
            public let course: Course

            public struct Course: Codable, Equatable {
                public let customGradeStatusesConnection: CustomGradeStatusesConnection

                public struct CustomGradeStatusesConnection: Codable, Equatable {
                    public let nodes: [CustomGradeStatus]

                    public struct CustomGradeStatus: Codable, Equatable {
                        public let name: String
                        public let id: String

                        private enum CodingKeys: String, CodingKey {
                            case name, id = "_id"
                        }
                    }
                }
            }
        }
    }
}

public typealias APICustomGradeStatus = GetCustomGradeStatusesRequest
    .Response
    .Data
    .Course
    .CustomGradeStatusesConnection
    .CustomGradeStatus
