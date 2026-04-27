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

    /// Returns whether analytics tracking is enabled, disabled or consent is needed.
    /// - Returns `.trackingEnabled`
    ///   - if feature flags govern that it's always enabled (no consent required),
    ///   - OR if consent is required and the user had already accepted.
    /// - Returns `.trackingDisabled`
    ///   - if feature flags govern that it's always disabled (no consent required),
    ///   - OR if consent is required and the user had already declined (for the given device),
    ///   - OR if the user is masqueareding.
    /// - Returns `.askForConsent`
    ///   - if consent is required but it's not yet provided by the user.
    func getTrackingPolicy(ignoreCache: Bool) -> AnyPublisher<TrackingPolicy, Error>

    /// Returns `true` when consent is required based on feature flags and the user is not masqueareding.
    /// Ignores whether user consent was given or not.
    func isConsentRequired(ignoreCache: Bool) -> AnyPublisher<Bool, Error>

    /// Returns the value of the analytics tracking consent, if any.
    /// - Returns `true` or `false` if consent is required and the user had already chosen.
    /// - Returns `nil` if consent is not required (or if the user had not yet provided it).
    /// - Returns `nil` if the user is masqueareding.
    func getConsentIfRequired() -> AnyPublisher<Bool?, Error>

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
    private let userSettingsStore: ReactiveStore<GetUserSettings>

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

        self.userSettingsStore = ReactiveStore(
            useCase: GetUserSettings(),
            backgroundEnv: environment
        )
    }

    public func getTrackingPolicy(ignoreCache: Bool) -> AnyPublisher<TrackingPolicy, Error> {
        getPreConsentTrackingPolicy(ignoreCache: ignoreCache)
            .map { [weak self] preConsentPolicy in
                guard let self else { return .trackingDisabled }

                // return predefined enabled/disabled policy
                if preConsentPolicy.isPredefined {
                    clearUserProvidedConsent()
                    return preConsentPolicy
                }

                // return user consent based policy
                if let userProvidedConsent {
                    return userProvidedConsent ? .trackingEnabled : .trackingDisabled
                }

                return .askForConsent
            }
            .eraseToAnyPublisher()
    }

    public func isConsentRequired(ignoreCache: Bool) -> AnyPublisher<Bool, Error> {
        getPreConsentTrackingPolicy(ignoreCache: ignoreCache)
            .map { $0 == .askForConsent }
            .eraseToAnyPublisher()
    }

    public func getConsentIfRequired() -> AnyPublisher<Bool?, Error> {
        getPreConsentTrackingPolicy(ignoreCache: false)
            .map { [weak self] in
                guard $0 == .askForConsent,
                      let userProvidedConsent = self?.userProvidedConsent
                else { return nil }

                return userProvidedConsent
            }
            .eraseToAnyPublisher()
    }

    private func getPreConsentTrackingPolicy(ignoreCache: Bool) -> AnyPublisher<TrackingPolicy, Error> {
        if isMasqueareding {
            return Publishers.typedJust(.trackingDisabled)
        }

        return userSettingsStore
            .getEntities(ignoreCache: ignoreCache)
            .map(\.first?.trackingPolicy)
            .flatMap { [weak self] trackingPolicy -> AnyPublisher<TrackingPolicy, Error> in
                guard let self else { return Publishers.noInstanceFailure() }

                if let trackingPolicy {
                    return Publishers.typedJust(trackingPolicy)
                }

                return getLegacyTrackingFlag(ignoreCache: ignoreCache)
                    .map { $0 ? .trackingEnabled : .trackingDisabled }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    /// We use this FF as a fallback in case `user/self/settings` does not return the `user_metrics` field.
    /// Once that field is reliably returned, we won't need this fallback anymore.
    /// (The FF's value will be already checked on backend side.)
    private func getLegacyTrackingFlag(ignoreCache: Bool) -> AnyPublisher<Bool, Error> {
        featureFlagStore
            .getEntities(ignoreCache: ignoreCache)
            .map { $0.isFeatureEnabled(.send_usage_metrics) }
            .eraseToAnyPublisher()
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
