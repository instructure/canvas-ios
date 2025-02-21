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

import Combine
import CombineExt

public class InboxSettingsInteractorLive: InboxSettingsInteractor {
    public let state = CurrentValueSubject<StoreState, Never>(.loading)
    public let settings = PassthroughRelay<InboxSettings>()

    private var subscriptions = Set<AnyCancellable>()
    private var settingsStore: ReactiveStore<GetInboxSettings>

    public init(userId: String) {
        self.settingsStore = ReactiveStore(useCase: GetInboxSettings(userId: userId))

        settingsStore.getEntities()
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] settings in
                if let value = settings.first {
                    self?.settings.accept(value)
                }
            })
            .store(in: &subscriptions)
    }

    public func refresh() -> AnyPublisher<Void, Never> {
        settingsStore.forceRefresh()
    }
}
