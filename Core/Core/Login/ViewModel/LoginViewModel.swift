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

import UIKit

public class LoginViewModel {

    public init() {}

    public func showLoginView(on window: UIWindow, loginDelegate: LoginDelegate, app: App) {
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft) {
            window.rootViewController = LoginNavigationController.create(loginDelegate: loginDelegate, app: app)
            Analytics.shared.logScreenView(route: "/login", viewController: window.rootViewController)
        }
    }
}
