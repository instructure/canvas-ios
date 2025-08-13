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

struct Program {
    var id: String
    var name: String
    var programDescription: String?
    var variant: String
    var progresses: [ProgramProgress]
    var requirements: [ProgramRequirement]

    init(
        id: String,
        name: String,
        programDescription: String? = nil,
        variant: String,
        progresses: [ProgramProgress],
        requirements: [ProgramRequirement]
    ) {
        self.id = id
        self.name = name
        self.programDescription = programDescription
        self.variant = variant
        self.progresses = progresses
        self.requirements = requirements
    }

    init(from entity: CDHProgram) {
        self.id = entity.id
        self.name = entity.name
        self.programDescription = entity.programDescription
        self.variant = entity.variant
        self.progresses = entity.porgresses.map { ProgramProgress(from: $0) }
        self.requirements = entity.requirements.map { ProgramRequirement(from: $0) }
    }
}

struct ProgramProgress {
    var id: String
    var completionPercentage: Double
    var courseEnrollmentStatus: String

    init(
        id: String,
        completionPercentage: Double,
        courseEnrollmentStatus: String
    ) {
        self.id = id
        self.completionPercentage = completionPercentage
        self.courseEnrollmentStatus = courseEnrollmentStatus
    }

    init(from entity: CDHProgramProgress) {
        self.id = entity.id
        self.completionPercentage = entity.completionPercentage
        self.courseEnrollmentStatus = entity.courseEnrollmentStatus
    }
}

struct ProgramRequirement {
    var id: String
    var isCompletionRequired: Bool
    var dependency: ProgramDependency?
    var dependent: ProgramDependent?
    init(
        id: String,
        isCompletionRequired: Bool,
        dependency: ProgramDependency? = nil,
        dependent: ProgramDependent? = nil
    ) {
        self.id = id
        self.isCompletionRequired = isCompletionRequired
        self.dependency = dependency
        self.dependent = dependent
    }

    init(from entity: CDHProgramRequirement) {
        self.id = entity.id
        self.isCompletionRequired = entity.isCompletionRequired
        self.dependency = ProgramDependency(from: entity.dependency)
        self.dependent = ProgramDependent(from: entity.dependent)
    }
}

struct ProgramDependency {
    public var id: String?
    public var canvasCourseId: String?

    init(id: String, canvasCourseId: String) {
        self.id = id
        self.canvasCourseId = canvasCourseId
    }

    init?(from entity: CDHProgramDependency?) {
        guard let entity else {
            return nil
        }
        self.id = entity.id
        self.canvasCourseId = entity.canvasCourseId
    }
}

struct ProgramDependent {
    public var id: String
    public var canvasCourseId: String

    init(id: String, canvasCourseId: String) {
        self.id = id
        self.canvasCourseId = canvasCourseId
    }

    init?(from entity: CDHProgramDependent?) {
        guard let entity else {
            return nil
        }
        self.id = entity.id
        self.canvasCourseId = entity.canvasCourseId
    }
}
