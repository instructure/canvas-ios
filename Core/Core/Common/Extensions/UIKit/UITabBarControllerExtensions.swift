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
                  let masterNav = splitViewController.masterNavigationController {
            masterNav.dismiss(animated: false, completion: nil)
            if (splitViewController.displayMode == .oneBesideSecondary) {
                masterNav.popToRootViewController(animated: true)
            } else {
                // I was unable to get this to animate nicely, there were some weird side effects.
                // Seemed resonable to punt on animations and just make it work
                masterNav.popToRootViewController(animated: false)
                splitViewController.preferredDisplayMode = .oneBesideSecondary
            }
        }
    }

    public func resetSelectedViewController() {
        guard let selected = selectedViewController else { return }
        resetViewControllerIfSelected(selected)
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        selectedViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }
}
