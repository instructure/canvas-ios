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

import CanvasCore
import Core

extension StudentAppDelegate: RCTBridgeDelegate {
    @objc func prepareReactNative() {
        excludeHelmInBranding()
        NativeLoginManager.shared().delegate = self
        HelmManager.shared.bridge = RCTBridge(delegate: self, launchOptions: nil)
        HelmManager.shared.onReactLoginComplete = {
            guard let window = self.window else { return }
            let controller = StudentTabBarController()
            controller.view.layoutIfNeeded()
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
                window.rootViewController = controller
            }, completion: { _ in
                self.environment.startupDidComplete()
                UIApplication.shared.registerForPushNotifications()
            })
        }

        HelmManager.shared.onReactReload = {
            guard self.window?.rootViewController is StudentTabBarController else { return }
            guard let session = LoginSession.mostRecent else {
                self.changeUser()
                return
            }
            self.setup(session: session)
        }
    }

    @objc func excludeHelmInBranding() {
        let appearance = UINavigationBar.appearance(whenContainedInInstancesOf: [CoreNavigationController.self])
        appearance.barTintColor = nil
        appearance.tintColor = nil
        appearance.titleTextAttributes = nil
    }

    func sourceURL(for bridge: RCTBridge!) -> URL! {
        let url = RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index.ios", fallbackResource: nil)
        return url
    }
}
