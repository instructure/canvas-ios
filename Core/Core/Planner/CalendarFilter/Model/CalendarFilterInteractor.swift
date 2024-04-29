//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Combine

public protocol CalendarFilterInteractor: AnyObject {
    var filterCountLimit: CurrentValueSubject<CalendarFilterCountLimit, Never> { get }

    func loadFilters(ignoreCache: Bool) -> AnyPublisher<[CDCalendarFilterEntry], Error>

    func observeSelectedContexts() -> AnyPublisher<Set<Context>, Never>
    func updateFilteredContexts(_ context: [Context], isSelected: Bool)

    func contextsForAPIFiltering() -> [Context]
    func numberOfUserSelectedContexts() -> Int
}

public class CalendarFilterInteractorLive: CalendarFilterInteractor {
    public let filterCountLimit = CurrentValueSubject<CalendarFilterCountLimit, Never>(.unlimited)

    private let observedUserId: String?
    private let selectedFilters = CurrentValueSubject<Set<Context>, Never>(Set())
    private let env: AppEnvironment
    private let isCalendarFilterLimitEnabled: Bool
    private var subscriptions = Set<AnyCancellable>()

    required public init(
        observedUserId: String?,
        env: AppEnvironment = .shared,
        isCalendarFilterLimitEnabled: Bool = AppEnvironment.shared.app.isCalendarFilterLimitEnabled
    ) {
        self.observedUserId = observedUserId
        self.env = env
        self.isCalendarFilterLimitEnabled = isCalendarFilterLimitEnabled
        loadSelectedContexts()
        observeUserDefaultChanges()

        if isCalendarFilterLimitEnabled {
            observeFilterCount()
        }
    }

    public func loadFilters(ignoreCache: Bool) -> AnyPublisher<[CDCalendarFilterEntry], Error> {
        let errorPublisher = {
            Fail<[CDCalendarFilterEntry], Error>(error: NSError.internalError())
                .eraseToAnyPublisher()
        }

        guard let filterPublisher = makeFiltersPublisher(ignoreCache: ignoreCache) else {
            return errorPublisher()
        }

        let fetchFilterLimitIfNecessary: ([CDCalendarFilterEntry]) -> AnyPublisher<[CDCalendarFilterEntry], Error> = { [isCalendarFilterLimitEnabled] filters in
            if isCalendarFilterLimitEnabled {
                let useCase = GetEnvironmentSettings()
                return ReactiveStore(useCase: useCase)
                    .getEntities(ignoreCache: ignoreCache)
                    .map { _ in filters }
                    .eraseToAnyPublisher()
            } else {
                return Just(filters)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        }
        let clearUnavailableSelectedFilters: ([CDCalendarFilterEntry]) -> AnyPublisher<[CDCalendarFilterEntry], Error> = { [weak self] filters in
           guard let self else {
               return errorPublisher()
           }
           return clearNotAvailableSelectedContexts(filters: filters)
               .map { filters }
               .setFailureType(to: Error.self)
               .eraseToAnyPublisher()
        }

        return filterPublisher
            .flatMap { fetchFilterLimitIfNecessary($0) }
            .flatMap { clearUnavailableSelectedFilters($0) }
            .eraseToAnyPublisher()
    }

    private func makeFiltersPublisher(ignoreCache: Bool) -> AnyPublisher<[CDCalendarFilterEntry], Error>? {
        guard let userName = env.currentSession?.userName,
              let userId = env.currentSession?.userID,
              let app = env.app
        else {
            return nil
        }

        switch app {
        case .parent:
            guard let observedUserId else {
                return nil
            }
            let useCase = GetParentCalendarFilters(
                currentUserName: userName,
                currentUserId: userId,
                observedStudentId: observedUserId
            )
            return ReactiveStore(useCase: useCase).getEntities(ignoreCache: ignoreCache)
        case .student:
            let useCase = GetCalendarFilters(currentUserName: userName,
                                             currentUserId: userId,
                                             states: [.current_and_concluded],
                                             filterUnpublishedCourses: true)
            return ReactiveStore(useCase: useCase).getEntities(ignoreCache: ignoreCache)
        case .teacher:
            let useCase = GetCalendarFilters(currentUserName: userName,
                                             currentUserId: userId,
                                             states: [],
                                             filterUnpublishedCourses: false)
            return ReactiveStore(useCase: useCase).getEntities(ignoreCache: ignoreCache)
        }
    }

    public func observeSelectedContexts() -> AnyPublisher<Set<Context>, Never> {
        selectedFilters
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func updateFilteredContexts(_ contexts: [Context], isSelected: Bool) {
        guard var defaults = env.userDefaults else { return }

        var selectedContexts = defaults.calendarSelectedContexts(for: observedUserId)

        if isSelected {
            selectedContexts.formUnion(contexts)
        } else {
            selectedContexts.subtract(contexts)
        }

        defaults.setCalendarSelectedContexts(selectedContexts, observedStudentId: observedUserId)
        selectedFilters.send(selectedContexts)
    }

    public func contextsForAPIFiltering() -> [Context] {
        switch env.app {
        case .parent, .student, .none:
            return Array(selectedFilters.value)
        case .teacher:
            return []
        }
    }

    public func numberOfUserSelectedContexts() -> Int {
        selectedFilters.value.count
    }

    // MARK: - Private

    private func clearNotAvailableSelectedContexts(filters: [CDCalendarFilterEntry]) -> Future<Void, Never> {
        Future { [weak self] promise in
            defer { promise(.success(())) }
            guard let self else { return }
            let availableContexts = filters.map { $0.context }
            let selectedContexts = selectedFilters.value
            let noLongerAvailableSelectedContexts = selectedContexts.subtracting(availableContexts)
            updateFilteredContexts(Array(noLongerAvailableSelectedContexts), isSelected: false)
        }
    }

    private func loadSelectedContexts() {
        guard let defaults = env.userDefaults else { return }
        selectedFilters.send(defaults.calendarSelectedContexts(for: observedUserId))
    }

    private func observeUserDefaultChanges() {
        NotificationCenter
            .default
            .publisher(for: UserDefaults.didChangeNotification)
            // We delay one cycle to avoid a crash occuring when the observed student changes
            // which also modifies userdefaults violating "Exclusive Access to Memory".
            .receive(on: RunLoop.main)
            .compactMap { [env, observedUserId] _ in
                env.userDefaults?.calendarSelectedContexts(for: observedUserId)
            }
            .sink { [selectedFilters] selectedContexts in
                selectedFilters.send(selectedContexts)
            }
            .store(in: &subscriptions)
    }

    private func observeFilterCount() {
        let app = env.app
        let useCase = LocalUseCase<CDEnvironmentSetting>(scope: .all)
        ReactiveStore(useCase: useCase)
            .getEntitiesFromDatabase(keepObservingDatabaseChanges: true)
            .replaceError(with: [])
            .map { $0.calendarFilterCountLimit(app: app) }
            .sink { [weak filterCountLimit] filterLimit in
                filterCountLimit?.send(filterLimit)
            }
            .store(in: &subscriptions)
    }
}
