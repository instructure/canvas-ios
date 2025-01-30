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
    }

    public init(userId: String) {
        variables = Input(id: userId)
    }
    public static let operationName = "GetUserCourses"

    public static let content = """
        id: _id
        content {
            ... on SubHeader {
                __typename
                name: title
            }
            ... on Page {
                __typename
                id
                name: title
            }
            ... on ModuleExternalTool {
                __typename
                createdAt
                updatedAt
                name: url
            }
            ... on File {
                __typename
                id
                name: displayName
            }
            ... on ExternalUrl {
                __typename
                createdAt
                name: title
            }
            ... on ExternalTool {
                __typename
                createdAt
                name: description
            }
            ... on Assignment {
                __typename
                id
                name
                dueAt
            }
        }
    """
    public static let query = """
        query \(operationName)($id: ID!) {
            legacyNode(_id: $id, type: User) {
                ... on User {
                    enrollments(currentOnly: true) {
                        course {
                            id: _id
                            name
                            image_download_url: imageUrl 
                            syllabus_body: syllabusBody
                            account {
                              name
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
