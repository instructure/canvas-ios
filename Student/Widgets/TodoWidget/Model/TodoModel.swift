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

    let groups: [TodoGroupViewModel]
    let error: TodoError?

    init(
        isLoggedIn: Bool = true,
        groups: [TodoGroupViewModel] = [],
        error: TodoError? = nil
    ) {
        self.groups = groups
        self.error = error

        super.init(isLoggedIn: isLoggedIn)
    }

    func todoDays(for family: WidgetFamily) -> TodoList {
        let allItems = groups.flatMap { $0.items }
        let maxCount = family.shownTodoItemsMaximumCount

        var itemCount = 0
        var days: [TodoDay] = []

        for group in groups.sorted() {
            if itemCount >= maxCount {
                break
            }

            let remainingCount = maxCount - itemCount
            let itemsToTake = Array(group.items.prefix(remainingCount))

            if !itemsToTake.isEmpty {
                days.append(TodoDay(date: group.date, items: itemsToTake))
                itemCount += itemsToTake.count
            }
        }

        return TodoList(days: days, isFullList: itemCount == allItems.count)
    }
}

enum TodoError: Error {
    case fetchingDataFailure
}

// MARK: - Previews

extension TodoModel {

    static func make(count: Int = 5) -> TodoModel {
        let groups = makePreviewGroups()
        let limitedGroups = limitGroups(groups, maxItemCount: count)
        return TodoModel(groups: limitedGroups)
    }

    private static func makePreviewGroups() -> [TodoGroupViewModel] {
        let todayItems = makeTodayPreviewItems()
        let laterItems = makeLaterPreviewItems()

        return [
            TodoGroupViewModel(date: Date.now.startOfDay(), items: todayItems),
            TodoGroupViewModel(date: Date.now.addDays(3).startOfDay(), items: laterItems)
        ]
    }

    private static func makeTodayPreviewItems() -> [TodoItemViewModel] {
        [
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
            )
        ]
    }

    private static func makeLaterPreviewItems() -> [TodoItemViewModel] {
        [
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
    }

    private static func limitGroups(_ groups: [TodoGroupViewModel], maxItemCount: Int) -> [TodoGroupViewModel] {
        let allItems = groups.flatMap { $0.items }

        guard maxItemCount < allItems.count else {
            return groups
        }

        var itemCount = 0
        var resultGroups: [TodoGroupViewModel] = []

        for group in groups {
            if itemCount >= maxItemCount {
                break
            }
            let remainingCount = maxItemCount - itemCount
            let itemsToTake = Array(group.items.prefix(remainingCount))

            if !itemsToTake.isEmpty {
                resultGroups.append(TodoGroupViewModel(date: group.date, items: itemsToTake))
                itemCount += itemsToTake.count
            }
        }

        return resultGroups
    }
}
