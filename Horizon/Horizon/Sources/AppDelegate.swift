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

import Core
import HorizonUI
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, AppEnvironmentDelegate {
    var window: UIWindow?

    private let sessionInteractor = SessionInteractor()
    lazy var environment: AppEnvironment = {
        let env = AppEnvironment.shared
        env.loginDelegate = sessionInteractor
        env.router = Router(routes: HorizonRoutes.routeHandlers())
        env.app = .horizon
        env.window = window
        return env
    }()

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
}
