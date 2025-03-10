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

struct HCourse: Identifiable {
    let id: String
    let institutionName: String
    let name: String
    let overviewDescription: String
    let progress: Double
    let enrollments: [HEnrollment]
    let modules: [HModule]
    let incompleteModules: [HModule]

    init(
        id: String = "",
        institutionName: String = "",
        name: String = " ",
        overviewDescription: String? = nil,
        progress: Double = 0,
        enrollments: [HEnrollment] = [],
        modules: [HModule] = [],
        incompleteModules: [HModule] = []
    ) {
        self.id = id
        self.institutionName = institutionName
        self.name = name
        self.overviewDescription = overviewDescription ?? ""
        self.progress = progress
        self.enrollments = enrollments
        self.modules = modules
        self.incompleteModules = incompleteModules
    }

    init(from entity: Course, modulesEntity: [Module]) {
        self.id = entity.id
        self.institutionName = ""
        self.name = entity.name ?? ""
        self.overviewDescription = entity.syllabusBody ?? ""
        self.progress = 0
        if let enrollments = entity.enrollments {
            self.enrollments = Array(enrollments).map { HEnrollment(from: $0) }
        } else {
            self.enrollments = []
        }
       self.modules = modulesEntity
            .map { HModule(from: $0) }
        self.incompleteModules = []
    }
}
