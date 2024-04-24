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
    init(observedUserId: String?, env: AppEnvironment)

    func observeFilter() -> AnyPublisher<CDCalendarFilter, Never>
    func load(ignoreCache: Bool) -> any Publisher<Void, Error>
    func updateFilteredContext(_ context: Context, isSelected: Bool)
    func selectAll()
    func deselectAll()
}

public class CalendarFilterInteractorLive: CalendarFilterInteractor {
    private let observedUserId: String?
    private let filterEntity = CurrentValueSubject<CDCalendarFilter?, Never>(nil)
    private let env: AppEnvironment
    private var subscriptions = Set<AnyCancellable>()

    required public init(
        observedUserId: String?,
        env: AppEnvironment = .shared
    ) {
        self.observedUserId = observedUserId
        self.env = env
        startObservingDatabase()
    }

    public func observeFilter() -> AnyPublisher<CDCalendarFilter, Never> {
        filterEntity
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    public func updateFilteredContext(_ context: Context, isSelected: Bool) {
        updateFilteredContext([context], isSelected: isSelected)
    }

    public func load(ignoreCache: Bool) -> any Publisher<Void, Error> {
        switch env.app {
        case .parent:
            return Fail<Void, Error>(error: NSError.internalError())
        case .student:
            guard let userName = env.currentSession?.userName,
                  let userId = env.currentSession?.userID
            else {
                return Fail<Void, Error>(error: NSError.internalError())
            }
            let useCase = GetStudentCalendarFilter(currentUserName: userName,
                                                   currentUserId: userId)
            return ReactiveStore(useCase: useCase)
                    .getEntities(ignoreCache: ignoreCache)
                    .mapToVoid()
        case .teacher:
            return Fail<Void, Error>(error: NSError.internalError())
        case .none:
            return Fail<Void, Error>(error: NSError.internalError())
        }
    }

    public func selectAll() {
        guard let filter = filterEntity.value else { return }
        updateFilteredContext(filter.entries.map(\.context), isSelected: true)
    }

    public func deselectAll() {
        guard let filter = filterEntity.value,
              let dbContext = filter.managedObjectContext
        else { return }

        dbContext.perform {
            filter.selectedContexts = Set()
            try? dbContext.save()
        }
    }

    private func updateFilteredContext(_ contexts: [Context], isSelected: Bool) {
        guard let filter = filterEntity.value,
              let dbContext = filter.managedObjectContext
        else { return }

        dbContext.perform {
            var selectedContexts = filter.selectedContexts

            if isSelected {
                selectedContexts.formUnion(contexts)
            } else {
                selectedContexts.subtract(contexts)
            }

            filter.selectedContexts = selectedContexts
            try? dbContext.save()
        }
    }

    private func startObservingDatabase() {
        let scope = Scope.where(
            (\CDCalendarFilter.observedUserId).string,
            equals: observedUserId,
            sortDescriptors: []
        )
        let useCase = LocalUseCase<CDCalendarFilter>(scope: scope)
        ReactiveStore(offlineModeInteractor: nil, useCase: useCase)
            .getEntities(keepObservingDatabaseChanges: true)
            .replaceError(with: [])
            .compactMap { $0.first }
            .sink { [weak filterEntity] in
                filterEntity?.send($0)
            }
            .store(in: &subscriptions)
    }
}
