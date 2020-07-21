//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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
import CanvasCore
import Core

class CanvasTabBarController: UITabBarController {
    fileprivate var previousSelectedIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    // Should be called when from the delegate method shouldSelectViewController
    @objc func logShouldSelectViewController(viewController: UIViewController) {
        let map = ["dashboard_selected", "calendar_selected", "todo_list_selected", "notifications_selected", "inbox_selected"]
        if let index = viewControllers?.firstIndex(of: viewController),
            selectedViewController != viewController {
            let event = map[index]
            Analytics.shared.logEvent(event)
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
