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
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, AppEnvironmentDelegate, LoginDelegate {
    var window: UIWindow?
    lazy var environment: AppEnvironment = {
        let env = AppEnvironment.shared
        env.loginDelegate = self
        env.router = Router(routes: HorizonRouter.routes)
        env.app = .horizon
        env.window = window
        return env
    }()

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow()
        _ = environment
        window?.rootViewController = SplashAssembly.makeViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

extension AppDelegate {
    func openExternalURL(_: URL) {}

    func userDidLogin(session _: Core.LoginSession) {}

    func userDidLogout(session _: Core.LoginSession) {}
}
