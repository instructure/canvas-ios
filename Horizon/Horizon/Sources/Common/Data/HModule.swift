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

struct HModule {
    let id: String
    let name: String
    let courseID: String
    let items: [HModuleItem]
    let state: ModuleState?
    let isSequentialProgressRequired: Bool

    init(
        id: String,
        name: String,
        courseID: String,
        items: [HModuleItem],
        state: ModuleState? = .completed,
        isSequentialProgressRequired: Bool = false
    ) {
        self.id = id
        self.name = name
        self.courseID = courseID
        self.items = items
        self.state = state
        self.isSequentialProgressRequired = isSequentialProgressRequired
    }

    init(from entity: Module) {
        self.id = entity.id
        self.name = entity.name
        self.courseID = entity.courseID
        self.items = entity.items.map { HModuleItem(from: $0) }
        self.state = entity.state
        self.isSequentialProgressRequired = entity.requireSequentialProgress ?? false
    }

    var isCompleted: Bool {
        state == .completed
    }

    var isInProgress: Bool {
        state == .started
    }
}

extension HModule: Identifiable {}