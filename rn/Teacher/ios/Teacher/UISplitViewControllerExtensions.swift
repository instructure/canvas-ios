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

extension UISplitViewController {
    var masterNavigationController: HelmNavigationController? {
        get {
            if let navigationController = self.viewControllers.first as? HelmNavigationController {
                return navigationController
            }
            return nil
        }
    }

    var detailNavigationController: HelmNavigationController? {
        get {
            if let navigationController = self.viewControllers.last as? HelmNavigationController, self.viewControllers.count > 1 {
                return navigationController
            }
            return nil
        }
    }

    var masterTopViewController: HelmViewController? {
        get {
            if let navigationController = self.viewControllers.first as? HelmNavigationController {
                if let topViewController = navigationController.topMostViewController() as? HelmViewController {
                    return topViewController
                }
            }
            return nil
        }
    }

    var detailTopViewController: HelmViewController? {
        get {
            if let navigationController = self.viewControllers.last as? HelmNavigationController, self.viewControllers.count > 1 {
                if let topViewController = navigationController.topMostViewController() as? HelmViewController {
                 return topViewController
                }
            }
            return nil
        }
    }

    func sourceController(moduleName: String) -> HelmViewController? {
        if let detailTopViewController = detailTopViewController, detailTopViewController.moduleName == moduleName {
            return detailTopViewController
        }

        if let masterTopViewController = masterTopViewController, masterTopViewController.moduleName == moduleName {
            return masterTopViewController
        }
        return nil
    }

    @discardableResult
    func primeEmptyDetailNavigationController() -> HelmNavigationController {
        let navigationController = HelmNavigationController()
        self.showDetailViewController(navigationController, sender: nil)
        return navigationController
    }

    override open var description: String {
        get {
            return "displayMode: \(self.displayMode) master: \(masterTopViewController?.moduleName ?? "N/A") detail: \(detailTopViewController?.moduleName ?? "N/A") masterVC: \( masterNavigationController != nil ? String(describing: masterNavigationController.self) : "N/A") detailVC: \( detailNavigationController != nil ? String(describing: detailNavigationController.self) : "N/A")"
        }
    }
}
