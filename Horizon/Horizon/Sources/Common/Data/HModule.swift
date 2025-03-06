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

struct HModule: Identifiable {
    let id: String
    let name: String
    let courseID: String
    let items: [HModuleItem]
    let moduleStatus: HModuleStatus
    var contentItems: [HModuleItem]
    let estimatedDuration: String?
    let position: Int
    init(
        id: String,
        name: String,
        courseID: String,
        items: [HModuleItem],
        state: ModuleState? = .completed,
        lockMessage: String? = nil,
        countOfPrerequisite: Int = 0,
        estimatedDuration: String? = nil,
        position: Int = 1
    ) {
        self.id = id
        self.name = name
        self.courseID = courseID
        self.items = items
        self.contentItems = []
        self.estimatedDuration = estimatedDuration
        self.moduleStatus = .init(
            items: items,
            state: state,
            lockMessage: lockMessage,
            countOfPrerequisite: countOfPrerequisite
        )
        self.position = position
    }

    init(from entity: Module) {
        self.id = entity.id
        self.name = entity.name
        self.courseID = entity.courseID
        self.items = entity.items
            .map(HModuleItem.init)
            .sorted { $0.position < $1.position }
        contentItems = items.filter { $0.type?.isContentItem == true  }
        self.estimatedDuration = entity.estimatedDuration
        moduleStatus = .init(
            items: contentItems,
            state: entity.state,
            lockMessage: entity.lockedMessage,
            countOfPrerequisite: entity.prerequisiteModuleIDs.count
        )
        self.position = entity.position
    }

    var dueItemsCount: Int {
        items.filter { $0.isOverDue }.count
    }

    var estimatedDurationFormatted: String? {
        let formatter = ISO8601DurationFormatter()
        return formatter.duration(from: estimatedDuration ?? "")
    }
}
