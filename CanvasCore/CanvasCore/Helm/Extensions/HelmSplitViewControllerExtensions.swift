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

public extension HelmSplitViewController {
    var masterHelmNavigationController: UINavigationController? {
        get {
            return self.viewControllers.first as? UINavigationController
        }
    }
    
    var detailHelmNavigationController: HelmNavigationController? {
        get {
            return detailNavigationController as? HelmNavigationController
        }
    }
    
    var masterTopHelmViewController: HelmViewController? {
        get {
            return masterTopViewController as? HelmViewController
        }
    }
    
    var detailTopHelmViewController: HelmViewController? {
        get {
            return detailTopViewController as? HelmViewController
        }
    }
    
    func sourceController(moduleName: String) -> HelmViewController? {
        if let detailTopViewController = detailTopHelmViewController, detailTopViewController.moduleName == moduleName {
            return detailTopViewController
        }
        
        if let masterTopViewController = masterTopHelmViewController, masterTopViewController.moduleName == moduleName {
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
            return "displayMode: \(self.displayMode) master: \(masterTopHelmViewController?.moduleName ?? "N/A") detail: \(detailTopHelmViewController?.moduleName ?? "N/A") masterVC: \( masterNavigationController != nil ? String(describing: masterNavigationController.self) : "N/A") detailVC: \( detailNavigationController != nil ? String(describing: detailNavigationController.self) : "N/A")"
        }
    }
}
