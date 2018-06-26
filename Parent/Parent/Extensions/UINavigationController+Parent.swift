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

extension UINavigationController {
    class func parentNavigationController(withRootViewController viewController: UIViewController, forObservee observeeID: String? = nil) -> UINavigationController {
        let navController = UINavigationController(rootViewController: viewController)
        
        navController.navigationBar.tintColor = UIColor.white
        navController.navigationBar.isTranslucent = false
        navController.navigationBar.barStyle = UIBarStyle.black
        navController.navigationBar.shadowImage = UIImage()

        if let observeeID = observeeID {
            let scheme = ColorCoordinator.colorSchemeForStudentID(observeeID.stringValue)
            navController.navigationBar.barTintColor = scheme.mainColor
        }

        navController.viewControllers = [viewController]

        return navController
    }
}
