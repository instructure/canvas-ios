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

    static let operationName = "AssignmentPickerList"
    /**`gradingPeriodId: null` is to return all assignments irrespective of their grading period in the course. */
    static let query = """
        query \(operationName)($courseID: ID!, $pageSize: Int!, $cursor: String) {
          course(id: $courseID) {
            assignmentsConnection(filter: { gradingPeriodId: null }, first: $pageSize, after: $cursor) {
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
              pageInfo {
                endCursor
                hasNextPage
              }
            }
          }
        }
        """

    public struct Variables: Codable, Equatable {
        public let courseID: String
        public let cursor: String?
        public let pageSize: Int
    }

    public let variables: Variables

    public init(courseID: String, pageSize: Int = 10, cursor: String? = nil) {
        variables = Variables(courseID: courseID, cursor: cursor, pageSize: pageSize)
    }

    public func getNext(from response: AssignmentPickerListResponse) -> AssignmentPickerListRequest? {
        guard let pageInfo = response.data.course.assignmentsConnection.pageInfo,
              pageInfo.hasNextPage
        else { return nil }

        return AssignmentPickerListRequest(
            courseID: variables.courseID,
            pageSize: variables.pageSize,
            cursor: variables.courseID
        )
    }
}
