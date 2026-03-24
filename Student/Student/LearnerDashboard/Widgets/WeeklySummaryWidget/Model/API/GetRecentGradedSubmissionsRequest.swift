//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Core
import Foundation

struct GetRecentGradedSubmissionsRequest: APIGraphQLRequestable {
    struct Variables: Codable, Equatable {
        let studentId: String
        let gradedSince: String
    }

    struct Response: Codable {
        let data: ResponseData

        struct ResponseData: Codable {
            let allCourses: [CourseNode]
        }

        struct CourseNode: Codable {
            let _id: String
            let name: String
            let submissions: SubmissionsConnection
        }

        struct SubmissionsConnection: Codable {
            let edges: [Edge]
        }

        struct Edge: Codable {
            let node: SubmissionNode
        }

        struct SubmissionNode: Codable {
            let _id: String
            let score: Double?
            let grade: String?
            let excused: Bool?
            let gradeHidden: Bool?
            let gradedAt: Date?
            let assignment: AssignmentNode

            func isValidNewGrade(weekStart: Date, weekEnd: Date) -> Bool {
                gradeHidden != true
                    && (grade != nil || score != nil)
                    && gradedAt.map { $0 >= weekStart && $0 < weekEnd } == true
            }
        }

        struct AssignmentNode: Codable {
            let _id: String
            let name: String
            let htmlUrl: String?
            let pointsPossible: Double?
            let gradingType: String?
        }
    }

    static let operationName = "RecentGradedSubmissionsQuery"
    static let query = """
        query RecentGradedSubmissionsQuery($studentId: ID!, $gradedSince: DateTime!) {
            allCourses {
                _id
                name
                submissions: submissionsConnection(
                    first: 100
                    orderBy: [{field: gradedAt, direction: descending}]
                    studentIds: [$studentId]
                    filter: {states: graded, gradedSince: $gradedSince}
                ) {
                    edges {
                        node {
                            _id
                            score
                            grade
                            excused
                            gradeHidden
                            gradedAt
                            assignment {
                                _id
                                name
                                htmlUrl
                                pointsPossible
                                gradingType
                            }
                        }
                    }
                }
            }
        }
        """

    let variables: Variables
}
