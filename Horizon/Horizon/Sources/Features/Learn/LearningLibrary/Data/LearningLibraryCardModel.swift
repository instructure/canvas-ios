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
    let courseID: String
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
    var isInProgress: Bool
    var courseEnrollmentId: String?
    let moduleItemID: String?
    let canvasUrl: URL?
    let completionPercentage: Double
    // Recommendation
    var primaryReason: RecommendationReason?
    var sourceCourseId: String?
    var sourceCourseName: String?
    var sourceSkillName: String?

    init(
        id: String,
        courseID: String = "",
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
        libraryId: String = "",
        moduleItemID: String? = nil,
        canvasUrl: URL? = nil,
        completionPercentage: Double = 0
    ) {
        self.id = id
        self.courseID = courseID
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
        self.moduleItemID = moduleItemID
        self.canvasUrl = canvasUrl
        self.completionPercentage = completionPercentage
    }

    init(for entity: CDHLearningLibraryCollectionItem) {
        self.id = entity.id
        self.courseID = entity.courseID
        self.name = entity.name
        self.imageURL = URL(string: entity.imageUrl.defaultToEmpty)
        self.itemType = LearningLibraryObjectType(rawValue: entity.itemType) ?? .course
        self.estimatedTime = entity.estimatedDurationMinutes.map { String(describing: $0) }
        self.isRecommended = false
        self.isCompleted = entity.completionPercentage == 100
        self.isBookmarked = entity.isBookmarked
        self.numberOfUnits = entity.moduleCount?.intValue
        self.isEnrolled = entity.isEnrolledInCanvas
        self.isInProgress = (entity.completionPercentage >= 0 && !isCompleted && isEnrolled)
        self.courseEnrollmentId = entity.canvasEnrollmentId
        self.libraryId = entity.libraryId
        self.moduleItemID = entity.canvasModuleItemId
        self.canvasUrl = entity.canvasUrl
        self.completionPercentage = entity.completionPercentage
        self.primaryReason = RecommendationReason(rawValue: entity.primaryReason.defaultToEmpty)
        self.sourceCourseId = entity.sourceCourseId
        self.sourceCourseName = entity.sourceCourseName
        self.sourceSkillName = entity.sourceSkillName
    }

    init(for response: LearningLibraryItemsResponse) {
        self.id = response.id
        self.courseID = response.canvasCourse?.courseId ?? ""
        self.name = response.canvasCourse?.courseName ?? ""
        self.imageURL = response.canvasCourse?.courseImageUrl.flatMap { URL(string: $0) }
        self.itemType = LearningLibraryObjectType(rawValue: response.itemType) ?? .course
        self.estimatedTime = response.canvasCourse?.estimatedDurationMinutes.map { String(describing: $0) }
        self.numberOfUnits = response.canvasCourse?.moduleCount
        self.isRecommended = false
        let completionPercentage = response.completionPercentage ?? 0
        self.isCompleted = completionPercentage == 100
        self.isBookmarked = response.isBookmarked ?? false
        let isEnrolled = response.isEnrolledInCanvas ?? false
        self.isEnrolled = isEnrolled
        self.isInProgress = (completionPercentage >= 0 && !self.isCompleted && isEnrolled)
        self.libraryId = response.libraryId ?? ""
        self.courseEnrollmentId = response.canvasEnrollmentId
        self.moduleItemID = response.canvasModuleItemId
        self.canvasUrl = response.canvasCourse?.canvasUrl
        self.completionPercentage = completionPercentage
    }

    mutating func update(with: LearningLibraryCardModel) {
        self.isBookmarked = with.isBookmarked
        self.isEnrolled = with.isEnrolled
        self.courseEnrollmentId = with.courseEnrollmentId
        /// When the user enrolls in the course, update the state to "in progress".
        self.isInProgress = (completionPercentage >= 0 && !self.isCompleted && isEnrolled)
    }

    var shouldShowEnrollButton: Bool {
        !isEnrolled && itemType == .course
    }

    var shouldShowProgressStatus: Bool {
        itemType == .course
    }

    var recommendationText: String? {
        guard let primaryReason else { return nil }
        switch primaryReason {
        case .pastLearnings:
            return String(format: String(localized: "A next step after %@"), arguments: [sourceCourseName.defaultToEmpty])
        case .bookmarkedItems:
            return String(localized: "Related to content you're interested in")
        case .existingSkills:
            return String(format: String(localized: "To deepen your skills in %@"), arguments: [sourceSkillName.defaultToEmpty])
        case .popularity:
            return String(localized: "Popular with learners at your organization")
        }
    }

    enum RecommendationReason: String {
        case pastLearnings = "PAST_LEARNINGS"      // Recommended based on previously completed courses
        case bookmarkedItems = "BOOKMARKED_ITEMS"  // Recommended based on bookmarked courses
        case existingSkills = "EXISTING_SKILLS"    // Recommended based on the user's skill profile
        case popularity = "POPULARITY"             // Recommended because it's popular among other learners
    }
}
