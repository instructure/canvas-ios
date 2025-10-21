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
    var todoGroups: CurrentValueSubject<[TodoGroupViewModel], Never> { get }
    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Error>
    func markItemAsDone(_ item: TodoItemViewModel, done: Bool) -> AnyPublisher<Void, Error>
}

public final class TodoInteractorLive: TodoInteractor {
    public var todoGroups = CurrentValueSubject<[TodoGroupViewModel], Never>([])

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
            .map { courses in
                var contextCodes: [String] = courses.filter(\.isPublished).map(\.canvasContextID)
                if let userContextCode = Context(.user, id: currentUserID)?.canvasContextID {
                    contextCodes.append(userContextCode)
                }
                return (contextCodes, courses)
            }
            .flatMap { [env] (courseContextCodes, courses: [Course]) in
                ReactiveStore(
                    useCase: GetPlannables(startDate: startDate, endDate: endDate, contextCodes: courseContextCodes),
                    environment: env
                )
                .getEntities(ignoreCache: ignoreCache, loadAllPages: true)
                .map { plannables in
                    let coursesByCanvasContextIds = Dictionary(uniqueKeysWithValues: courses.map { ($0.canvasContextID, $0) })
                    return plannables
                        .filter { !$0.isMarkedComplete && !$0.isSubmitted }
                        .compactMap { plannable in
                            let course = coursesByCanvasContextIds[plannable.canvasContextIDRaw ?? ""]
                            return TodoItemViewModel(plannable, course: course)
                        }
                }
            }
            .map { [weak todoGroups] (todos: [TodoItemViewModel]) in
                TabBarBadgeCounts.todoListCount = UInt(todos.count)

                // Group todos by day
                let groupedTodos = Self.groupTodosByDay(todos)
                todoGroups?.value = groupedTodos
                return ()
            }
            .eraseToAnyPublisher()
    }

    public func markItemAsDone(_ item: TodoItemViewModel, done: Bool) -> AnyPublisher<Void, Error> {
        let useCase = MarkPlannableItemDone(
            plannableId: item.plannableId,
            plannableType: item.plannableType,
            overrideId: item.overrideId,
            done: done
        )

        return useCase.fetchWithFuture(environment: env)
            .map { [weak self] _ in
                self?.updateOverrideId(for: item)
                return ()
            }
            .eraseToAnyPublisher()
    }

    private func updateOverrideId(for item: TodoItemViewModel) {
        let scope = Scope.plannable(id: item.plannableId)
        if let plannable: Plannable = env.database.viewContext.fetch(scope: scope).first,
           let overrideId = plannable.plannerOverrideId {
            item.overrideId = overrideId
        }
    }

    private static func groupTodosByDay(_ todos: [TodoItemViewModel]) -> [TodoGroupViewModel] {
        // Group todos by day using existing Canvas extension
        let groupedDict = Dictionary(grouping: todos) { todo in
            todo.date.startOfDay()
        }

        // Convert to TodoGroup array and sort by date
        return groupedDict.map { (date, items) in
            TodoGroupViewModel(date: date, items: items.sorted())
        }
        .sorted()
    }
}

#if DEBUG

public final class TodoInteractorPreview: TodoInteractor {
    public let todoGroups: CurrentValueSubject<[TodoGroupViewModel], Never>

    public init(todoGroups: [TodoGroupViewModel]? = nil) {
        if let todoGroups {
            self.todoGroups = CurrentValueSubject<[TodoGroupViewModel], Never>(todoGroups)
            return
        }

        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today

        let todayGroup = TodoGroupViewModel(
            date: today,
            items: [
                .makeShortText(plannableId: "3")
            ]
        )
        let tomorrowGroup = TodoGroupViewModel(
            date: tomorrow,
            items: [
                .makeShortText(plannableId: "1"),
                .makeLongText(plannableId: "2")
            ]
        )
        self.todoGroups = CurrentValueSubject<[TodoGroupViewModel], Never>([todayGroup, tomorrowGroup])
    }

    public func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Error> {
        Publishers.typedJust(())
    }

    public func markItemAsDone(_ item: TodoItemViewModel, done: Bool) -> AnyPublisher<Void, Error> {
        Publishers.typedJust(())
    }
}

#endif
