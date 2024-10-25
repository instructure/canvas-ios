//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

struct GetCoursesProgressionResponse: Codable {
    let data: DataModel?

    struct DataModel: Codable {
        let user: UserModel?
    }

    struct UserModel: Codable {
        let enrollments: [EnrollmentModel]?
    }

    struct EnrollmentModel: Codable {
        let course: CourseModel?
    }

    struct CourseModel: Codable {
        let id, name: String?
        let usersConnection: UsersConnection?

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case name
            case usersConnection
        }
    }

    struct UsersConnection: Codable {
        let nodes: [NodeModel]?
    }

    struct NodeModel: Codable {
        let courseProgression: CourseProgression?
    }

    struct CourseProgression: Codable {
        let requirements: Requirements?
    }

    struct Requirements: Codable {
        let completed: Int?
        let completionPercentage: Double?
        let total: Int?
    }
}
