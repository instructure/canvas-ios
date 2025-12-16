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
import Core
import Combine

@Observable
public final class HelloWidgetViewModel {
    private(set) var state = State.loading

    @ObservationIgnored private let store: ReactiveStore<GetUserProfile>
    @ObservationIgnored private var subscriptions = Set<AnyCancellable>()
    @ObservationIgnored private var periodProvider: DayPeriodProvider

    init(
        environment: AppEnvironment = .shared,
        dayPeriodProvider: DayPeriodProvider = .init(),
        refresh: PassthroughSubject<Void, Never>
    ) {
        self.store = ReactiveStore(
            context: environment.database.viewContext,
            useCase: GetUserProfile(userID: "self"),
            environment: environment
        )
        self.periodProvider = dayPeriodProvider

        store.getEntities(keepObservingDatabaseChanges: true)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.state = .error
                    }
                },
                receiveValue: { [weak self] profiles in
                    self?.refreshData(profile: profiles.first)
                }
            )
            .store(in: &subscriptions)

        refresh
            .flatMap { [weak self] in
                self?.store.forceRefresh() ?? Just(()).eraseToAnyPublisher()
            }
            .sink { _ in }
            .store(in: &subscriptions)
    }

    private func refreshData(profile: UserProfile?) {
        guard let message = message() else {
            // when generic + periodMessages is empty, will not happen
            return
        }

        state = .success(
            greeting: greeting(to: profile?.shortName),
            message: message
        )
    }

    private func greeting(to shortName: String?) -> String.LocalizationValue {
        return if let shortName, shortName.isNotEmptyOrBlank() {
            switch periodProvider.current {
            case .morning: "Good morning \(shortName)!"
            case .afternoon: "Good afternoon \(shortName)!"
            case .evening: "Good evening \(shortName)!"
            case .night: "Good night \(shortName)!"
            }
        } else {
            switch periodProvider.current {
            case .morning: "Good morning!"
            case .afternoon: "Good afternoon!"
            case .evening: "Good evening!"
            case .night: "Good night!"
            }
        }
    }

    private func message() -> String.LocalizationValue? {
        let periodMessages = switch periodProvider.current {
        case .morning: Self.morning
        case .afternoon: Self.afternoon
        case .evening: Self.evening
        case .night: Self.night
        }

        return (Self.generic + periodMessages).randomElement()
    }
}

extension HelloWidgetViewModel {
    enum State: Equatable {
        case error
        case success(greeting: String.LocalizationValue, message: String.LocalizationValue)
        case loading
    }
}
