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

/// Requests DiscussionCheckpoint data for all ModuleItems in a given course.
struct GetModuleItemsDiscussionCheckpointsRequest: APIGraphQLPagedRequestable {
    typealias Response = APIModuleItemsDiscussionCheckpoints

    struct Variables: Codable, Equatable {
        let courseId: String
        let pageSize: Int
        let cursor: String?
    }

    let variables: Variables

    init(courseId: String, pageSize: Int = 20, cursor: String? = nil) {
        variables = Variables(
            courseId: courseId,
            pageSize: pageSize,
            cursor: cursor
        )
    }

    static var query: String {
        """
        query GetModuleItemsDiscussionCheckpoints($courseId: ID!, $pageSize: Int!, $cursor: String) {
          course(id: $courseId) {
            modulesConnection(first: $pageSize, after: $cursor) {
              pageInfo {
                endCursor
                hasNextPage
              }
              edges {
                node {
                  moduleItems {
                    _id
                    content {
                      ... on Discussion {
                        checkpoints {
                          dueAt
                          tag
                          pointsPossible
                        }
                        replyToEntryRequiredCount
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

    public func nextPageRequest(from response: APIModuleItemsDiscussionCheckpoints) -> Self? {
        guard let pageInfo = response.pageInfo, pageInfo.hasNextPage else { return nil }

        return .init(
            courseId: variables.courseId,
            pageSize: variables.pageSize,
            cursor: pageInfo.endCursor
        )
    }
}
