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

protocol TodoInteractor {
    /// The current list of todo groups, grouped by day and filtered according to user preferences.
    /// Updated when `refresh()` is called.
    var todoGroups: CurrentValueSubject<[TodoGroupViewModel], Never> { get }

    /// Fetches todos from the API or cache and applies current filter settings.
    ///
    /// This method fetches plannables and courses, applies user's filter preferences,
    /// groups the results by day, and updates the badge count.
    ///
    /// - Parameter ignoreCache: If `true`, forces a fetch from the API.
    ///   If `false`, checks cache expiration: returns cached data if valid, fetches from API if expired.
    /// - Returns: A publisher that completes when the refresh operation finishes.
    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Error>

    /// Checks if the cache has expired for todo data.
    ///
    /// Returns `true` if the cache has expired and the next `refresh(ignoreCache: false)` will fetch from the API.
    /// Returns `false` if cached data is still valid.
    ///
    /// - Returns: A publisher that emits whether the cache has expired.
    func isCacheExpired() -> AnyPublisher<Bool, Never>

    /// Marks a todo item as done or not done.
    ///
    /// - Parameters:
    ///   - item: The todo item to update.
    ///   - done: `true` to mark as done, `false` to mark as not done.
    /// - Returns: A publisher that emits the override ID and completes when the operation finishes.
    func markItemAsDone(_ item: TodoItemViewModel, done: Bool) -> AnyPublisher<String, Error>
}

final class TodoInteractorLive: TodoInteractor {
    var todoGroups = CurrentValueSubject<[TodoGroupViewModel], Never>([])

    private let env: AppEnvironment
    private let sessionDefaults: SessionDefaults
    private let coursesStore: ReactiveStore<GetCourses>
    private var subscriptions = Set<AnyCancellable>()

    init(env: AppEnvironment, sessionDefaults: SessionDefaults) {
        self.env = env
        self.sessionDefaults = sessionDefaults
        self.coursesStore = ReactiveStore(useCase: GetCourses(), environment: env)
    }

    // MARK: - Public Methods

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Error> {
        let plannableStore = makePlannablesStore()

        return Publishers.Zip(
            plannableStore.getEntities(ignoreCache: ignoreCache, loadAllPages: true),
            coursesStore.getEntities(ignoreCache: ignoreCache)
        )
        .handleEvents(receiveOutput: { [weak self] plannables, courses in
            self?.filterAndGroupTodos(plannables: plannables, courses: courses)
            self?.logFilterAnalytics()
        })
        .mapToVoid()
        .eraseToAnyPublisher()
    }

    func isCacheExpired() -> AnyPublisher<Bool, Never> {
        let plannablesUseCase = GetPlannables.makeTodoFetchUseCase()

        return Publishers.Zip(
            plannablesUseCase.hasCacheExpired(environment: env),
            coursesStore.useCase.hasCacheExpired(environment: env)
        )
        .map { plannablesExpired, coursesExpired in
            plannablesExpired || coursesExpired
        }
        .eraseToAnyPublisher()
    }

    func markItemAsDone(_ item: TodoItemViewModel, done: Bool) -> AnyPublisher<String, Error> {
        let useCase = MarkPlannableItemDone(
            plannableId: item.plannableId,
            plannableType: item.type.rawValue,
            overrideId: item.overrideId,
            useCaseId: .todo,
            done: done
        )

        return useCase.fetchWithAPIResponse(environment: env)
            .handleEvents(receiveOutput: { _, _ in
                let eventName = done ? "todo_item_marked_done" : "todo_item_marked_undone"
                Analytics.shared.logEvent(eventName)
            })
            .tryMap { response, _ in
                guard let response else {
                    throw NSError.instructureError("No response from API")
                }
                return response.id.value
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    private func makePlannablesStore() -> ReactiveStore<GetPlannables> {
        ReactiveStore(useCase: GetPlannables.makeTodoFetchUseCase(), environment: env)
    }

    private func filterAndGroupTodos(plannables: [Plannable], courses: [Course]) {
        let filterOptions = sessionDefaults.todoFilterOptions ?? TodoFilterOptions.default
        let coursesByCanvasContextIds = Dictionary(uniqueKeysWithValues: courses.map { ($0.canvasContextID, $0) })

        let shouldKeepCompletedItemsVisible = filterOptions.visibilityOptions.contains(.showCompleted)

        let todos = plannables
            .filter { plannable in
                let course = coursesByCanvasContextIds[plannable.canvasContextIDRaw ?? ""]
                return filterOptions.shouldInclude(plannable: plannable, course: course)
            }
            .compactMap { plannable -> TodoItemViewModel? in
                let course = coursesByCanvasContextIds[plannable.canvasContextIDRaw ?? ""]
                guard let item = TodoItemViewModel(plannable, course: course) else { return nil }
                item.shouldKeepCompletedItemsVisible = shouldKeepCompletedItemsVisible
                return item
            }

        let notDoneTodos = todos.filter { $0.markAsDoneState == .notDone }
        TabBarBadgeCounts.todoListCount = UInt(notDoneTodos.count)

        let groupedTodos = todos.groupByDay()
        todoGroups.value = groupedTodos
    }

    private func logFilterAnalytics() {
        let filterOptions = sessionDefaults.todoFilterOptions ?? TodoFilterOptions.default
        Analytics.shared.logEvent(filterOptions.analyticsEventName, parameters: filterOptions.analyticsParameters)
    }
}

private extension [TodoItemViewModel] {

    func groupByDay() -> [TodoGroupViewModel] {
        let todosPerDay = Dictionary(grouping: self) { todo in
            todo.date.startOfDay()
        }

        return todosPerDay
            .map { (date, items) in
                TodoGroupViewModel(date: date, items: items.sorted())
            }
            .sorted()
    }
}

private extension GetPlannables {

    static func makeTodoFetchUseCase() -> GetPlannables {
        let startDate = TodoDateRangeStart.fourWeeksAgo.startDate()
        let endDate = TodoDateRangeEnd.inFourWeeks.endDate()
        return GetPlannables(
            startDate: startDate,
            endDate: endDate,
            contextCodes: nil,
            allowEmptyContextCodesFetch: true,
            useCaseID: .todo
        )
    }
}
