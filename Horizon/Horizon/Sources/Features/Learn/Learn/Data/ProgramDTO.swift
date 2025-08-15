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

/// `ProgramDTO` is a Data Transfer Object used to decouple Core Data entities (`CDHProgram`)
/// from the rest of the app.
/// Why needed here:
/// - Core Data relationships (e.g., `requirements`) often return `NSSet` or ordered collections that
///   are not directly sortable or assignable without mutating the managed object context.
/// - By converting to DTOs (plain Swift value types), we can freely sort and validate the data
///   without affecting Core Data state or triggering unwanted context saves.
///

import Foundation

struct ProgramDTO {
    let id: String
    let name: String
    let programDescription: String?
    let variant: String
    let courseCompletionCount: Int?
    let startDate: Date?
    let endDate: Date?
    let progresses: [ProgramProgressDTO]
    var requirements: [ProgramRequirementDTO]

    init(from entity: CDHProgram) {
        self.id = entity.id
        self.name = entity.name
        self.programDescription = entity.programDescription
        self.variant = entity.variant
        self.startDate = entity.startDate
        self.endDate = entity.endDate
        self.courseCompletionCount = if let count = entity.courseCompletionCount { Int(truncating: count) } else { nil }
        self.progresses = entity.porgresses.map { ProgramProgressDTO(from: $0) }
        self.requirements = entity.requirements.map { ProgramRequirementDTO(from: $0) }
    }
}

struct ProgramProgressDTO {
    let id: String
    let completionPercentage: Double
    let courseEnrollmentStatus: String
    let canvasCourseId: String

    init(from entity: CDHProgramProgress) {
        self.id = entity.id
        self.completionPercentage = entity.completionPercentage
        self.courseEnrollmentStatus = entity.courseEnrollmentStatus
        self.canvasCourseId = entity.canvasCourseId
    }
}

struct ProgramRequirementDTO {
    let id: String
    let isCompletionRequired: Bool
    let courseEnrollment: String
    let dependency: ProgramDependencyDTO?
    let dependent: ProgramDependentDTO?

    init(from entity: CDHProgramRequirement) {
        self.id = entity.id
        self.isCompletionRequired = entity.isCompletionRequired
        self.courseEnrollment = entity.courseEnrollment
        self.dependency = ProgramDependencyDTO(from: entity.dependency)
        self.dependent = ProgramDependentDTO(from: entity.dependent)
    }
}

struct ProgramDependencyDTO {
    let id: String?
    let canvasCourseId: String?

    init?(from entity: CDHProgramDependency?) {
        guard let entity else {
            return nil
        }
        self.id = entity.id
        self.canvasCourseId = entity.canvasCourseId
    }
}

struct ProgramDependentDTO {
    let id: String
    let canvasCourseId: String

    init?(from entity: CDHProgramDependent?) {
        guard let entity else {
            return nil
        }
        self.id = entity.id
        self.canvasCourseId = entity.canvasCourseId
    }
}
