//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public class LoginNavigationController: UINavigationController {
    weak var loginDelegate: LoginDelegate?
    var app: App = .student

    public static func create(loginDelegate: LoginDelegate, fromLaunch: Bool = false, app: App) -> LoginNavigationController {
        let startView = LoginStartViewController.create(loginDelegate: loginDelegate, fromLaunch: fromLaunch, app: app)
        let controller = LoginNavigationController(rootViewController: startView)
        controller.app = app
        controller.loginDelegate = loginDelegate
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.useStyle(.global)
        isNavigationBarHidden = true
    }

    public func login(host: String) {
        viewControllers = [
            LoginStartViewController.create(loginDelegate: loginDelegate, fromLaunch: false, app: app),
            LoginFindSchoolViewController.create(loginDelegate: loginDelegate, method: .normalLogin),
            LoginWebViewController.create(host: host, loginDelegate: loginDelegate, method: .normalLogin),
        ]
    }
}
