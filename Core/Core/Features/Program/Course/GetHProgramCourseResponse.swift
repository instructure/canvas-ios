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

public struct GetHProgramCourseResponse: Codable {
    let data: [String: ProgramCourse]?
    var enrollemtIDs: [String: String]?

    public struct ProgramCourse: Codable {
        public let id: String?
        public let name: String?
        public let modulesConnection: ModuleConnection?
        public let usersConnection: UsersConnection?
    }

    public struct ModuleConnection: Codable {
        public let pageInfo: PageInfo?
        public let edges: [Edge]?
    }

    public struct PageInfo: Codable {
        public let hasNextPage: Bool?
        public let startCursor: String?
    }

    public struct Edge: Codable {
        public let node: EdgeNode?
    }

    public struct EdgeNode: Codable {
        public let id, name: String
        public let moduleItems: [ModuleItem]
    }

    public struct ModuleItem: Codable {
        public let published: Bool?
        public let id: String?
        public let estimatedDuration: String?

        enum CodingKeys: String, CodingKey {
            case published
            case id = "_id"
            case estimatedDuration
        }
    }

    public struct Module: Codable {
        let id: String?
        let name: String?
    }

    public struct UsersConnection: Codable {
        public let nodes: [NodeElement]?
    }

    public struct NodeElement: Codable {
        public let courseProgression: CourseProgression?
    }

    public struct CourseProgression: Codable {
        public let requirements: Requirements?
    }

    public struct Requirements: Codable {
        public let completionPercentage: Double?
    }
}
