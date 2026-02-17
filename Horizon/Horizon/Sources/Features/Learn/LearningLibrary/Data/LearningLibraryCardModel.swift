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

struct LearningLibraryCardModel: Identifiable, Equatable {
    let id: String
    let itemId: String
    let name: String
    let imageURL: URL?
    let itemType: LearningLibraryObjectType
    let estimatedTime: String?
    let isRecommended: Bool
    let isCompleted: Bool
    var isBookmarked: Bool
    let libraryId: String
    let numberOfUnits: Int?
    var isEnrolled: Bool
    let isInProgress: Bool
    let courseEnrollmentId: String?

    init(
        id: String,
        itemId: String = "",
        name: String,
        imageURL: URL?,
        itemType: LearningLibraryObjectType,
        estimatedTime: String?,
        isRecommended: Bool,
        isCompleted: Bool,
        isBookmarked: Bool,
        numberOfUnits: Int?,
        isEnrolled: Bool = false,
        isInProgress: Bool = false,
        courseEnrollmentId: String? = nil,
        libraryId: String = ""
    ) {
        self.id = id
        self.itemId = itemId
        self.name = name
        self.imageURL = imageURL
        self.itemType = itemType
        self.estimatedTime = estimatedTime
        self.isRecommended = isRecommended
        self.isCompleted = isCompleted
        self.isBookmarked = isBookmarked
        self.numberOfUnits = numberOfUnits
        self.isEnrolled = isEnrolled
        self.isInProgress = isInProgress
        self.courseEnrollmentId = courseEnrollmentId
        self.libraryId = libraryId
    }

    init(for entity: CDHLearningLibraryCollectionItem) {
        self.id = entity.id
        self.itemId = entity.itemId
        self.name = entity.name
        self.imageURL = URL(string: entity.imageUrl.defaultToEmpty)
        self.itemType = LearningLibraryObjectType(rawValue: entity.itemType) ?? .course
        self.estimatedTime = entity.estimatedDurationMinutes.map { String(describing: $0) }
        self.isRecommended = false
        self.isCompleted = entity.completionPercentage == 100
        self.isBookmarked = entity.isBookmarked
        self.numberOfUnits = entity.moduleItemCount?.intValue
        self.isEnrolled = entity.isEnrolledInCanvas
        self.isInProgress = (entity.completionPercentage >= 0 && !isCompleted && isEnrolled)
        self.courseEnrollmentId = entity.canvasEnrollmentId
        self.libraryId = entity.libraryId
    }

    mutating func update(with: LearningLibraryCardModel) {
        self.isBookmarked = with.isBookmarked
        self.isEnrolled = with.isEnrolled
    }
}
