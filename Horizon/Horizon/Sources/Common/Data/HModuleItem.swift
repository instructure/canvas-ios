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

struct HModuleItem: Equatable {
    let id: String
    let title: String
    let htmlURL: URL?
    let isCompleted: Bool
    let dueAt: Date?
    let type: ModuleItemType?
    let isLocked: Bool
    let moduleState: ModuleState?

    init(
        id: String,
        title: String,
        htmlURL: URL?,
        isCompleted: Bool = false,
        dueAt: Date? = Date(),
        type: ModuleItemType? = .file(""),
        isLocked: Bool = false,
        moduleState: ModuleState? = .completed
    ) {
        self.id = id
        self.title = title
        self.htmlURL = htmlURL
        self.isCompleted = isCompleted
        self.dueAt = dueAt
        self.type = type
        self.isLocked = isLocked
        self.moduleState = moduleState
    }

    init(from entity: ModuleItem) {
        self.id = entity.id
        self.title = entity.title
        self.htmlURL = entity.htmlURL
        self.isCompleted = entity.completed ?? false
        self.dueAt = entity.dueAt
        self.type = entity.type
        self.isLocked = entity.isLocked
        self.moduleState = entity.module?.state
    }

    var isOverDue: Bool {
        guard !isCompleted else {
            return false
        }
        let rightNow = Clock.now
        return (dueAt ?? Date.distantFuture) < rightNow
    }
}

extension HModuleItem: Identifiable {}
