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

public struct GetHSubmissionCommentsRequest: APIGraphQLPagedRequestable {
    public typealias Response = GetHSubmissionCommentsResponse
    public let variables: Input

    public struct Input: Codable, Equatable {
        let userId: String
        let assignmentId: String
        let forAttempt: Int
        let beforeCursor: String?
        let last: Int?
    }

    public init(
        assignmentId: String,
        userId: String,
        forAttempt: Int,
        beforeCursor: String? = nil,
        last: Int? = 100
    ) {
        variables = Input(
            userId: userId,
            assignmentId: assignmentId,
            forAttempt: forAttempt,
            beforeCursor: beforeCursor,
            last: last
        )
    }

    public func nextPageRequest(from response: GetHSubmissionCommentsResponse) -> GetHSubmissionCommentsRequest? {
        guard response.data?.submission?.commentsConnection?.pageInfo?.hasPreviousPage == true else {
            return nil
        }
        return GetHSubmissionCommentsRequest(
            assignmentId: variables.assignmentId,
            userId: variables.userId,
            forAttempt: variables.forAttempt,
            beforeCursor: response.data?.submission?.commentsConnection?.pageInfo?.startCursor,
            last: variables.last
        )
    }

    public static let query = """
        query GetSubmissionComments($assignmentId: ID!, $userId: ID!, $forAttempt: Int, $beforeCursor: String, $last: Int) {
            submission(assignmentId: $assignmentId, userId: $userId) {
               ...on Submission {
                 id: _id
                 unreadCommentCount
                 commentsConnection(last: $last, sortOrder: asc, before: $beforeCursor, filter: { forAttempt: $forAttempt }) {
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
                    attachments {
                      _id
                      url
                      displayName
                    }
                   }
                 }
               }
             }
          }
        }
        """
}
