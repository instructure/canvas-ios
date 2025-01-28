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

public struct GetCoursesProgressionResponse: Codable {
    let data: DataModel?

    struct DataModel: Codable {
        let legacyNode: LegacyNodeModel?
    }

    struct LegacyNodeModel: Codable {
        let enrollments: [EnrollmentModel]?
    }

    public struct EnrollmentModel: Codable {
        let course: CourseModel
    }

    struct CourseModel: Codable {
        let id, name: String
        let imageUrl, syllabusBody: String?
        let modulesConnection: ModulesConnection?
        let usersConnection: UsersConnection?

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case imageUrl
            case modulesConnection
            case name
            case syllabusBody
            case usersConnection
        }
    }

    struct UsersConnection: Codable {
        public  let nodes: [NodeModel]?
    }

    struct ModulesConnection: Codable {
        public let nodes: [Module]?
    }

    struct Module: Codable {
        public let id: String
        public let name: String
        public let position: Int?
        public let moduleItems: [ModuleItem]?

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case name
            case position
            case moduleItems
        }
    }

    struct ModuleItem: Codable {
        public let content: ModuleContent
    }

    struct ModuleContent: Codable {
        public let id: String
        public let name: String?

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case name
        }
    }

    struct NodeModel: Codable {
        public let courseProgression: CourseProgression?
        public let incompleteModulesConnection: IncompleteModulesConnection?
    }

    struct CourseProgression: Codable {
        public let requirements: Requirements?
    }

    struct Requirements: Codable {
        let completed: Int?
        public   let completionPercentage: Double?
        let total: Int?
    }

    struct IncompleteModulesConnection: Codable {
        public let nodes: [ModulesConnection]?
    }
}
