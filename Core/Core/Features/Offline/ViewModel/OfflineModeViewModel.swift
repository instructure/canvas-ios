//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import Foundation

/// Please use `EnvironmentValues.offlineMode` instead.
public class OfflineModeViewModel: ObservableObject {
    @Published public var isOffline: Bool
    @Published public var isOfflineFeatureEnabled: Bool

    private let interactor: OfflineModeInteractor

    public init(interactor: OfflineModeInteractor) {
        self.interactor = interactor

        isOffline = interactor.isOfflineModeEnabled()
        isOfflineFeatureEnabled = interactor.isFeatureFlagEnabled()
        interactor.observeIsOfflineMode().assign(to: &$isOffline)
        interactor.observeIsFeatureFlagEnabled().assign(to: &$isOfflineFeatureEnabled)
    }
}

@Observable
public final class OfflineMode {
    public var isAppOnline: Bool
    public var isOfflineFeatureEnabled: Bool

    private let interactor: OfflineModeInteractor

    private var subscriptions = Set<AnyCancellable>()

    public init(interactor: OfflineModeInteractor = OfflineModeAssembly.make()) {
        self.interactor = interactor

        isAppOnline = !interactor.isOfflineModeEnabled()
        isOfflineFeatureEnabled = interactor.isFeatureFlagEnabled()

        interactor.observeIsOfflineMode()
            .sink { [weak self] in
                self?.isAppOnline = !$0
            }
            .store(in: &subscriptions)

        interactor.observeIsFeatureFlagEnabled()
            .sink { [weak self] in
                self?.isOfflineFeatureEnabled = $0
            }
            .store(in: &subscriptions)
    }
}
