//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

extension UIApplicationDelegate {

    public func updateInterfaceStyle(for window: UIWindow?) {
        window?.updateInterfaceStyle(AppEnvironment.shared.userDefaults?.interfaceStyle)
    }

    public func showForceUpdateModal(of app: AppEnvironment.App, on controller: UIViewController) {
        let modal = CoreHostingController(ForceUpdateView(app: app, isDismissable: true))
        modal.modalPresentationStyle = .overFullScreen
        controller.present(modal, animated: true)
    }

    public func setForceUpdateView(window: UIWindow?, completion: @escaping () -> Void) {
        guard let window = window else { return }
        let controller = CoreHostingController(ForceUpdateView(app: .student, isDismissable: false))
        controller.view.layoutIfNeeded()
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight) {
            window.rootViewController = controller
        } completion: { _ in
            completion()
        }
    }
}
