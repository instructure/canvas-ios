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

import Foundation
import Combine

public protocol TodoInteractor {
    var todoGroups: AnyPublisher<[TodoGroupViewModel], Never> { get }
    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Error>
}

public final class TodoInteractorLive: TodoInteractor {
    public var todoGroups: AnyPublisher<[TodoGroupViewModel], Never> {
        todoGroupsSubject.eraseToAnyPublisher()
    }

    private let todoGroupsSubject = CurrentValueSubject<[TodoGroupViewModel], Never>([])
    private let env: AppEnvironment

    private var subscriptions = Set<AnyCancellable>()

    init(env: AppEnvironment) {
        self.env = env
    }

    public func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Error> {
        let startDate = Clock.now.addDays(-28)
        let endDate = Clock.now.addDays(28)
        let currentUserID = env.currentSession?.userID

        return ReactiveStore(useCase: GetCourses(), environment: env)
            .getEntities(ignoreCache: ignoreCache)
            .map {
                var contextCodes: [String] = $0.filter(\.isPublished).map(\.canvasContextID)
                if let userContextCode = Context(.user, id: currentUserID)?.canvasContextID {
                    contextCodes.append(userContextCode)
                }
                return contextCodes
            }
            .flatMap { [env] codes in
                ReactiveStore(
                    useCase: GetPlannables(startDate: startDate, endDate: endDate, contextCodes: codes),
                    environment: env
                )
                .getEntities(ignoreCache: ignoreCache, loadAllPages: true)
                .map { $0.compactMap(TodoItemViewModel.init) }
            }
            .map { [weak todoGroupsSubject] (todos: [TodoItemViewModel]) in
                TabBarBadgeCounts.todoListCount = UInt(todos.count)

                // Group todos by day
                let groupedTodos = Self.groupTodosByDay(todos)
                todoGroupsSubject?.value = groupedTodos
                return ()
            }
            .eraseToAnyPublisher()
    }

    private static func groupTodosByDay(_ todos: [TodoItemViewModel]) -> [TodoGroupViewModel] {
        // Group todos by day using existing Canvas extension
        let groupedDict = Dictionary(grouping: todos) { todo in
            todo.date.startOfDay()
        }

        // Convert to TodoGroup array and sort by date
        return groupedDict.map { (date, items) in
            TodoGroupViewModel(date: date, items: items.sorted { $0.date < $1.date })
        }
        .sorted { $0.date < $1.date }
    }
}

#if DEBUG

public final class TodoInteractorPreview: TodoInteractor {
    public let todoGroups: AnyPublisher<[TodoGroupViewModel], Never>

    public init(todoGroups: [TodoGroupViewModel] = []) {
        if todoGroups.isNotEmpty {
            self.todoGroups = Publishers.typedJust(todoGroups)
            return
        }

        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today

        let todayGroup = TodoGroupViewModel(
            date: today,
            items: [
                .makeShortText(id: "3")
            ]
        )
        let tomorrowGroup = TodoGroupViewModel(
            date: tomorrow,
            items: [
                .makeShortText(id: "1"),
                .makeLongText(id: "2")
            ]
        )
        self.todoGroups = Publishers.typedJust([todayGroup, tomorrowGroup])
    }

    public func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Error> {
        Publishers.typedJust(())
    }
}

#endif
