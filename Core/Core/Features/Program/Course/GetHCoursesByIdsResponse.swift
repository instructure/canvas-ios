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

public struct GetHCoursesByIdsResponse: Codable {
    let data: Response?

    public struct Response: Codable {
        var courses: [ProgramCourse]?
        let course: ProgramCourse?
    }

    public struct ProgramCourse: Codable {
        let id, name: String
        let modulesConnection: ModulesConnection?

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case name, modulesConnection
        }
    }

    public struct ModulesConnection: Codable {
        let edges: [Edge]?
    }

    public struct Edge: Codable {
        let node: Node?
    }

    public struct Node: Codable {
        let id, name: String?
        let moduleItems: [ModuleItem]?
    }

    public struct ModuleItem: Codable {
        let published: Bool?
        let id: String?
        let estimatedDuration: String?

        enum CodingKeys: String, CodingKey {
            case published
            case id = "_id"
            case estimatedDuration
        }
    }
}
