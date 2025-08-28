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

/// The main idea of using `GetHProgramCourseRequest` is to collect up to 5 courses
/// and fetch their data in a single request, instead of calling the API separately
/// for each course.
///
/// Program IDs are UUIDs, which may contain dashes (-) and may also start with a number.
/// To make them valid GraphQL aliases, we prefix them with an underscore (_) and replace
/// dashes with underscores, then append the course ID.
///
/// Example:
///   Program ID: 25f21c34-34e8-4498-9f30-02b53d7032ef
///   Course ID: 489
///   Alias: _25f21c34_34e8_4498_9f30_02b53d7032efID489
///
/// We use **two aliases per course**:
/// 1. An `ID` alias → fetches enrollments, estimated duration, completion percentage, etc.
/// 2. A `Course` alias → fetches the course name only.
///
/// The reason for the extra `Course` alias is that in some cases the learner is not
/// enrolled in the course, or the course is blocked. In those cases the enrollment-based
/// alias would return nothing, so we still need a way to retrieve and display the course
/// name.
///
/// Example query:
///
/// _25f21c34_34e8_4498_9f30_02b53d7032efID489: legacyNode(_id: 1308, type: User) {
///   ... on User {
///     enrollments(courseId: 489) {
///       course {
///         id: _id
///         name
///         usersConnection(filter: { userIds: [1308] }) {
///           nodes {
///             courseProgression {
///               requirements {
///                 completed
///                 completionPercentage
///                 total
///               }
///               incompleteModulesConnection {
///                 nodes {
///                   incompleteItemsConnection {
///                     nodes {
///                       id: _id
///                       title
///                       estimatedDuration
///                     }
///                   }
///                 }
///               }
///             }
///           }
///         }
///       }
///     }
///   }
/// }
///
/// _25f21c34_34e8_4498_9f30_02b53d7032efCourse489: {
///   name
///   id
/// }

public struct GetHProgramCourseRequest: APIGraphQLRequestable {
    public struct Parameters {
        let programID: String
        let courseID: String
        public init(
            programID: String,
            courseID: String
        ) {
            self.programID = programID
            self.courseID = courseID
        }

        var cacheKey: String {
            "\(programID)-\(courseID)"
        }
        var enrollmentKey: String {
            "_\(programID.replacingOccurrences(of: "-", with: "_"))ID\(courseID)"
        }
        var courseKey: String {
            "_\(programID.replacingOccurrences(of: "-", with: "_"))Course\(courseID)"
        }
    }

    public typealias Response = GetHProgramCourseResponse
    public typealias Variables = Input
    public let variables: Input = .init()
    public struct Input: Codable, Equatable { }
    private static var userId: String = ""
    private static var programs: [Parameters] = []
    public static let operationName = "GetProgramCourse"

    // MARK: - Init

    public init(userId: String, programs: [Parameters]) {
        Self.userId = userId
        Self.programs = programs
    }

    public static var query: String {
        var queryParts: [String] = []

        for program in programs {
            let key = program.enrollmentKey
            let part = """
                \(key): legacyNode(_id: \(program.courseID), type: Course) {
                  ... on Course {
                    id
                    name
                    modulesConnection(first: 20) {
                      pageInfo {
                        hasNextPage
                        startCursor
                      }
                      edges {
                        node {
                          id
                          name
                          moduleItems {
                            published
                            _id
                            estimatedDuration
                          }
                        }
                      }
                    }
                    usersConnection(userIds: \(userId)) {
                      nodes {
                        courseProgression {
                          requirements {
                            completionPercentage
                          }
                        }
                      }
                    }
                  }
                }
                """
            queryParts.append(part)
        }

        let fullQuery = """
        query \(operationName) {
        \(queryParts.joined(separator: "\n\n"))
        }
        """
        return fullQuery
    }
}
