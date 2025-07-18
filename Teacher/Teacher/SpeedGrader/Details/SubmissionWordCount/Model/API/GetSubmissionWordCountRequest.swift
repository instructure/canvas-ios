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
import Core

struct GetSubmissionWordCountRequest: APIGraphQLRequestable {
    typealias Response = GetSubmissionWordCountResponse

    let variables: Variables

    init(assignmentId: String, userId: String) {
        variables = Variables(assignmentId: assignmentId, userId: userId)
    }

    static let query = """
        query \(operationName)($userId: ID!, $assignmentId: ID!) {
          submission(userId: $userId, assignmentId: $assignmentId) {
            submissionHistoriesConnection(filter: {}) {
              edges {
                node {
                  attempt
                  wordCount
                  submissionType
                }
              }
            }
          }
        }
        """

    struct Variables: Codable, Equatable {
        let assignmentId: String
        let userId: String
    }
}

struct GetSubmissionWordCountResponse: Codable, Equatable {
    var submissionAttempts: [Data.Submission.SubmissionHistoriesConnection.SubmissionHistoryEdge] {
        data.submission.submissionHistoriesConnection.edges
    }

    let data: Data

    struct Data: Codable, Equatable {
        let submission: Submission

        struct Submission: Codable, Equatable {
            let submissionHistoriesConnection: SubmissionHistoriesConnection

            struct SubmissionHistoriesConnection: Codable, Equatable {
                let edges: [SubmissionHistoryEdge]

                struct SubmissionHistoryEdge: Codable, Equatable {
                    let node: SubmissionHistory

                    struct SubmissionHistory: Codable, Equatable {
                        let attempt: Int
                        /// This may be null for some not word-countable types. It may be zero for others.
                        let wordCount: Double?
                        /// This is null when there are no submissions yet
                        let submissionType: String?
                    }
                }
            }
        }
    }
}
