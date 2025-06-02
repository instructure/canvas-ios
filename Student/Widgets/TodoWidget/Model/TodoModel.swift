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
import SwiftUI
import Core

class TodoModel: WidgetModel {
    override class var publicPreview: TodoModel {
        Self.make()
    }

    let items: [TodoItem]
    let error: TodoError?

    init(
        isLoggedIn: Bool = true,
        items: [TodoItem] = [],
        error: TodoError? = nil
    ) {
        self.items = items
        self.error = error

        super.init(isLoggedIn: isLoggedIn)
    }

    func todoDays(for family: WidgetFamily) -> TodoList {
        let todoItems = Array(
            items
                .sorted { $0.date < $1.date }
                .prefix(family.shownTodoItemsMaximumCount)
        )

        let days = Dictionary(grouping: todoItems, by: { $0.date.startOfDay() })
            .sorted(by: { $0.key < $1.key })
            .map { (date, dayItems) in
                return TodoDay(date: date, items: dayItems)
            }

        return TodoList(days: days, isFullList: todoItems.count == items.count)
    }
}

enum TodoError: Error {
    case fetchingDataFailure
}

extension TodoModel {

    static func make(count: Int = 5) -> TodoModel {
        let items = [
            TodoItem(plannableID: "1", type: .assignment, date: Date.now, title: "Important Assignment"),
            TodoItem(plannableID: "2", type: .discussion_topic, date: Date.now, title: "Discussion About Everything"),
            TodoItem(plannableID: "3", type: .calendar_event, date: Date.now, title: "Huge Event"),
            TodoItem(plannableID: "4", type: .planner_note, date: Date.now.addDays(3), title: "Don't forget"),
            TodoItem(plannableID: "5", type: .quiz, date: Date.now.addDays(3), title: "Quiz About Life"),
            TodoItem(plannableID: "6", type: .assignment, date: Date.now.addDays(3), title: "Another Assignment"),
            TodoItem(plannableID: "7", type: .wiki_page, date: Date.now.addDays(3), title: "Some Page")
        ]
        return TodoModel(items: Array(items.prefix(count)))
    }
}
