//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import Core
import HorizonUI
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, AppEnvironmentDelegate {
    var window: UIWindow?

    private let sessionInteractor = SessionInteractor()
    private lazy var analyticsTracker: PendoAnalyticsTracker = .init(environment: environment)

    lazy var environment: AppEnvironment = {
        let env = AppEnvironment.shared
        env.loginDelegate = sessionInteractor
        env.router = Router(routes: HorizonRoutes.routeHandlers())
        env.app = .horizon
        env.window = window
        env.userDidLogin = userDidLogin
        return env
    }()

    private var subscriptions = Set<AnyCancellable>()

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // MARK: Root view

        window = UIWindow()
        _ = environment
        window?.rootViewController = SplashAssembly.makeViewController()
        window?.makeKeyAndVisible()

        // MARK: Setups

        HorizonUI.registerCustomFonts()

        return true
    }
}

// MARK: - Notification Registration

extension AppDelegate {
    func application(
        _: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        PushNotificationsInteractor.shared.applicationDidRegisterForPushNotifications(deviceToken: deviceToken)
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        AppEnvironment.shared.reportError(error)
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.scheme?.range(of: "pendo") != nil {
            analyticsTracker.initManager(with: url)
            return true
        }
        return false
    }
}

// MARK: - Usage Analytics

extension AppDelegate: Core.AnalyticsHandler {
    func userDidLogin() {
        initializeTracking()
    }

    func handleEvent(_ name: String, parameters: [String: Any]?) {
        analyticsTracker.track(name, properties: parameters)

        PageViewEventController.instance.logPageView(
            name,
            attributes: parameters
        )
    }

    private func initializeTracking() {
        guard !ProcessInfo.isUITest else { return }

        ReactiveStore(
            useCase: GetEnvironmentFeatureFlags(context: Context.currentUser)
        )
        .getEntities()
        .replaceError(with: [])
        .sink { [weak self] environmentFeatureFlags in
            let isTrackingEnabled = environmentFeatureFlags.isFeatureEnabled(.send_usage_metrics)

            if isTrackingEnabled {
                self?.analyticsTracker.startSession()
            } else {
                self?.analyticsTracker.endSession()
            }
        }
        .store(in: &subscriptions)
    }

    private func disableTracking() {
        analyticsTracker.endSession()
    }
}
