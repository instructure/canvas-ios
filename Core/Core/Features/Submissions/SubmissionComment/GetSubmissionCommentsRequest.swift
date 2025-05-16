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

public struct GetSubmissionCommentsRequest: APIGraphQLRequestable {
    public typealias Response = GetSubmissionCommentsResponse
    public let variables: Input

    public struct Input: Codable, Equatable {
        var userId: String
        var assignmentId: String
    }

    public init(
        assignmentId: String,
        userId: String
    ) {
        variables = Input(
            userId: userId,
            assignmentId: assignmentId
        )
    }

    public static let query = """
        query GetSubmissionComments($assignmentId: ID!, $userId: ID!) {
            submission(assignmentId: $assignmentId, userId: $userId) {
               ...on Submission {
                 id: _id
                 unreadCommentCount
                 commentsConnection(sortOrder: asc, filter:{allComments: true}) {
                   pageInfo {
                     endCursor
                     startCursor
                     hasPreviousPage
                     hasNextPage
                   }
                   edges {
                     node {
                       id: _id
                       attempt
                       author {
                         _id
                         avatarUrl
                         shortName
                       }
                       comment
                       read
                       updatedAt
                       createdAt
                     }
                   }
                 }
               }
             }
          }
        """
}
