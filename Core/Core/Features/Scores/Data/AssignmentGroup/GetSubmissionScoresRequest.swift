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

public struct GetSubmissionScoresRequest: APIGraphQLRequestable {
    public typealias Response = GetSubmissionScoresResponse
    public let variables: Input

    public struct Input: Codable, Equatable {
        var userId: String
        var enrollmentId: String
    }

    public init(userId: String, enrollmentId: String) {
        variables = Input(userId: userId, enrollmentId: enrollmentId)
    }

    public static let query = """
        query GetSubmissionScoresForCourse($enrollmentId: ID!, $userId: ID!) {
                legacyNode(_id: $enrollmentId, type: Enrollment) {
                    ... on Enrollment {
                        id: _id
                        grades {
                          finalScore
                          finalGrade
                        }
                        course {
                          applyGroupWeights
                          assignmentGroups {
                              _id
                              name
                              groupWeight
                              gradesConnection(filter: { enrollmentIds: [$enrollmentId] }) {
                                  nodes {
                                      currentScore
                                      finalScore
                                      state
                                  }
                              }
                              assignmentsConnection {
                                  nodes {
                                      _id
                                      name
                                      pointsPossible
                                      dueAt
                                      htmlUrl
                                      submissionsConnection(filter: { includeUnsubmitted: true, userId: $userId }) {
                                          nodes {
                                              state
                                              late
                                              excused
                                              missing
                                              score
                                              grade
                                              submissionStatus
                                              commentsConnection {
                                                  nodes {
                                                      _id
                                                      read
                                                  }
                                              }
                                          }
                                      }
                                      submissionTypes
                                  }
                              }
                          }
                        }
                    }
                }
        }
        """
}
