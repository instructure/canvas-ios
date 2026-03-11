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
import CombineSchedulers

enum TodoInteractorError: Error, Equatable {
    /// Thrown when deleted Course entities are detected in the courses array during filtering.
    /// This occurs due to a race condition where GetDashboardCourses deletes courses via
    /// deleteCoursesNotInResponse() while TodoInteractor is processing them.
    /// The retry mechanism with forced cache refresh resolves this by fetching fresh data.
    case deletedCoursesDetected

    /// Thrown when duplicate canvasContextIDs are detected in the courses array.
    /// This can occur when courses have nil/empty IDs due to deletion or data corruption.
    /// The retry mechanism with forced cache refresh resolves this by fetching fresh data.
    case duplicateCourseIdsDetected
}

public protocol TodoInteractor {
    /// The current list of todo groups, grouped by day and filtered according to user preferences.
    /// Updated when `refresh()` is called.
    var todoGroups: CurrentValueSubject<[TodoGroupViewModel], Never> { get }

    /// Fetches todos from the API or cache with separate cache control for plannables and courses.
    ///
    /// This method fetches plannables and courses, applies user's filter preferences,
    /// groups the results by day, and updates the badge count.
    ///
    /// - Parameters:
    ///   - ignorePlannablesCache: If `true`, forces a fetch of plannables from the API.
    ///   - ignoreCoursesCache: If `true`, forces a fetch of courses from the API.
    /// - Returns: A publisher that completes when the refresh operation finishes.
    func refresh(ignorePlannablesCache: Bool, ignoreCoursesCache: Bool) -> AnyPublisher<Void, Error>

    /// Fetches todos for a specific date range without affecting the badge count.
    /// Intended for use by the widget to load data lazily per visible week.
    ///
    /// - Parameters:
    ///   - startDate: The start of the date range to fetch.
    ///   - endDate: The end of the date range to fetch.
    ///   - ignorePlannablesCache: If `true`, forces a fetch of plannables from the API.
    ///   - ignoreCoursesCache: If `true`, forces a fetch of courses from the API.
    /// - Returns: A publisher that completes when the refresh operation finishes.
    func refresh(
        startDate: Date,
        endDate: Date,
        ignorePlannablesCache: Bool,
        ignoreCoursesCache: Bool,
        filterOptions: TodoFilterOptions?
    ) -> AnyPublisher<Void, Error>

    /// Checks if the cache has expired for todo data.
    ///
    /// Returns `true` if the cache has expired and the next `refresh()` call will fetch from the API.
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

public final class TodoInteractorLive: TodoInteractor {
    public var todoGroups = CurrentValueSubject<[TodoGroupViewModel], Never>([])

    private let env: AppEnvironment
    private let sessionDefaults: SessionDefaults
    private let coursesStore: ReactiveStore<GetCourses>
    private let contextColorsStore: ReactiveStore<GetCustomColors>
    private let alwaysExcludeCompleted: Bool
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var subscriptions = Set<AnyCancellable>()
    private var cachedCourses: [Course]?
    private var lastUsedFilterOptions: TodoFilterOptions?

    public init(
        alwaysExcludeCompleted: Bool,
        sessionDefaults: SessionDefaults,
        env: AppEnvironment,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.sessionDefaults = sessionDefaults
        self.alwaysExcludeCompleted = alwaysExcludeCompleted
        self.env = env
        self.scheduler = scheduler
        self.coursesStore = ReactiveStore(useCase: GetCourses(), environment: env)
        self.contextColorsStore = ReactiveStore(useCase: GetCustomColors(), environment: env)
        setupLocalObservation()
    }

    // MARK: - Public Methods

    public func refresh(ignorePlannablesCache: Bool, ignoreCoursesCache: Bool) -> AnyPublisher<Void, Error> {
        refresh(
            plannablesStore: makePlannablesStore(),
            ignorePlannablesCache: ignorePlannablesCache,
            ignoreCoursesCache: ignoreCoursesCache,
            skipBadgeUpdate: false,
            retryCount: 0
        )
    }

    public func refresh(
        startDate: Date,
        endDate: Date,
        ignorePlannablesCache: Bool,
        ignoreCoursesCache: Bool,
        filterOptions: TodoFilterOptions? = nil
    ) -> AnyPublisher<Void, Error> {
        let useCase = GetPlannables(
            startDate: startDate,
            endDate: endDate,
            contextCodes: nil,
            allowEmptyContextCodesFetch: true,
            useCaseID: nil
        )
        let store = ReactiveStore(useCase: useCase, environment: env)
        let widgetFilterOptions = filterOptions ?? sessionDefaults.todoFilterOptions ?? .default
        return refresh(
            plannablesStore: store,
            ignorePlannablesCache: ignorePlannablesCache,
            ignoreCoursesCache: ignoreCoursesCache,
            skipBadgeUpdate: true,
            filterOptions: widgetFilterOptions,
            retryCount: 0
        )
    }

    public func isCacheExpired() -> AnyPublisher<Bool, Never> {
        let plannablesUseCase = GetPlannables.makeTodoFetchUseCase()

        return Publishers.Zip3(
            plannablesUseCase.hasCacheExpired(environment: env),
            coursesStore.useCase.hasCacheExpired(environment: env),
            contextColorsStore.useCase.hasCacheExpired(environment: env)
        )
        .map { plannablesExpired, coursesExpired, colorsExpired in
            plannablesExpired || coursesExpired || colorsExpired
        }
        .eraseToAnyPublisher()
    }

    public func markItemAsDone(_ item: TodoItemViewModel, done: Bool) -> AnyPublisher<String, Error> {
        let useCase = MarkPlannableItemDone(
            plannableId: item.plannableId,
            plannableType: item.type.rawValue,
            overrideId: item.overrideId,
            useCaseId: .todo,
            done: done
        )

        return useCase.fetchWithAPIResponse(environment: env)
            .handleEvents(receiveOutput: { _, _ in
                Analytics.shared.logTodoEvent(done ? .itemMarkedDone : .itemMarkedUndone)
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

    private func setupLocalObservation() {
        let localUseCase = LocalUseCase<Plannable>(scope: GetPlannables.makeTodoFetchUseCase().scope)
        ReactiveStore(useCase: localUseCase, environment: env)
            .getEntitiesFromDatabase(keepObservingDatabaseChanges: true)
            .dropFirst()
            .debounce(for: .milliseconds(100), scheduler: scheduler)
            .sink { _ in
            } receiveValue: { [weak self] plannables in
                guard let self,
                      let courses = self.cachedCourses,
                      let filterOptions = self.lastUsedFilterOptions else { return }
                try? self.filterAndGroupTodos(
                    plannables: plannables,
                    courses: courses,
                    skipBadgeUpdate: self.alwaysExcludeCompleted,
                    filterOptions: filterOptions
                )
            }
            .store(in: &subscriptions)
    }

    private func refresh(
        plannablesStore: ReactiveStore<GetPlannables>,
        ignorePlannablesCache: Bool,
        ignoreCoursesCache: Bool,
        skipBadgeUpdate: Bool,
        filterOptions: TodoFilterOptions? = nil,
        retryCount: Int
    ) -> AnyPublisher<Void, Error> {
        return Publishers.Zip3(
            plannablesStore.getEntities(ignoreCache: ignorePlannablesCache, loadAllPages: true),
            coursesStore.getEntities(ignoreCache: ignoreCoursesCache),
            contextColorsStore.getEntities(ignoreCache: ignoreCoursesCache)
        )
        .tryMap { [weak self] plannables, courses, _ in
            guard let self else { return }
            try self.filterAndGroupTodos(plannables: plannables, courses: courses, skipBadgeUpdate: skipBadgeUpdate, filterOptions: filterOptions)
            self.logFilterAnalytics()
        }
        .catch { [weak self] error -> AnyPublisher<Void, Error> in
            let shouldRetry = error as? TodoInteractorError == .deletedCoursesDetected ||
                              error as? TodoInteractorError == .duplicateCourseIdsDetected

            guard let self,
                  retryCount < 2,
                  shouldRetry else {
                return Fail(error: error).eraseToAnyPublisher()
            }

            return Just(())
                .delay(for: .seconds(0.5), scheduler: scheduler)
                .flatMap { [weak self] _ in
                    self?.refresh(
                        plannablesStore: plannablesStore,
                        ignorePlannablesCache: ignorePlannablesCache,
                        ignoreCoursesCache: true,
                        skipBadgeUpdate: skipBadgeUpdate,
                        filterOptions: filterOptions,
                        retryCount: retryCount + 1
                    ) ?? Publishers.noInstanceFailure()
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    private func makePlannablesStore() -> ReactiveStore<GetPlannables> {
        ReactiveStore(useCase: GetPlannables.makeTodoFetchUseCase(), environment: env)
    }

    private func filterAndGroupTodos(plannables: [Plannable], courses: [Course], skipBadgeUpdate: Bool, filterOptions passedFilterOptions: TodoFilterOptions? = nil) throws {
        let filterOptions = passedFilterOptions ?? sessionDefaults.todoFilterOptions ?? TodoFilterOptions.default
        cachedCourses = courses
        lastUsedFilterOptions = filterOptions

        let hasDeletedCourses = courses.contains { $0.isDeleted }
        if hasDeletedCourses {
            Logger.shared.error("TodoInteractor - Deleted courses detected. Retrying with force refresh.")
            throw TodoInteractorError.deletedCoursesDetected
        }

        let coursesByCanvasContextIds = try Dictionary(courses.map { ($0.canvasContextID, $0) }) { _, _ in
            Logger.shared.error("TodoInteractor - Duplicate course IDs detected. Retrying with force refresh.")
            throw TodoInteractorError.duplicateCourseIdsDetected
        }

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
        if !skipBadgeUpdate {
            TabBarBadgeCounts.todoListCount = UInt(notDoneTodos.count)
        }

        let groupedTodos = (alwaysExcludeCompleted ? notDoneTodos : todos).groupByDay()
        todoGroups.value = groupedTodos
    }

    private func logFilterAnalytics() {
        let filterOptions = sessionDefaults.todoFilterOptions ?? TodoFilterOptions.default
        Analytics.shared.logTodoEvent(.filterApplied(filterOptions))
    }
}

extension [TodoItemViewModel] {

    public func groupByDay() -> [TodoGroupViewModel] {
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
