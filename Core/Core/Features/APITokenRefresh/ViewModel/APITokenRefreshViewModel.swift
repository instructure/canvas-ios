//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

class APITokenRefreshViewModel {

    func reLoginUser(
        host: String,
        rootViewController: UIViewController,
        router: Router,
        completion: @escaping (LoginSession?) -> Void
    ) {
        Task {
            await showLoginDialog(rootViewController: rootViewController)
            let newSession = await showLoginWebViewController(host: host, rootViewController: rootViewController, router: router)
            completion(newSession)
        }
    }

    @MainActor
    private func showLoginDialog(
        rootViewController: UIViewController
    ) async {
        await withCheckedContinuation { continuation in
            let message = String(
                localized: "You'll need to log in again due to your institute's security policy.\nOnce logged in, you can continue working seamlessly.",
                bundle: .core
            )
            let alert = UIAlertController(
                title: nil,
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(AlertAction(String(localized: "OK", bundle: .core), style: .default) { _ in
                continuation.resume()
            })
            rootViewController.present(alert, animated: true)
        }
    }

    @MainActor
    private func showLoginWebViewController(
        host: String,
        rootViewController: UIViewController,
        router: Router
    ) async -> LoginSession? {
        await withCheckedContinuation { continuation in
            let controller = LoginWebViewController.create(host: host, loginDelegate: nil, method: .normalLogin)
            controller.loginCompletion = { [unowned controller] newSession in
                controller.dismiss(animated: true) {
                    continuation.resume(returning: newSession)
                }
            }
            let cancelButton = UIBarButtonItemWithCompletion(
                title: String(localized: "Cancel", bundle: .core),
                actionHandler: { [weak controller] in
                    controller?.dismiss(animated: true) {
                        continuation.resume(returning: nil)
                    }
                }
            )
            controller.navigationItem.rightBarButtonItem = cancelButton

            router.show(
                controller,
                from: rootViewController,
                options: .modal(
                    isDismissable: false,
                    embedInNav: true,
                    addDoneButton: false,
                    animated: true
                ),
                analyticsRoute: "/login/weblogin"
            )
        }
    }
}
