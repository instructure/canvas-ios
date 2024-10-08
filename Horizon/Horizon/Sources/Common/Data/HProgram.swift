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

struct HProgram {
    let course: HCourse
    let modules: [HModule]

    var name: String {
        course.name
    }

    var progress: Double {
        0.75
    }

    var progressString: String {
        "75%"
    }

    var institutionName: String {
        "Community College"
    }
    var targetCompletion: String {
        "Target Completion: 2024/11/27"
    }

    var currentModule: HModule? {
        modules.first
    }

    var currentModuleItem: HModuleItem? {
        if let firstModule = modules.first,
           let currentModuleItem = firstModule.items.first {
            return currentModuleItem
        } else {
            return nil
        }
    }

    var upcomingModuleItems: [HModuleItem] {
        if let firstModule = modules.first {
            var cpy = firstModule.items
            _ = cpy.removeFirst()
            return cpy
        } else {
            return []
        }
    }

    init(course: HCourse, modules: [HModule]) {
        self.course = course
        self.modules = modules
    }

    init(courseEntity: Course, modulesEntity: [Module]) {
        self.course = HCourse(from: courseEntity)
        self.modules = modulesEntity.map { HModule(from: $0) }
    }
}

extension HProgram: Identifiable {
    var id: String {
        course.id
    }
}
