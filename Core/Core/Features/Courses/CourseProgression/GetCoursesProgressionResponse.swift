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
        let user: LegacyNodeModel?

        enum CodingKeys: String, CodingKey {
            case user = "legacyNode"
        }
    }

    struct LegacyNodeModel: Codable {
        let enrollments: [EnrollmentModel]?
    }

    public struct EnrollmentModel: Codable {
        let state: String
        let id: String
        let course: CourseModel
    }

    struct CourseModel: Codable {
        let id, name: String
        let account: AccountModel?
        let imageUrl, syllabusBody: String?
        let usersConnection: UsersConnection?
        let modulesConnection: ModulesConnection?
    }

    struct AccountModel: Codable {
        let name: String
    }

    struct UsersConnection: Codable {
        public let nodes: [NodeModel]?
    }

    struct NodeModel: Codable {
        public let courseProgression: CourseProgression?
    }

    struct CourseProgression: Codable {
        public let requirements: Requirements?
        public let incompleteModulesConnection: IncompleteModulesConnection?
    }

    struct Requirements: Codable {
        public let completionPercentage: Double?
    }

    struct IncompleteModulesConnection: Codable {
        public let nodes: [IncompleteNode]
    }

    struct IncompleteNode: Codable {
        public let module: Module?
        public let incompleteItemsConnection: IncompleteItemsConnection?
    }

    struct ModulesConnection: Codable {
        public let edges: [Edge]?

        struct Edge: Codable {
            public let node: Node?
        }

        struct Node: Codable {
            let id: String?
            let name: String?
            let moduleItems: [ModuleItem]?
        }

        struct ModuleItem: Codable {
            let id: String?
            let estimatedDuration: String?
            let url: String?
            let content: Content?
        }

        struct Content: Codable {
            let id: String?
            let title: String?
            let __typename: String?
            let dueAt: Date?
        }
    }

    struct Module: Codable {
        public let id: String
        public let name: String
        public let position: Int?
    }

    struct IncompleteItemsConnection: Codable {
        public let nodes: [ModuleContent]
    }

    struct ModuleContent: Codable {
        public let url: String?
        public let id: String
        public let estimatedDuration: String?
        public let content: ContentNode?
    }

    struct ContentNode: Codable {
        public let id: String
        public let title: String?
        public let dueAt: Date?
        public let position: Double?
        public let __typename: String?
    }
}
