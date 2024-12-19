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
import CombineSchedulers

public protocol CalendarFilterInteractor: AnyObject {
    var filters: CurrentValueSubject<[CDCalendarFilterEntry], Never> { get }
    var filterCountLimit: CurrentValueSubject<CalendarFilterCountLimit, Never> { get }
    var selectedContexts: CurrentValueSubject<Set<Context>, Never> { get }

    func load(ignoreCache: Bool) -> AnyPublisher<Void, Error>
    func updateFilteredContexts(_ contexts: [Context], isSelected: Bool) -> AnyPublisher<Void, Error>
    func updateFilteredContexts(_ contexts: Set<Context>) -> AnyPublisher<Void, Error>

    func contextsForAPIFiltering() -> [Context]
}

public class CalendarFilterInteractorLive: CalendarFilterInteractor {
    public let filters = CurrentValueSubject<[CDCalendarFilterEntry], Never>([])
    public let filterCountLimit = CurrentValueSubject<CalendarFilterCountLimit, Never>(.unlimited)
    public let selectedContexts = CurrentValueSubject<Set<Context>, Never>(Set())

    private let observedUserId: String?
    private var userDefaults: SessionDefaults?
    private let isCalendarFilterLimitEnabled: Bool
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let filterProvider: CalendarFilterEntryProvider
    private var subscriptions = Set<AnyCancellable>()

    required public init(
        observedUserId: String?,
        userDefaults: SessionDefaults? = AppEnvironment.shared.userDefaults,
        filterProvider: CalendarFilterEntryProvider,
        isCalendarFilterLimitEnabled: Bool = AppEnvironment.shared.app.isCalendarFilterLimitEnabled,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.observedUserId = observedUserId
        self.userDefaults = userDefaults
        self.filterProvider = filterProvider
        self.isCalendarFilterLimitEnabled = isCalendarFilterLimitEnabled
        self.scheduler = scheduler

        observeUserDefaultChanges()
    }

    public func load(ignoreCache: Bool) -> AnyPublisher<Void, Error> {
        guard let filterPublisher = filterProvider.make(ignoreCache: ignoreCache) else {
            return Fail<Void, Error>(error: NSError.internalError())
                .eraseToAnyPublisher()
        }

        return ReactiveStore(useCase: GetCustomColors())
            .getEntities(ignoreCache: ignoreCache)
            .mapToVoid()
            .flatMap { filterPublisher }
            .flatMap { [isCalendarFilterLimitEnabled] filters in
                Self.fetchFilterLimit(
                    isCalendarFilterLimitEnabled: isCalendarFilterLimitEnabled,
                    ignoreCache: ignoreCache
                )
                .map { limit in
                    (filters, limit)
                }
            }
            .map { [userDefaults, observedUserId] (filters, limit) in
                let selectedContexts: Set<Context> = {
                    if let loadedContexts = userDefaults?.calendarSelectedContexts(observedStudentId: observedUserId) {
                        return loadedContexts.removeUnavailableFilters(filters: filters)
                    } else {
                        return filters.defaultFilters(limit: limit)
                    }
                }()

                return (filters, limit, selectedContexts)
            }
            .map { [weak self] (filters, limit, selectedContexts) in
                guard let self else { return }
                self.filters.send(filters)
                filterCountLimit.send(limit)
                self.selectedContexts.send(selectedContexts)
                userDefaults?.setCalendarSelectedContexts(selectedContexts, observedStudentId: observedUserId)

                return
            }
            .eraseToAnyPublisher()
    }

    public func updateFilteredContexts(_ contexts: [Context], isSelected: Bool) -> AnyPublisher<Void, Error> {
        guard var defaults = userDefaults else {
            return Fail(error: NSError.internalError()).eraseToAnyPublisher()
        }

        if isSelected,
           selectedContexts.value.count >= filterCountLimit.value.rawValue {
            return Fail(error: NSError.internalError()).eraseToAnyPublisher()
        }

        return Future { [observedUserId, selectedContexts] promise in
            var newSelectedContexts = defaults.calendarSelectedContexts(observedStudentId: observedUserId) ?? Set()

            if isSelected {
                newSelectedContexts.formUnion(contexts)
            } else {
                newSelectedContexts.subtract(contexts)
            }

            defaults.setCalendarSelectedContexts(newSelectedContexts, observedStudentId: observedUserId)
            selectedContexts.send(newSelectedContexts)
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }

    public func updateFilteredContexts(_ contexts: Set<Context>) -> AnyPublisher<Void, Error> {
        guard var defaults = userDefaults else {
            return Fail(error: NSError.internalError()).eraseToAnyPublisher()
        }

        if contexts.count > filterCountLimit.value.rawValue {
            return Fail(error: NSError.internalError()).eraseToAnyPublisher()
        }

        return Future { [observedUserId, selectedContexts] promise in
            defaults.setCalendarSelectedContexts(contexts, observedStudentId: observedUserId)
            selectedContexts.send(contexts)
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }

    public func contextsForAPIFiltering() -> [Context] {
        Array(selectedContexts.value)
    }

    // MARK: - Private

    private static func fetchFilterLimit(
        isCalendarFilterLimitEnabled: Bool,
        ignoreCache: Bool
    ) -> AnyPublisher<CalendarFilterCountLimit, Error> {
        let useCase = GetEnvironmentSettings()
        return ReactiveStore(useCase: useCase)
            .getEntities(ignoreCache: ignoreCache)
            .map { $0.first }
            .map { $0.calendarFilterCountLimit(isCalendarFilterLimitEnabled: isCalendarFilterLimitEnabled) }
            .eraseToAnyPublisher()
    }

    private func observeUserDefaultChanges() {
        NotificationCenter
            .default
            .publisher(for: UserDefaults.didChangeNotification)
            // We delay one cycle to avoid a crash occuring when the observed student changes
            // which also modifies userdefaults violating "Exclusive Access to Memory".
            .receive(on: scheduler)
            .compactMap { [weak self, observedUserId] _ in
                self?.userDefaults?.calendarSelectedContexts(observedStudentId: observedUserId)
            }
            .sink { [weak selectedContexts] newSelectedContexts in
                selectedContexts?.send(newSelectedContexts)
            }
            .store(in: &subscriptions)
    }
}

private extension Set where Element == Context {

    func removeUnavailableFilters(filters: [CDCalendarFilterEntry]) -> Set<Element> {
        // using compactMap here to handle invalid contextIDs, which may have been cached before
        let availableContexts = filters.compactMap { $0.wrappedContext }
        return intersection(availableContexts)
    }
}

private extension Array where Element == CDCalendarFilterEntry {

    func defaultFilters(limit: CalendarFilterCountLimit) -> Set<Context> {
        // using compactMap here to handle invalid contextIDs, which may have been cached before
        let contexts = sorted().compactMap { $0.wrappedContext }
        return Set(contexts.prefix(limit.rawValue))
    }
}
