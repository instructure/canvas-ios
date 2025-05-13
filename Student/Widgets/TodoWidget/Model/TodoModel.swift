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
            TodoItem(id: "1", name: "Todo Item 1", dueDate: .now, color: .red)
        ])
    }

    let todoItems: [TodoItem]

    init(isLoggedIn: Bool = true, todoItems: [TodoItem] = []) {
        self.todoItems = todoItems
        super.init(isLoggedIn: isLoggedIn)
    }
}

#if DEBUG
extension TodoModel {
    public static func make() -> TodoModel {
        TodoModel(todoItems: [
            TodoItem(id: "1", name: "Explosion 101 Assignment", dueDate: .now, color: .systemRed),
            TodoItem(id: "2", name: "Explosion 101 Quiz", dueDate: .now.addDays(1), color: .systemYellow),
            TodoItem(id: "3", name: "Explosion 101 New Quiz", dueDate: .now.addDays(1), color: .systemBlue),
            TodoItem(id: "4", name: "Explosion 101 New Quiz 2", dueDate: .now.addDays(1), color: .systemGreen),
            TodoItem(id: "5", name: "Explosion 101 Discussion", dueDate: .now.addDays(2), color: .systemPink),
            TodoItem(id: "6", name: "Explosion 101 Discussion", dueDate: .now.addDays(2), color: .systemCyan),
            TodoItem(id: "7", name: "Explosion 101 Discussion", dueDate: .now.addDays(2), color: .systemBrown),
            TodoItem(id: "8", name: "Explosion 101 Discussion", dueDate: .now.addDays(2), color: .systemBlue)
        ])
    }
}
#endif
