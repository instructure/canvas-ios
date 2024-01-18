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
    func isNetworkOffline() -> Bool
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
                context: NSManagedObjectContext = AppEnvironment.shared.database.viewContext,
                isOfflineModeEnabledForApp: Bool) {
        self.availabilityService = availabilityService
        self.availabilityService.startMonitoring()
        self.offlineFlagStore = ReactiveStore(offlineModeInteractor: nil,
                                              context: context,
                                              useCase: Self.LocalFeatureFlagUseCase)

        // If offline mode isn't enabled for the app we just don't
        // update the flag state and leave it at its default false value
        if isOfflineModeEnabledForApp {
            subscribeToOfflineFeatureFlagChanges()
        }
    }

    public func isFeatureFlagEnabled() -> Bool {
        featureFlagEnabled.value
    }

    public func isOfflineModeEnabled() -> Bool {
        isFeatureFlagEnabled() && isNetworkOffline()
    }

    public func isNetworkOffline() -> Bool {
        availabilityService.status == nil || availabilityService.status == .disconnected
    }

    /** Values are published on the main thread. */
    public func observeIsOfflineMode() -> AnyPublisher<Bool, Never> {
        return availabilityService
            .startObservingStatus()
            .map { _ in self.isOfflineModeEnabled() }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    /** Values are published on the main thread. */
    public func observeNetworkStatus() -> AnyPublisher<NetworkAvailabilityStatus, Never> {
        return availabilityService
            .startObservingStatus()
            .compactMap { $0 }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    /** Values are published on the main thread. */
    public func observeIsFeatureFlagEnabled() -> AnyPublisher<Bool, Never> {
        featureFlagEnabled.eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    private func subscribeToOfflineFeatureFlagChanges() {
        offlineFlagStore
            .getEntities(keepObservingDatabaseChanges: true)
            .replaceError(with: [])
            .compactMap { $0.first }
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
