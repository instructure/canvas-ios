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

    func loadFilters(ignoreCache: Bool) -> any Publisher<[CDCalendarFilterEntry], Error>

    func observeSelectedContexts() -> AnyPublisher<Set<Context>, Never>
    func updateFilteredContexts(_ context: [Context], isSelected: Bool)
}

public class CalendarFilterInteractorLive: CalendarFilterInteractor {
    private let observedUserId: String?
    private let selectedFilters = CurrentValueSubject<Set<Context>, Never>(Set())
    private let env: AppEnvironment
    private var subscriptions = Set<AnyCancellable>()

    required public init(
        observedUserId: String?,
        env: AppEnvironment = .shared
    ) {
        self.observedUserId = observedUserId
        self.env = env
        loadSelectedContexts()
    }

    public func loadFilters(ignoreCache: Bool) -> any Publisher<[CDCalendarFilterEntry], Error> {
        switch env.app {
        case .parent:
            return Fail<[CDCalendarFilterEntry], Error>(error: NSError.internalError())
        case .student:
            guard let userName = env.currentSession?.userName,
                  let userId = env.currentSession?.userID
            else {
                return Fail<[CDCalendarFilterEntry], Error>(error: NSError.internalError())
            }
            let useCase = GetStudentCalendarFilters(currentUserName: userName,
                                                    currentUserId: userId)
            return ReactiveStore(useCase: useCase)
                .getEntities(ignoreCache: ignoreCache)
        case .teacher:
            return Fail<[CDCalendarFilterEntry], Error>(error: NSError.internalError())
        case .none:
            return Fail<[CDCalendarFilterEntry], Error>(error: NSError.internalError())
        }
    }

    public func observeSelectedContexts() -> AnyPublisher<Set<Context>, Never> {
        selectedFilters
            .compactMap { $0 }
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

    private func loadSelectedContexts() {
        guard let defaults = env.userDefaults else { return }
        selectedFilters.send(defaults.calendarSelectedContexts(for: observedUserId))
    }
}
