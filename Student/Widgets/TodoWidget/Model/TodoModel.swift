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

    let items: [TodoItemViewModel]
    let error: TodoError?

    init(
        isLoggedIn: Bool = true,
        items: [TodoItemViewModel] = [],
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

// MARK: - Previews

extension TodoModel {

    static func make(count: Int = 5) -> TodoModel {
        let items = [
            TodoItemViewModel(
                plannableId: "1",
                type: .assignment,
                date: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date.now)!,
                title: String(localized: "Research Paper Draft"),
                subtitle: nil,
                contextName: String(localized: "Introduction to Psychology"),
                htmlURL: nil,
                color: .course3,
                icon: .assignmentLine
            ),
            TodoItemViewModel(
                plannableId: "2",
                type: .discussion_topic,
                date: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date.now)!,
                title: String(localized: "Chapter 5 Discussion"),
                subtitle: nil,
                contextName: String(localized: "Modern Literature"),
                htmlURL: nil,
                color: .course8,
                icon: .discussionLine
            ),
            TodoItemViewModel(
                plannableId: "3",
                type: .calendar_event,
                date: Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: Date.now)!,
                title: String(localized: "Guest Lecture Series"),
                subtitle: nil,
                contextName: String(localized: "Biology 101"),
                htmlURL: nil,
                color: .course5,
                icon: .calendarMonthLine
            ),
            TodoItemViewModel(
                plannableId: "4",
                type: .planner_note,
                date: Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date.now.addDays(3))!,
                title: String(localized: "Review study materials"),
                subtitle: nil,
                contextName: String(localized: "To Do"),
                htmlURL: nil,
                color: .course11,
                icon: .noteLine
            ),
            TodoItemViewModel(
                plannableId: "5",
                type: .quiz,
                date: Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: Date.now.addDays(3))!,
                title: String(localized: "Unit 3 Quiz"),
                subtitle: nil,
                contextName: String(localized: "Introduction to Psychology"),
                htmlURL: nil,
                color: .course3,
                icon: .quizLine
            ),
            TodoItemViewModel(
                plannableId: "6",
                type: .assignment,
                date: Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: Date.now.addDays(3))!,
                title: String(localized: "Lab Report Submission"),
                subtitle: nil,
                contextName: String(localized: "Chemistry Lab"),
                htmlURL: nil,
                color: .course12,
                icon: .assignmentLine
            ),
            TodoItemViewModel(
                plannableId: "7",
                type: .wiki_page,
                date: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date.now.addDays(3))!,
                title: String(localized: "Course Syllabus"),
                subtitle: nil,
                contextName: String(localized: "History 202"),
                htmlURL: nil,
                color: .course6,
                icon: .documentLine
            )
        ]
        return TodoModel(items: Array(items.prefix(count)))
    }
}
