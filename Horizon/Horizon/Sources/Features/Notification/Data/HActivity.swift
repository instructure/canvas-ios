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

struct HActivity: Identifiable, Equatable {
    let id: String
    let title: String
    let message: String?
    let date: Date?
    let grade: String?
    let score: String?
    let type: ActivityType?
    let contextType: String?
    let notificationCategory: String?
    let courseId: String?
    let isRead: Bool

    init(
        id: String,
        title: String,
        message: String?,
        date: Date? = nil,
        grade: String? = nil,
        score: String? = nil,
        type: ActivityType? = nil,
        contextType: String? = nil,
        notificationCategory: String? = nil,
        courseId: String? = nil,
        isRead: Bool = true
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.date = date
        self.grade = grade
        self.score = score
        self.type = type
        self.contextType = contextType
        self.notificationCategory = notificationCategory
        self.courseId = courseId
        self.isRead = isRead
    }

    init(from entity: Activity) {
        self.id = entity.id
        self.title = entity.title ?? ""
        self.message = entity.message
        self.date = entity.updatedAt
        self.grade = entity.grade
        self.score = entity.score
        self.type = entity.type
        self.contextType = entity.contextType
        self.notificationCategory = entity.notificationCategory
        self.courseId = entity.courseId
        self.isRead = entity.readState
    }

    var dateFormatted: String {
        date?.formatted(format: "MMM d") ?? ""
    }
}
