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

import Core
import Foundation

struct GetGradeStatusesRequest: APIGraphQLRequestable {
    typealias Response = GetGradeStatusesResponse

    let variables: Variables

    init(courseID: String) {
        variables = Variables(courseID: courseID)
    }

    static let operationName = "GetCustomGradeStatuses"
    static let query = """
        query \(operationName)($courseID: ID!) {
          course(id: $courseID) {
            customGradeStatusesConnection {
              nodes {
                name
                _id
              }
            }
            gradeStatuses
          }
        }
        """

    struct Variables: Codable, Equatable {
        let courseID: String
    }
}

struct GetGradeStatusesResponse: Codable, Equatable {
    var customGradeStatuses: [Data.Course.CustomGradeStatusesConnection.CustomGradeStatus] {
        data.course.customGradeStatusesConnection.nodes
    }
    var defaultGradeStatuses: [String] {
        data.course.gradeStatuses
    }
    let data: Data

    struct Data: Codable, Equatable {
        let course: Course

        struct Course: Codable, Equatable {
            let customGradeStatusesConnection: CustomGradeStatusesConnection
            let gradeStatuses: [String]

            struct CustomGradeStatusesConnection: Codable, Equatable {
                let nodes: [CustomGradeStatus]

                struct CustomGradeStatus: Codable, Equatable {
                    let name: String
                    let id: String
                    private enum CodingKeys: String, CodingKey {
                        case name, id = "_id"
                    }
                }
            }
        }
    }
}
