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
import Core

public struct GetLearnItemsResponse: Codable, PagedResponse {
    public var page: [Item] { data?.learnItems?.items ?? [] }
    let data: DataClass?

    struct DataClass: Codable {
        let learnItems: LearnItems?
    }

    struct LearnItems: Codable {
        let items: [Item]?
        let pageInfo: PageInfo?
    }

    public struct Item: Codable {
        let typename, id, name, itemType: String?
        let position: Int?
        let enrollmentId: String?
        let startAt, endAt: Date?
        let enrolledAt: String?
        let completionPercentage: Double?
        let requirementCount, requirementCompletedCount: Int?
        let completedAt, grade: String?
        let imageURL: URL?
        let workflowState: String?
        let lastActivityAt: String?
        let estimatedDurationMinutes: Int?
        let courseCount: Int?
        let incompleteModules: [IncompleteModule]?
        enum CodingKeys: String, CodingKey {
            case typename = "__typename"
            case id, name, itemType, position, startAt, endAt, enrolledAt, completionPercentage, requirementCount, requirementCompletedCount, completedAt, grade
            case imageURL = "imageUrl"
            case workflowState, lastActivityAt, estimatedDurationMinutes, courseCount, enrollmentId
            case incompleteModules
        }
    }

    struct IncompleteModule: Codable {
        let id, name: String?
        let incompleteItems: [IncompleteItem]?
    }

    struct IncompleteItem: Codable {
        let id: String?
    }

    struct PageInfo: Codable {
        let nextCursor, previousCursor: String?
        let hasNextPage, hasPreviousPage: Bool?
        let totalCount: Int?
        let pageCursors: [PageCursor]?
    }

    struct PageCursor: Codable {
        let page: Int?
        let cursor: String?
    }
}
