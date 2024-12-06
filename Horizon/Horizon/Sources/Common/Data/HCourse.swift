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
    let name: String
    let imageURL: URL?
    let overviewDescription: String?
    let modules: [HModule]

    var percentage: Double = 0.0
    var progressState: ProgressState = .notStarted

    var progress: Double {
        percentage / 100
    }

    var progressString: String {
        let percentageRound = round(percentage * 100) / 100.0
        return "\(percentageRound)%"
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

    init(
        id: String,
        name: String,
        imageURL: URL?,
        overviewDescription: String?,
        modules: [HModule]
    ) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.overviewDescription = overviewDescription
        self.modules = modules
    }

    init(from entity: Course, modulesEntity: [Module]) {
        self.id = entity.id
        self.name = entity.name ?? ""
        self.imageURL = entity.imageDownloadURL
        self.overviewDescription = entity.syllabusBody
        self.modules = modulesEntity.map { HModule(from: $0) }
    }
}

extension HCourse {
    enum ProgressState: String, CaseIterable {
        case onTrack = "On Track"
        case notStarted = "Not Started"
        case completed = "Completed"

        init(from value: Double) {
            switch value {
            case 0:
                self = .notStarted
            case 100:
                self = .completed
            default:
                self = .onTrack
            }
        }
    }
}
