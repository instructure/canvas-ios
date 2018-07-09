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
    
    // Should be called when from the delegate method shouldSelectViewController
    func logShouldSelectViewController(viewController: UIViewController) {
        let map = ["dashboard_selected", "calendar_selected", "todo_list_selected", "notifications_selected", "inbox_selected"]
        if let index = viewControllers?.index(of: viewController),
            selectedViewController != viewController {
            let event = map[index]
            CanvasAnalytics.logEvent(event)
        }
    }
}

extension CanvasTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        tabBarController.resetViewControllerIfSelected(viewController)
        logShouldSelectViewController(viewController: viewController)
        return true
    }
}
