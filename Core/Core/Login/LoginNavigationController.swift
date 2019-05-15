//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

public class LoginNavigationController: UINavigationController {
    weak var loginDelegate: LoginDelegate?

    public static func create(loginDelegate: LoginDelegate, fromLaunch: Bool = false) -> LoginNavigationController {
        let startView = LoginStartViewController.create(loginDelegate: loginDelegate, fromLaunch: fromLaunch)
        let controller = LoginNavigationController(rootViewController: startView)
        controller.loginDelegate = loginDelegate
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = nil // use platform default
        navigationBar.barTintColor = .named(.backgroundLightest)
        navigationBar.barStyle = .default
        navigationBar.isTranslucent = true
        isNavigationBarHidden = true
    }

    public func login(host: String) {
        viewControllers = [
            LoginStartViewController.create(loginDelegate: loginDelegate, fromLaunch: false),
            LoginFindSchoolViewController.create(loginDelegate: loginDelegate, method: .normalLogin),
            LoginWebViewController.create(host: host, loginDelegate: loginDelegate, method: .normalLogin),
        ]
    }
}
