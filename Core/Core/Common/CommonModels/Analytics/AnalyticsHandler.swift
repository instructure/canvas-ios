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

public protocol AnalyticsHandler: AnyObject {

    func initializeTracking(sessionStartCompletion: @escaping () -> Void) -> AnyPublisher<Void, Error>

    func endTracking()

    func handleEvent(_ name: String, parameters: [String: Any]?)

    /// Checks `url` for Pendo Pairing Mode scheme.
    /// If that applies, enters the app into Pendo Pairing Mode, and returns true.
    /// Otherwise does nothing and returns false.
    func handlePendoPairingModeUrl(url: URL) -> Bool
}

extension AnalyticsHandler where Self == AnalyticsHandlerLive {
    public static func live(environment: AppEnvironment) -> AnalyticsHandlerLive {
        .init(environment: environment)
    }
}

public final class AnalyticsHandlerLive: @MainActor AnalyticsHandler {

    private var analyticsTracker: PendoAnalyticsTracker
    private let consentInteractor: AnalyticsConsentInteractor

    private let environment: AppEnvironment

    public init(environment: AppEnvironment) {
        // This is always created at user login even if tracking is disabled.
        // (The actual tracking is of course disabled in that case.)
        // Pendo setup can only be called once during the application lifecycle,
        // and the related flag is stored in `analyticsTracker.isSetupCalled`.
        // That's why this is not an optional and cleared out when not needed for the given user.
        self.analyticsTracker = PendoAnalyticsTracker(environment: environment)

        self.consentInteractor = AnalyticsConsentInteractorLive(environment: environment)

        self.environment = environment
    }

    @MainActor
    public func initializeTracking(sessionStartCompletion: @escaping () -> Void) -> AnyPublisher<Void, Error> {
        isTrackingEnabled()
            .receive(on: DispatchQueue.main)
            .map { [analyticsTracker] isEnabled in
                if isEnabled {
                    analyticsTracker.startSession(completion: sessionStartCompletion)
                } else {
                    analyticsTracker.endSession()
                }
            }
            .eraseToAnyPublisher()
    }

    private func isTrackingEnabled() -> AnyPublisher<Bool, Error> {
        guard !ProcessInfo.isUITest else {
            return Publishers.typedJust(false)
        }

        return consentInteractor.isTrackingEnabled()
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] isEnabled -> AnyPublisher<Bool, Never> in
                // If the user had already choosen or the feature flags enforce something
                if let isEnabled {
                    return Publishers.typedJust(isEnabled)
                }

                // If the user must be asked
                return self?.showConsentDialog()
                    ?? Publishers.typedEmpty()
            }
            .eraseToAnyPublisher()
    }

    private func showConsentDialog() -> AnyPublisher<Bool, Never> {
        Future { [environment] promise in
            UIAlertController.showAnalyticsConsentDialog(env: environment) { consentFromDialog in
                promise(.success(consentFromDialog))
            }
        }
        .eraseToAnyPublisher()
    }

    @MainActor
    public func endTracking() {
        analyticsTracker.endSession()
    }

    public func handleEvent(_ name: String, parameters: [String: Any]?) {
        analyticsTracker.track(name, properties: parameters)

        PageViewEventController.instance.logPageView(
            name,
            attributes: parameters
        )
    }

    public func handlePendoPairingModeUrl(url: URL) -> Bool {
        if url.scheme?.range(of: "pendo") != nil {
            analyticsTracker.initManager(with: url)
            return true
        }

        return false
    }
}
