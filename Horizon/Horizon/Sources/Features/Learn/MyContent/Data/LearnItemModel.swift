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
    let estimatedDurationMinutes: Int?
    let courseCount: Int?
    let itemType: ItemType
    let enrollmentId: String
    let nextModuleItemID: String?

    var estimatedTime: String? {
        guard let estimatedDurationMinutes else {
            return nil
        }

        let hours = estimatedDurationMinutes / 60
        let minutes = estimatedDurationMinutes % 60

        if hours > 0, minutes > 0 {
            return String(format: String(localized: "%d hrs %d mins"), hours, minutes)
        } else if hours > 0 {
            return String(format: String(localized: "%d hrs"), hours)
        } else {
            return String(format: String(localized: "%d mins"), minutes)
        }
    }

    var buttonCourseTitle: String {
        switch completionPercentage {
        case 100.0:
            String(localized: "View course")
        case 0.0:
            String(localized: "Start learning")
        default:
            String(localized: "Resume learning")
        }
    }

    var isCourseCompleted: Bool {
        completionPercentage.rounded() == 100
    }

    init(
        id: String,
        name: String,
        completionPercentage: Double,
        position: Int,
        startAt: String?,
        endAt: String?,
        imageUrl: URL?,
        estimatedDurationMinutes: Int?,
        courseCount: Int?,
        itemType: ItemType,
        enrollmentId: String = "",
        nextModuleItemID: String? = nil
    ) {
        self.id = id
        self.name = name
        self.completionPercentage = completionPercentage
        self.position = position
        self.startAt = startAt
        self.endAt = endAt
        self.imageUrl = imageUrl
        self.estimatedDurationMinutes = estimatedDurationMinutes
        self.courseCount = courseCount
        self.itemType = itemType
        self.enrollmentId = enrollmentId
        self.nextModuleItemID = nextModuleItemID
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
        self.enrollmentId = item.enrollmentId.defaultToEmpty
        let incompleteModule = item.incompleteModules?.first(where: { ($0.incompleteItems ?? []).isNotEmpty })
        self.nextModuleItemID = incompleteModule?.incompleteItems?.first?.id
    }

    var accessibilityLearnDescription: String {
        var description = ""

        if itemType == .course {
            description = String.localizedStringWithFormat(
                String(localized: "Course: %@. ", bundle: .horizon),
                name
            )
        } else {
            description = String.localizedStringWithFormat(
                String(localized: "Program: %@. ", bundle: .horizon),
                name
            )
        }

        description += String.localizedStringWithFormat(
            String(localized: "Progress: %d percent complete. ", bundle: .horizon),
            Int(completionPercentage.rounded())
        )

        if let courseCount {
            description += String.localizedStringWithFormat(
                String(localized: "Number of courses: %d . ", bundle: .horizon),
                Int(courseCount)
            )
        }
        if let estimatedTime {
            description += String.localizedStringWithFormat(
                String(localized: "Estimated duration: %@. ", bundle: .horizon),
                estimatedTime
            )
        }
        if let startAt, let endAt {
            description += String.localizedStringWithFormat(
                String(localized: "Date from: %@, to: %@. ", bundle: .horizon),
                startAt, endAt
            )
        }
        return description
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
