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
import CombineExt
import CoreData

public protocol OfflineModeInteractor {
    func isFeatureFlagEnabled() -> Bool
    func isOfflineModeEnabled() -> Bool
    func observeIsFeatureFlagEnabled() -> AnyPublisher<Bool, Never>
    func observeIsOfflineMode() -> AnyPublisher<Bool, Never>
    func observeNetworkStatus() -> AnyPublisher<NetworkAvailabilityStatus, Never>
}

public final class OfflineModeInteractorLive: OfflineModeInteractor {
    // MARK: - Dependencies
    private let availabilityService: NetworkAvailabilityService

    // MARK: - Internal State
    private var featureFlagEnabled = CurrentValueRelay<Bool>(false)
    private let offlineFlagStore: ReactiveStore<LocalUseCase<FeatureFlag>>
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Public Interface

    public init(availabilityService: NetworkAvailabilityService = NetworkAvailabilityServiceLive(),
                context: NSManagedObjectContext = AppEnvironment.shared.database.viewContext) {
        self.availabilityService = availabilityService
        self.availabilityService.startMonitoring()
        self.offlineFlagStore = ReactiveStore(offlineModeInteractor: nil,
                                              context: context,
                                              useCase: Self.LocalFeatureFlagUseCase)
        subscribeToOfflineFeatureFlagChanges()
    }

    deinit {
        offlineFlagStore.cancel()
    }

    public func isFeatureFlagEnabled() -> Bool {
        featureFlagEnabled.value
    }

    public func isOfflineModeEnabled() -> Bool {
        isFeatureFlagEnabled() && isNetworkOffline()
    }

    public func observeIsOfflineMode() -> AnyPublisher<Bool, Never> {
        return availabilityService
            .startObservingStatus()
            .receive(on: DispatchQueue.main)
            .map { _ in self.isOfflineModeEnabled() }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func observeNetworkStatus() -> AnyPublisher<NetworkAvailabilityStatus, Never> {
        return availabilityService
            .startObservingStatus()
            .receive(on: DispatchQueue.main)
            .map { $0 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func observeIsFeatureFlagEnabled() -> AnyPublisher<Bool, Never> {
        featureFlagEnabled.eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    private func isNetworkOffline() -> Bool {
        !availabilityService.status.isConnected
    }

    private func subscribeToOfflineFeatureFlagChanges() {
        offlineFlagStore
            .observeEntities()
            .compactMap { $0.firstItem }
            .map { $0.enabled }
            .subscribe(featureFlagEnabled)
            .store(in: &subscriptions)
    }

    private static var LocalFeatureFlagUseCase: LocalUseCase<FeatureFlag> {
        let environmentFlagsPredicate = GetEnvironmentFeatureFlags(context: .currentUser).scope.predicate
        let offlineFlagFilter = NSPredicate(key: #keyPath(FeatureFlag.name), equals: EnvironmentFeatureFlags.mobile_offline_mode.rawValue)
        let offlineFlagScope = Scope(predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [environmentFlagsPredicate, offlineFlagFilter]),
                                     order: [])
        return LocalUseCase<FeatureFlag>(scope: offlineFlagScope)
    }
}
