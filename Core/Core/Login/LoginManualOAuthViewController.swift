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

class LoginManualOAuthViewController: UIViewController {
    @IBOutlet weak var clientIDField: UITextField!
    @IBOutlet weak var clientSecretField: UITextField!

    var authenticationProvider: String?
    let env = AppEnvironment.shared
    var host = ""
    weak var loginDelegate: LoginDelegate?

    static func create(authenticationProvider: String?, host: String, loginDelegate: LoginDelegate?) -> LoginManualOAuthViewController {
        let controller = loadFromStoryboard()
        controller.authenticationProvider = authenticationProvider
        controller.host = host
        controller.loginDelegate = loginDelegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    @IBAction func submit(_ sender: UIButton) {
        guard let id = clientIDField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !id.isEmpty,
            let secret = clientSecretField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !secret.isEmpty else {
            return
        }

        let controller = LoginWebViewController.create(
            authenticationProvider: authenticationProvider,
            host: host,
            loginDelegate: loginDelegate,
            method: .manualOAuthLogin
        )
        let baseURL = URL(string: host.hasPrefix("http") ? host : "https://\(host)")
        controller.mobileVerifyModel = APIVerifyClient(
            authorized: true,
            base_url: baseURL,
            client_id: id,
            client_secret: secret
        )
        env.router.show(controller, from: self)
    }
}
