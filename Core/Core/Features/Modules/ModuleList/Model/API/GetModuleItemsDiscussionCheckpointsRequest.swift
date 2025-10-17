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
struct GetModuleItemsDiscussionCheckpointsRequest: APIGraphQLRequestable {
    typealias Response = APIModuleItemsDiscussionCheckpoints

    let variables: Variables

    init(courseId: String) {
        variables = Variables(courseId: courseId)
    }

    static var query: String {
        """
        query GetModuleItemsDiscussionCheckpoints($courseId: ID!) {
          course(id: $courseId) {
            modulesConnection {
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

    struct Variables: Codable, Equatable {
        let courseId: String
    }
}
