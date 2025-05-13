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
        var id: String
        var horizonCourses: Bool
    }

    public init(userId: String, horizonCourses: Bool = true) {
        variables = Input(id: userId, horizonCourses: horizonCourses)
    }

    public static let operationName = "GetUserCourses"

    public static let query = """
            query \(operationName)($id: ID!, $horizonCourses: Boolean!) {
                legacyNode(_id: $id, type: User) {
                    ... on User {
                        enrollments(currentOnly: false, horizonCourses: $horizonCourses) {
                            id: _id
                            state
                            course {
                                id: _id
                                name
                                imageUrl
                                syllabusBody
                                account {
                                  name
                                }
                                modulesConnection(first: 1) {
                                  edges {
                                    node {
                                      id
                                      name
                                      published
                                      moduleItems {
                                        id
                                        estimatedDuration
                                        url
                                       content {
                                         ... on Assignment {
                                           id
                                           title
                                           dueAt
                                           type: __typename
                                         }
                                         ... on Discussion {
                                           id
                                           title
                                           type: __typename
                                         }
                                         ... on ExternalTool {
                                           id: _id
                                           title: name
                                           type: __typename
                                         }
                                         ... on ExternalUrl {
                                           id: _id
                                           title
                                           type: __typename
                                         }
                                         ... on File {
                                           id
                                           title
                                           type: __typename
                                         }
                                         ... on ModuleExternalTool {
                                           id: _id
                                           title
                                           type: __typename
                                         }
                                         ... on Page {
                                           id
                                           title
                                           type: __typename
                                         }
                                         ... on Quiz {
                                           id
                                           title
                                           type: __typename
                                         }
                                         ... on SubHeader {
                                           id: title
                                           title
                                           type: __typename
                                         }
                                       }
                                      }
                                    }
                                  }
                                }
                                usersConnection(filter: {userIds: [$id]}) {
                                    nodes {
                                        courseProgression {
                                            requirements {
                                                completionPercentage
                                            }
                                            incompleteModulesConnection {
                                                nodes {
                                                    module {
                                                        id: _id
                                                        name
                                                        position
                                                        published
                                                    }
                                                    incompleteItemsConnection {
                                                        nodes {
                                                            id: _id
                                                            url
                                                            estimatedDuration
                                                            content {
                                                                ... on Assignment {
                                                                    id
                                                                    title
                                                                    dueAt
                                                                    position
                                                                    published
                                                                    type: __typename
                                                                }
                                                                ... on Discussion {
                                                                    id
                                                                    title
                                                                    position
                                                                    published
                                                                    type: __typename
                                                                }
                                                                ... on ExternalTool {
                                                                    id: _id
                                                                    title
                                                                    published
                                                                    type: __typename
                                                                }
                                                                ... on ExternalUrl {
                                                                    id: _id
                                                                    title
                                                                    published
                                                                    type: __typename
                                                                }
                                                                ... on File {
                                                                    id
                                                                    title
                                                                    published
                                                                    type: __typename
                                                                }
                                                                ... on ModuleExternalTool {
                                                                    id: _id
                                                                    title
                                                                    published
                                                                    type: __typename
                                                                }
                                                                ... on Page {
                                                                    id
                                                                    title
                                                                    published
                                                                    type: __typename
                                                                }
                                                                ... on Quiz {
                                                                    id
                                                                    title
                                                                    published
                                                                    type: __typename
                                                                }
                                                                ... on SubHeader {
                                                                    id: title
                                                                    title
                                                                    published
                                                                    type: __typename
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
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
