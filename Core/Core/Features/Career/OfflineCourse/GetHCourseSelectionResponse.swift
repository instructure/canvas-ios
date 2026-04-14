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

import Foundation

public struct GetHCourseSelectionResponse: Codable {
    let data: DataClass

    struct DataClass: Codable {
        let legacyNode: LegacyNode
    }

    struct LegacyNode: Codable {
        let enrollments: [Enrollment]
    }

    struct Enrollment: Codable {
        let id: String
        let course: Course

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case course
        }
    }

    struct Course: Codable {
        let id, name: String
        let modulesConnection: ModulesConnection

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case name, modulesConnection
        }
    }

    struct ModulesConnection: Codable {
        let edges: [Edge]
    }

    struct Edge: Codable {
        let node: Node
    }

    struct Node: Codable {
        let moduleItems: [ModuleItem]
    }

    struct ModuleItem: Codable {
        let content: Content?
    }

    struct Content: Codable {
        let id, displayName, size: String?
        let url: URL?
        let mimeClass: String?
        let updatedAt: Date?
        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case displayName, size, url, mimeClass, updatedAt
        }
    }
}
