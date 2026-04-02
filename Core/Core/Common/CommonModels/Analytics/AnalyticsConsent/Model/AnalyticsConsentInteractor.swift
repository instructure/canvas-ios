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
import Foundation

public protocol AnalyticsConsentInteractor {
    func isTrackingEnabled(ignoreConsentCache: Bool) -> AnyPublisher<Bool?, Error>
    func setConsent(_ value: Bool) -> AnyPublisher<Void, Error>
}

extension AnalyticsConsentInteractor where Self == AnalyticsConsentInteractorLive {
    public static func live(environment: AppEnvironment) -> AnalyticsConsentInteractorLive {
        .init(environment: environment)
    }
}

public class AnalyticsConsentInteractorLive: AnalyticsConsentInteractor {

    private let featureFlagStore: ReactiveStore<GetEnvironmentFeatureFlags>
    private let consentStore: ReactiveStore<GetAnalyticsConsent>

    private let environment: AppEnvironment

    public init(environment: AppEnvironment) {
        self.environment = environment

        self.featureFlagStore = ReactiveStore(
            useCase: GetEnvironmentFeatureFlags(context: Context.currentUser),
            backgroundEnv: environment
        )

        self.consentStore = ReactiveStore(
            useCase: GetAnalyticsConsent(app: environment.app ?? .student),
            backgroundEnv: environment
        )
    }

    public func isTrackingEnabled(ignoreConsentCache: Bool) -> AnyPublisher<Bool?, Error> {
        featureFlagStore
            .getEntities()
            .flatMap { [weak self] featureFlags -> AnyPublisher<Bool?, Error> in
                guard featureFlags.isFeatureEnabled(.send_usage_metrics) else {
                    return Publishers.typedJust(false)
                }

                if featureFlags.isFeatureEnabled(.cookie_consent_necessary) {
                    return self?.getConsent(ignoreCache: ignoreConsentCache)
                        ?? Publishers.typedEmpty()
                } else {
                    return Publishers.typedJust(true)
                }
            }
            .eraseToAnyPublisher()
    }

    private func getConsent(ignoreCache: Bool) -> AnyPublisher<Bool?, Error> {
        consentStore
            .getEntities(ignoreCache: ignoreCache)
            .map { entities in entities.first?.consentValue }
            .eraseToAnyPublisher()
    }

    public func setConsent(_ value: Bool) -> AnyPublisher<Void, Error> {
        ReactiveStore(
            useCase: SetAnalyticsConsent(app: environment.app ?? .student, value: value),
            backgroundEnv: environment
        )
        .getEntities(ignoreCache: true)
        .map { _ in }
        .eraseToAnyPublisher()
    }
}
