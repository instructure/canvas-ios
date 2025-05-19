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
            TodoItem(id: "1", name: "My Todo Item 1", date: .now, color: .red, contextName: "My Course")
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
            TodoItem(id: "1", name: "Explosion 101 Assignment", date: .now, color: .systemRed, contextName: "My First Course"),
            TodoItem(id: "8", name: "My Todo Item", date: .now.addDays(2), color: .systemBlue, contextName: "User Calendar"),
            TodoItem(id: "2", name: "Explosion 101 Quiz", date: .now.addDays(1), color: .systemYellow, contextName: "My Second Course"),
            TodoItem(id: "3", name: "Explosion 101 New Quiz", date: .now.addDays(1), color: .systemBlue, contextName: "My Second Course"),
            TodoItem(id: "4", name: "Explosion 101 New Quiz 2", date: .now.addDays(1), color: .systemGreen, contextName: "My First Course"),
            TodoItem(id: "5", name: "Explosion 101 Discussion", date: .now.addDays(2), color: .systemPink, contextName: "My First Course"),
            TodoItem(id: "6", name: "Explosion 101 Discussion", date: .now.addDays(2), color: .systemCyan, contextName: "My First Course"),
            TodoItem(id: "7", name: "Explosion 101 Discussion", date: .now.addDays(2), color: .systemBrown, contextName: "My First Course")
        ])
    }
}
#endif
