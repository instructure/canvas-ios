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

public class EnrollmentSplitViewController: HelmSplitViewController {
}

extension EnrollmentSplitViewController: UINavigationControllerDelegate {    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let masterNav = masterNavigationController, let detailNav = detailNavigationController, let coursesViewController = masterNav.viewControllers.first, toVC == coursesViewController, operation == .pop {
            // When navigating back to all courses list, detail view should show empty vc
            detailNav.navigationItem.leftBarButtonItem = nil
            detailNav.setViewControllers([EmptyViewController()], animated: false)
        }
        return nil
    }
}

// Needed for the above bug mentioned in comments
extension EnrollmentSplitViewController: UIGestureRecognizerDelegate { }
