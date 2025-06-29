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

public class InboxSettingsInteractorLive: InboxSettingsInteractor {
    public let state = CurrentValueSubject<StoreState, Never>(.loading)
    public let signature = CurrentValueSubject<(useSignature: Bool, String?), Never>((false, nil))
    public let settings = CurrentValueSubject<CDInboxSettings?, Never>(nil)
    public let environmentSettings = CurrentValueSubject<CDEnvironmentSettings?, Never>(nil)
    public let isFeatureEnabled = CurrentValueSubject<Bool, Never>(false)

    private var subscriptions = Set<AnyCancellable>()
    private var settingsStore: ReactiveStore<GetInboxSettings>
    private var environmentSettingsStore: ReactiveStore<GetEnvironmentSettings>

    private let environment: AppEnvironment

    public init(environment: AppEnvironment) {
        let userId = environment.currentSession?.userID ?? ""
        self.settingsStore = ReactiveStore(useCase: GetInboxSettings(userId: userId))
        self.environmentSettingsStore = ReactiveStore(useCase: GetEnvironmentSettings())
        self.environment = environment

        getValues()
    }

    private func getValues(forceRefresh: Bool = false) {
        settingsStore
            .getEntities(ignoreCache: forceRefresh, keepObservingDatabaseChanges: true)
            .sink(
                receiveCompletion: { [weak self] result in
                    if case .failure = result {
                        self?.state.send(.error)
                    }
                },
                receiveValue: { [weak self] settings in
                    if let value = settings.first {
                        self?.settings.send(value)
                    } else {
                        self?.state.send(.error)
                    }
                }
            )
            .store(in: &subscriptions)

        environmentSettingsStore
            .getEntities(ignoreCache: forceRefresh, keepObservingDatabaseChanges: true)
            .sink(
                receiveCompletion: { [weak self] result in
                    if case .failure = result {
                        self?.state.send(.error)
                    }
                },
                receiveValue: { [weak self, environment] settings in
                    if let settings = settings.first {
                        self?.environmentSettings.send(settings)

                        var isFeatureEnabled = settings.enableInboxSignatureBlock
                        if (environment.app == .student) {
                            isFeatureEnabled = isFeatureEnabled && !settings.disableInboxSignatureBlockForStudents
                        }
                        self?.isFeatureEnabled.send(isFeatureEnabled)
                    } else {
                        self?.state.send(.error)
                    }
                }
            )
            .store(in: &subscriptions)

        Publishers.CombineLatest(settings, environmentSettings)
            .sink { [weak self, environment] (settings, environmentSettings) in
                guard let settings, let environmentSettings else { return }
                var useSignature = settings.useSignature && environmentSettings.enableInboxSignatureBlock
                if environment.app == .student {
                    useSignature = useSignature && !environmentSettings.disableInboxSignatureBlockForStudents
                }
                self?.state.send(.data)
                self?.signature.send((useSignature, settings.signature))
            }
            .store(in: &subscriptions)
    }

    public func updateInboxSettings(inboxSettings: CDInboxSettings) -> AnyPublisher<Void, Error> {
        return UpdateInboxSettings(inboxSettings: inboxSettings)
            .fetchWithFuture(environment: environment)
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    public func refresh() {
        state.send(.loading)
        getValues(forceRefresh: true)
    }
}
