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

class EnrollmentSplitViewController: HelmSplitViewController {
    
    override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EnrollmentSplitViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let masterNav = masterNavigationController, let coursesViewController = masterNav.viewControllers.first, viewController == coursesViewController {
            UIView.animate(withDuration: 0.2, delay: 0.27, options: .curveEaseInOut, animations: {
                self.detailNavigationController?.navigationBar.barTintColor = Brand.current.navBgColor
                self.detailNavigationController?.navigationBar.layoutIfNeeded()
                self.detailNavigationController?.viewControllers = [EmptyViewController()]
            }, completion: nil)
        }
    }
}

// Needed for the above bug mentioned in comments
extension EnrollmentSplitViewController: UIGestureRecognizerDelegate { }
