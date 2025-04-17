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

import WidgetKit

class TodoModel: WidgetModel {
    override class var publicPreview: TodoModel {
        TodoModel(todoItems: [
            TodoItem(name: String(localized: "Lab 1.2: The Solar System", comment: "Example to-do item name"), dueAt: Date().addDays(1), color: .textInfo),
            TodoItem(name: String(localized: "Mitosis Essay", comment: "Example to-do item name"), dueAt: Date().addDays(3), color: .course3),
            TodoItem(name: String(localized: "Moby Dick Quiz", comment: "Example to-do item name"), dueAt: Date().addDays(5), color: .textSuccess)
        ])
    }

    let todoItems: [TodoItem]

    init(isLoggedIn: Bool = true, todoItems: [TodoItem] = []) {
        self.todoItems = todoItems
        super.init(isLoggedIn: isLoggedIn)
    }

    func trimmed(to count: Int) -> TodoModel {
        let trimmedTodoItems = Array(todoItems.prefix(count))
        return TodoModel(todoItems: trimmedTodoItems)
    }
}

#if DEBUG
extension TodoModel {
    public static func makeWithOneToDoItem() -> TodoModel {
        TodoModel(todoItems: [
            TodoItem(name: String(localized: "Lab 1.2: The Solar System", comment: "Example to-do item name"), dueAt: Date().addDays(1), color: .textInfo)
        ]
        )
    }

    public static func make() -> TodoModel {
        TodoModel(todoItems: [
            TodoItem(name: String(localized: "Lab 1.2: The Solar System", comment: "Example to-do item name"), dueAt: Date().addDays(1), color: .textInfo),
            TodoItem(name: String(localized: "Mitosis Essay", comment: "Example to-do item name"), dueAt: Date().addDays(3), color: .course3),
            TodoItem(name: String(localized: "Moby Dick Quiz", comment: "Example to-do item name"), dueAt: Date().addDays(5), color: .textSuccess)
        ])
    }
}
#endif
