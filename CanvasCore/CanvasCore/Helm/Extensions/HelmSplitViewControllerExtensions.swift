//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

extension HelmSplitViewController {
    @objc var masterHelmNavigationController: UINavigationController? {
        get {
            return self.viewControllers.first as? UINavigationController
        }
    }
    
    @objc var detailHelmNavigationController: HelmNavigationController? {
        get {
            return detailNavigationController as? HelmNavigationController
        }
    }
    
    @objc func sourceController(moduleName: String) -> UIViewController? {
        if (detailTopViewController as? HelmModule)?.moduleName == moduleName {
            return detailTopViewController
        }
        
        if (masterTopViewController as? HelmModule)?.moduleName == moduleName {
            return masterTopViewController
        }
        return nil
    }
    
    @objc @discardableResult
    func primeEmptyDetailNavigationController() -> HelmNavigationController {
        let navigationController = HelmNavigationController()
        self.showDetailViewController(navigationController, sender: nil)
        return navigationController
    }
    
    override open var description: String {
        get {
            return "<\(type(of: self))  displayMode: \(self.displayMode) master: \((masterTopViewController as? HelmModule)?.moduleName ?? "N/A") detail: \((detailTopViewController as? HelmModule)?.moduleName ?? "N/A") masterVC: \( masterNavigationController != nil ? String(describing: masterNavigationController.self) : "N/A") detailVC: \( detailNavigationController != nil ? String(describing: detailNavigationController.self) : "N/A")"
        }
    }
}
