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
import Core

public class EnrollmentSplitViewController: HelmSplitViewController {
}

extension EnrollmentSplitViewController: UINavigationControllerDelegate {    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
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
