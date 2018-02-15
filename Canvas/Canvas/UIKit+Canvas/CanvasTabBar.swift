//
// Copyright (C) 2016-present Instructure, Inc.
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
import CanvasCore

class CanvasTabBarController: UITabBarController {
    fileprivate var previousSelectedIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationKitController.registerForPushNotifications()
        DispatchQueue.main.async {
            StartupManager.shared.markStartupFinished()
        }
    }
}

extension CanvasTabBarController: UITabBarControllerDelegate {
    // Couldn't think of a better way to still do the default way of not poping to the root on select, like UITabBarController
    // works by default, with our custom crap. So. Here's a hack. Yay for coupling!
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        previousSelectedIndex = selectedIndex
        return true
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if self.selectedViewController == viewController, selectedIndex == 0, previousSelectedIndex == selectedIndex {
            if let svc = viewController as? EnrollmentSplitViewController, let masterNav = svc.viewControllers.first as? UINavigationController {
                masterNav.popToRootViewController(animated: true)
            }
        }
    }
}
