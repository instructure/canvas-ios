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

    /// Returns whether analytics tracking is enabled.
    /// - Returns `true` or `false` if feature flags govern that it's always enabled/disabled.
    ///   In this case no consent is required.
    /// - Returns `false` if the user is masqueareding.
    /// - Returns `true` or `false` if consent is required and the user had already chosen.
    /// - Returns `nil` if consent is required but it's not yet provided by the user.
    func isTrackingEnabled() -> AnyPublisher<Bool?, Error>

    /// Returns the value of the analytics tracking consent, if any.
    /// - Returns `true` or `false` if consent is required and the user had already chosen.
    /// - Returns `nil` if consent is not required (or if the user had not yet provided it).
    /// - Returns `nil` if the user is masqueareding.
    func getConsentIfRequired(ignoreCache: Bool) -> AnyPublisher<Bool?, Error>

    /// Sets the consent to `value`.
    func setConsent(_ value: Bool) throws
}

extension AnalyticsConsentInteractor where Self == AnalyticsConsentInteractorLive {
    public static func live(environment: AppEnvironment) -> AnalyticsConsentInteractorLive {
        .init(environment: environment)
    }
}

public class AnalyticsConsentInteractorLive: AnalyticsConsentInteractor {

    private let featureFlagStore: ReactiveStore<GetEnvironmentFeatureFlags>
    private let consentStore: ReactiveStore<GetAnalyticsConsent>

    private var userProvidedConsent: Bool? {
        get { environment.userDefaults?.userProvidedAnalyticsConsent }
        set { environment.userDefaults?.userProvidedAnalyticsConsent = newValue }
    }

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

    public func isTrackingEnabled() -> AnyPublisher<Bool?, Error> {
        featureFlagStore
            .getEntities()
            .map { [weak self] featureFlags in
                guard let self else { return nil }

                if let value = isTrackingEnabledPreConsent(featureFlags: featureFlags) {
                    clearUserProvidedConsent()
                    return value
                }

                return userProvidedConsent
            }
            .eraseToAnyPublisher()
    }

    public func getConsentIfRequired(ignoreCache: Bool) -> AnyPublisher<Bool?, Error> {
        featureFlagStore
            .getEntities(ignoreCache: ignoreCache)
            .map { [weak self] featureFlags in
                guard let self else { return nil }

                if isTrackingEnabledPreConsent(featureFlags: featureFlags) != nil {
                    clearUserProvidedConsent()
                    return nil
                }

                return userProvidedConsent
            }
            .eraseToAnyPublisher()
    }

    private func isTrackingEnabledPreConsent(featureFlags: [FeatureFlag]) -> Bool? {
        if isMasqueareding {
            return false
        }

        guard featureFlags.isFeatureEnabled(.send_usage_metrics) else {
            return false
        }

        if featureFlags.isFeatureEnabled(.cookie_consent_necessary) {
            return nil
        } else {
            return true
        }
    }

    public func setConsent(_ value: Bool) throws {
        if isMasqueareding {
            throw AnalyticsConsentError()
        }

        userProvidedConsent = value
    }

    private var isMasqueareding: Bool {
        AppEnvironment.shared.currentSession?.masquerader != nil
    }

    private func clearUserProvidedConsent() {
        userProvidedConsent = nil
    }
}

private struct AnalyticsConsentError: Error { }
