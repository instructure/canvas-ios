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

import Core
import Foundation

struct LearnItemModel: Identifiable, PaginatedDataSourceSearchable {
    let id: String
    let name: String
    let completionPercentage: Double
    let position: Int
    let startAt: String?
    let endAt: String?
    let imageUrl: URL?
    let estimatedDurationMinutes: String?
    let courseCount: Int?
    let itemType: ItemType

    var estimatedTime: String? {
        guard let estimatedDurationMinutes else {
            return nil
        }
        let formatter = ISO8601DurationFormatter()
        return formatter.duration(from: estimatedDurationMinutes)
    }
    init(item: GetLearnItemsResponse.Item) {
        self.id = item.id.defaultToEmpty
        self.name = item.name.defaultToEmpty
        self.completionPercentage = item.completionPercentage.defaultToZero
        self.position = item.position.defaultToZero
        self.startAt = item.startAt?.formatted(format: "MM/dd")
        self.endAt = item.endAt?.formatted(format: "MM/dd")
        self.imageUrl = item.imageURL
        self.estimatedDurationMinutes = item.estimatedDurationMinutes
        self.courseCount = item.courseCount
        self.itemType = ItemType(rawValue: item.itemType.defaultToEmpty) ?? .course
    }

    enum ItemType: String {
        case course = "COURSE"
        case program = "PROGRAM"
    }

    enum Status: String, CaseIterable {
        case notStarted = "NOT_STARTED"
        case inProgress = "IN_PROGRESS"
        case completed = "COMPLETED"
    }

    enum UIItemType: CaseIterable {
        case all
        case course
        case program

        var name: String {
            switch self {
            case .all: String(localized: "All")
            case .course: String(localized: "Courses")
            case .program: String(localized: "Programs")
            }
        }

        var key: String {
            switch self {
            case .course: ItemType.course.rawValue
            case .program: ItemType.program.rawValue
            case .all: ""
            }
        }

    }
}
