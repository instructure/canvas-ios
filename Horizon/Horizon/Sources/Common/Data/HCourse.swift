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

import Core
import Foundation

struct HCourse: Identifiable {
    enum EnrollmentState: String {
        case active
        case invited
    }

    struct LearningObjectCard {
        let moduleTitle: String
        let learningObjectName: String
        let learningObjectID: String
        let type: LearningObjectType?
        let dueDate: String?
        let url: URL?
        let estimatedTime: String?
        let isNewQuiz: Bool
    }

    let id: String
    let name: String
    let institutionName: String
    let state: String // active or inactive
    let enrollmentID: String
    let enrollments: [HEnrollment]
    let modules: [HModule]
    let progress: Double
    let overviewDescription: String
    let imageUrl: String?
    let currentLearningObject: LearningObjectCard? // upcoming module item details
    var programs: [Program] = []

    init(
        id: String = "",
        name: String = " ",
        institutionName: String = "",
        state: String = "",
        enrollmentID: String = "",
        enrollments: [HEnrollment] = [],
        modules: [HModule] = [],
        progress: Double = 0,
        overviewDescription: String? = nil,
        imageUrl: String? = nil,
        currentLearningObject: LearningObjectCard? = nil,
        programs: [Program] = []
    ) {
        self.id = id
        self.name = name
        self.institutionName = institutionName
        self.state = state
        self.enrollmentID = enrollmentID
        self.enrollments = enrollments
        self.modules = modules
        self.progress = progress
        self.overviewDescription = overviewDescription ?? ""
        self.imageUrl = imageUrl
        self.currentLearningObject = currentLearningObject
        self.programs = programs
    }

    init(from entity: CDHCourse, modules: [HModule]?) {
        self.id = entity.courseID
        self.name = entity.name ?? ""
        self.institutionName = entity.institutionName ?? ""
        self.state = entity.state
        self.enrollmentID = entity.enrollmentID
        self.enrollments = [] // TODO: Find where to set
        self.modules = modules ?? []
        self.progress = entity.completionPercentage
        self.overviewDescription = entity.overviewDescription ?? ""
        self.imageUrl = entity.imageUrl

        if entity.nextModuleID != nil, entity.nextModuleItemID != name {
            self.currentLearningObject = LearningObjectCard(
                moduleTitle: entity.nextModuleName ?? "",
                learningObjectName: entity.nextModuleItemName ?? "",
                learningObjectID: entity.nextModuleItemID ?? "",
                type: LearningObjectType(rawValue: entity.nextModuleItemType ?? ""),
                dueDate: entity.nextModuleItemDueDate?.relativeShortDateOnlyString,
                url: URL(string: entity.nextModuleItemURL ?? ""),
                estimatedTime: entity.nextModuleItemEstimatedTime?.toISO8601Duration,
                isNewQuiz: entity.nextModuleItemIsNewQuiz
            )
        } else {
            self.currentLearningObject = nil
        }
    }
}
