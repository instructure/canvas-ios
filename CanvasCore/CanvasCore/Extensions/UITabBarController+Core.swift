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

import Foundation

extension UITabBarController {
    
    // Call this whenever you really want to get to the root of the specified view controller
    // Will only reset the view controller if it's current selected
    public func resetViewControllerIfSelected(_ viewController: UIViewController) {
        guard selectedViewController == viewController else { return }
        viewController.dismiss(animated: false, completion: nil)
        if let navigationController = viewController as? UINavigationController {
            navigationController.dismiss(animated: false, completion: nil)
            navigationController.popToRootViewController(animated: true)
        } else if let splitViewController = viewController as? UISplitViewController,
            let masterNav = splitViewController.viewControllers.first as? UINavigationController {
            masterNav.dismiss(animated: false, completion: nil)
            if (splitViewController.displayMode == .allVisible) {
                masterNav.popToRootViewController(animated: true)
            } else {
                // I was unable to get this to animate nicely, there were some weird side effects.
                // Seemed resonable to punt on animations and just make it work
                masterNav.popToRootViewController(animated: false)
                splitViewController.preferredDisplayMode = .allVisible
            }
        }
    }
    
    public func resetSelectedViewController() {
        guard let selected = selectedViewController else { return }
        resetViewControllerIfSelected(selected)
    }
}
