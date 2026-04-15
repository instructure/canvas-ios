//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import UIKit

/// Handles starting and ending analytics sessions, and handles the actual custom event tracking.
/// Intended to be created at application start and assigned to the singleton `Analytics.shared`.
/// Its `handleEvent()` is not intended to be used directly, but via the singleton's matching method.
public protocol AnalyticsHandler: AnyObject {

    func initializeTracking(
        environment: AppEnvironment,
        sessionStartCompletion: @escaping () -> Void
    ) -> AnyPublisher<Void, Error>

    func endTracking()

    func handleConsentChange(to isAnalyticsEnabled: Bool, sessionStartCompletion: @escaping () -> Void)

    func handleEvent(_ name: String, parameters: [String: Any]?)

    /// Checks `url` for Pendo Pairing Mode scheme.
    /// If that applies, enters the app into Pendo Pairing Mode, and returns true.
    /// Otherwise does nothing and returns false.
    func handlePendoPairingModeUrl(url: URL) -> Bool
}

extension AnalyticsHandler {
    public func initializeTracking(environment: AppEnvironment) -> AnyPublisher<Void, Error> {
        initializeTracking(environment: environment, sessionStartCompletion: { })
    }

    public func handleConsentChange(to isAnalyticsEnabled: Bool) {
        handleConsentChange(to: isAnalyticsEnabled, sessionStartCompletion: { })
    }
}

extension AnalyticsHandler where Self == AnalyticsHandlerLive {
    public static func live(environment: AppEnvironment) -> AnalyticsHandlerLive {
        .init(
            analyticsTracker: .init(pendoApiKey: environment.pendoApiKey),
            consentInteractorProvider: { .live(environment: $0) }
        )
    }
}

public final class AnalyticsHandlerLive: @MainActor AnalyticsHandler {

    // This is always created at user login even if tracking is disabled.
    // (The actual tracking is of course disabled in that case.)
    // Pendo setup can only be called once during the application lifecycle,
    // and the related flag is stored in `analyticsTracker.isSetupCalled`.
    // That's why this is not an optional and cleared out when not needed for the given user.
    private let analyticsTracker: PendoAnalyticsTracker

    // The interactor is created only when it's actually needed, so it uses
    // the environment after it's already set up for the logged in user.
    // This works around the lazy initialization of the AnalyticsHandler
    // in the AppDelegates, which happens before login.
    private let consentInteractorProvider: (AppEnvironment) -> AnalyticsConsentInteractor
    private var consentInteractor: AnalyticsConsentInteractor?

    public init(
        analyticsTracker: PendoAnalyticsTracker,
        consentInteractorProvider: @escaping (AppEnvironment) -> AnalyticsConsentInteractor
    ) {
        self.analyticsTracker = analyticsTracker
        self.consentInteractorProvider = consentInteractorProvider
    }

    @MainActor
    public func initializeTracking(
        environment: AppEnvironment,
        sessionStartCompletion: @escaping () -> Void
    ) -> AnyPublisher<Void, Error> {
        consentInteractor = consentInteractorProvider(environment)
        Logger.shared.log("AnalyticsHandlerLive.initializeTracking()")

        // Ensure pageview tracking is disabled (clears any leftover from previous user)
        PageViewEventController.instance.endTracking()

        return isTrackingEnabled()
            .receive(on: DispatchQueue.main)
            .map { [weak self] isEnabled in
                self?.handleConsentChange(to: isEnabled, sessionStartCompletion: sessionStartCompletion)
            }
            .eraseToAnyPublisher()
    }

    private func isTrackingEnabled() -> AnyPublisher<Bool, Error> {
        guard !ProcessInfo.isUITest else {
            return Publishers.typedJust(false)
        }

        guard let consentInteractor else {
            return Publishers.typedJust(false)
        }

        return consentInteractor.isTrackingEnabled(ignoreConsentCache: true)
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] isEnabled -> AnyPublisher<Bool, Error> in
                // If the user had already chosen or the feature flags enforce something
                if let isEnabled {
                    return Publishers.typedJust(isEnabled)
                }

                // If the user must be asked
                return self?.showAndHandleConsentDialog()
                    ?? Publishers.typedEmpty()
            }
            .eraseToAnyPublisher()
    }

    private func showAndHandleConsentDialog() -> AnyPublisher<Bool, Error> {
        Future { promise in
            UIAlertController.showAnalyticsConsentDialog { consentFromDialog in
                promise(.success(consentFromDialog))
            }
        }
        .flatMap { [weak self] value in
            self?.setConsent(value)
                ?? Publishers.typedEmpty()
        }
        .eraseToAnyPublisher()
    }

    private func setConsent(_ value: Bool) -> AnyPublisher<Bool, Error> {
        guard let consentInteractor else {
            return Publishers.typedJust(value)
        }

        return consentInteractor.setConsent(value)
            .map { value }
            .eraseToAnyPublisher()
    }

    @MainActor
    public func endTracking() {
        analyticsTracker.endSession()
        PageViewEventController.instance.flushEventsAndEndTracking()
    }

    @MainActor
    public func handleConsentChange(to isAnalyticsEnabled: Bool, sessionStartCompletion: @escaping () -> Void) {
        Logger.shared.log("AnalyticsHandlerLive.handleConsentChange(to: \(isAnalyticsEnabled ? "✅" : "❌"))")
        if isAnalyticsEnabled {
            analyticsTracker.startSession(completion: sessionStartCompletion)
            PageViewEventController.instance.startTracking()
        } else {
            analyticsTracker.endSession()
            PageViewEventController.instance.endTracking()
        }
    }

    public func handleEvent(_ name: String, parameters: [String: Any]?) {
        analyticsTracker.track(name, properties: parameters)
    }

    public func handlePendoPairingModeUrl(url: URL) -> Bool {
        if url.scheme?.range(of: "pendo") != nil {
            analyticsTracker.initManager(with: url)
            return true
        }

        return false
    }
}

private extension AppEnvironment {
    var pendoApiKey: String? {
        guard let app else { return nil }

        return switch app {
        case .student, .horizon: Secret.studentPendoApiKey.string
        case .teacher: Secret.teacherPendoApiKey.string
        case .parent: Secret.parentPendoApiKey.string
        }
    }
}
