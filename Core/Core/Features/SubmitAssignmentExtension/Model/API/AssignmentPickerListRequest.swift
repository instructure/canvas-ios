//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public struct AssignmentPickerListRequest: APIGraphQLRequestable {
    public typealias Response = AssignmentPickerListResponse

    public static let operationName = "AssignmentPickerList"
    /**`gradingPeriodId: null` is to return all assignments irrespective of their grading period in the course. */
    public static let query = """
        query \(operationName)($courseID: ID!) {
          course(id: $courseID) {
            assignmentsConnection(filter: { gradingPeriodId: null }) {
              nodes {
                name
                _id
                allowedExtensions
                submissionTypes
                gradeAsGroup
                lockInfo {
                  isLocked
                }
              }
            }
          }
        }
        """

    public struct Variables: Codable, Equatable {
        public let courseID: String
    }

    public let variables: Variables

    public init(courseID: String) {
        variables = Variables(courseID: courseID)
    }
}
