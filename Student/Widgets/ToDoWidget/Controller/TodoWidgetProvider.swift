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
import WidgetKit

class TodoWidgetProvider: CommonWidgetProvider<TodoModel> {
    private var colors: Store<GetCustomColors>?
    private var todos: Store<GetTodos>?
    init() {
        super.init(loggedOutModel: TodoModel(isLoggedIn: false), timeout: 60 * 60) // 1 hour
    }

    override func fetchData() {
        colors = env.subscribe(GetCustomColors())
        colors?.refresh { [weak self] _ in
            guard let self = self, let colors = self.colors, !colors.pending else { return }
            self.todos = self.env.subscribe(GetTodos()) { [weak self] in self?.handleFetchFinished() }
            self.todos?.refresh()
        }
    }

    private func handleFetchFinished() {
        guard
            let todos = todos, !todos.pending
        else {
            return
        }

        let todoItems = todos.all.map { TodoItem(todo: $0)}
        updateWidget(model: TodoModel(todoItems: todoItems))
    }
}
