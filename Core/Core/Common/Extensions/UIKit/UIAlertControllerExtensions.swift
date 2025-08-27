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

import UIKit

extension UIAlertController {
    public static func loginErrorAlert(
        cancelAction: @escaping () -> Void,
        retryAction: @escaping () -> Void
    ) -> UIAlertController {
        let title = String(localized: "Oops, something went wrong", bundle: .core)
        let message = String(
            localized: "There was an error while logging you in. You can try again, or come back a bit later.",
            bundle: .core
        )
        let logoutTitle = String(localized: "Logout", bundle: .core)
        let retryTitle = String(localized: "Retry", bundle: .core)

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let cancelAlertAction = AlertAction(logoutTitle, style: .cancel) { _ in
            cancelAction()
        }

        let retryAlertAction = AlertAction(retryTitle, style: .default) { _ in
            retryAction()
        }

        alert.addAction(cancelAlertAction)
        alert.addAction(retryAlertAction)

        return alert
    }

    public static func showLoginErrorAlert(
        env: AppEnvironment = .shared,
        cancelAction: @escaping () -> Void,
        retryAction: @escaping () -> Void
    ) {
        let alert = loginErrorAlert(
            cancelAction: cancelAction,
            retryAction: retryAction
        )

        if let viewController = env.topViewController {
            env.router.show(alert, from: viewController, options: .modal())
        }
    }
}
