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
import HorizonUI
import Foundation

struct HModuleItem: Equatable {
    let id: String
    let title: String
    let htmlURL: URL?
    let isCompleted: Bool
    let dueAt: Date?
    let type: ModuleItemType?
    let isLocked: Bool
    let moduleState: ModuleState?
    let points: Double?
    let isOptional: Bool
    var lockedMessage: String?
    let moduleID: String
    let url: URL?
    let visibleWhenLocked: Bool
    let lockedForUser: Bool
    let lockExplanation: String?
    let courseID: String
    let isQuizLTI: Bool
    let completionRequirementType: CompletionRequirementType?
    let moduleName: String?
    let estimatedDuration: String?

    init(
        id: String,
        title: String,
        htmlURL: URL?,
        isCompleted: Bool = false,
        dueAt: Date? = Date(),
        type: ModuleItemType? = nil,
        isLocked: Bool = false,
        moduleState: ModuleState? = nil,
        points: Double? = nil,
        lockedDate: String? = nil,
        url: URL? = nil,
        visibleWhenLocked: Bool = false,
        lockedForUser: Bool = false,
        lockExplanation: String? = nil,
        courseID: String = "courseID",
        moduleID: String = "moduleID",
        isQuizLTI: Bool = false,
        completionRequirementType: CompletionRequirementType? = nil,
        moduleName: String? = nil,
        estimatedDuration: String? = nil

    ) {
        self.id = id
        self.title = title
        self.htmlURL = htmlURL
        self.isCompleted = isCompleted
        self.dueAt = dueAt
        self.type = type
        self.isLocked = isLocked
        self.moduleState = moduleState
        self.points = points
        self.isOptional = false
        self.lockedMessage = lockedDate
        self.url = url
        self.moduleID = moduleID
        self.visibleWhenLocked = visibleWhenLocked
        self.lockedForUser = lockedForUser
        self.lockExplanation = lockExplanation
        self.courseID = courseID
        self.isQuizLTI = isQuizLTI
        self.completionRequirementType = completionRequirementType
        self.moduleName = moduleName
        self.estimatedDuration = estimatedDuration
    }

    init(from entity: ModuleItem) {
        self.id = entity.id
        self.title = entity.title
        self.htmlURL = entity.htmlURL
        self.isCompleted = entity.completed ?? false
        self.dueAt = entity.dueAt
        self.type = entity.type
        self.isLocked = entity.lockExplanation?.isEmpty == false
        self.moduleState = entity.module?.state
        self.points = entity.pointsPossible
        self.isOptional = entity.completionRequirement == nil
        self.lockedMessage = HModuleItemLockMessage(html: entity.lockExplanation ?? "").generate()
        self.moduleID = entity.moduleID
        self.url = entity.url
        self.visibleWhenLocked = entity.visibleWhenLocked
        self.lockedForUser = entity.lockedForUser
        self.lockExplanation = entity.lockExplanation
        self.courseID = entity.courseID
        self.isQuizLTI = entity.isQuizLTI
        self.completionRequirementType = entity.completionRequirementType
        self.moduleName = entity.module?.name
        self.estimatedDuration = entity.estimatedDuration
    }

    var isOverDue: Bool {
        guard !isCompleted else {
            return false
        }
        let rightNow = Clock.now
        return (dueAt ?? Date.distantFuture) < rightNow
    }

    var status: HorizonUI.LearningObjectItem.Status? {
        isLocked ? .locked : (isCompleted ? .completed : nil)
    }

    var estimatedDurationFormatted: String? {
        let formatter = ISO8601DurationFormatter()
        return formatter.duration(from: estimatedDuration ?? "")
    }
}

extension HModuleItem: Identifiable {}
