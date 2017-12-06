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

public extension UISplitViewController {
    var masterNavigationController: UINavigationController? {
        get {
            if let navigationController = self.viewControllers.first as? UINavigationController {
                return navigationController
            }
            return nil
        }
    }
    
    var detailNavigationController: UINavigationController? {
        get {
            if let navigationController = self.viewControllers.last as? UINavigationController, self.viewControllers.count > 1 {
                return navigationController
            }
            return nil
        }
    }
    
    var masterTopViewController: UIViewController? {
        get {
            if let navigationController = self.viewControllers.first as? UINavigationController {
                if let topViewController = navigationController.topMostViewController() {
                    return topViewController
                }
            }
            return nil
        }
    }
    
    var detailTopViewController: UIViewController? {
        get {
            if let navigationController = self.viewControllers.last as? UINavigationController, self.viewControllers.count > 1 {
                if let topViewController = navigationController.topMostViewController() {
                    return topViewController
                }
            }
            return nil
        }
    }
}

