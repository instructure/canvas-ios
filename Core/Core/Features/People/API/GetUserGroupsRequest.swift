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

public struct GetUserGroupsRequest: APIGraphQLRequestable {
    public typealias Response = GetUserGroupsResponse
    public struct Variables: Codable, Equatable {
        let courseId: String
    }
    public static let query = """
        query GetUserGroupsRequest($courseId: ID!) {
          course(id: $courseId) {
            groupSets(includeNonCollaborative: true) {
              _id
              name
              groups {
                _id
                name
                nonCollaborative
                membersConnection {
                  nodes {
                    user {
                      _id
                    }
                  }
                }
              }
            }
          }
        }
        """
    public let variables: Variables

    public init(courseId: String) {
        variables = Variables(courseId: courseId)
    }
}

public struct GetUserGroupsResponse: Codable, Equatable {
    public let data: ResponseData
    public var groupSets: [GroupSet] {
        data.course.groupSets
    }

    public struct ResponseData: Codable, Equatable {
        public let course: Course
    }

    public struct Course: Codable, Equatable {
        public let groupSets: [GroupSet]
    }

    public struct GroupSet: Codable, Equatable {
        public let _id: String
        public let name: String
        public let groups: [Group]
    }

    public struct Group: Codable, Equatable {
        public let _id: String
        public let name: String
        public let nonCollaborative: Bool
        public let membersConnection: MembersConnection

        public var userIds: [String] {
            membersConnection.nodes.map { $0.user._id }
        }
    }

    public struct MembersConnection: Codable, Equatable {
        public let nodes: [Member]

        public struct Member: Codable, Equatable {
            public let user: User

            public struct User: Codable, Equatable {
                public let _id: String
            }
        }
    }
}
