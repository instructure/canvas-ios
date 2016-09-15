//
//  UINavigationController+Parent.swift
//  Parent
//
//  Created by Ben Kraus on 3/28/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

extension UINavigationController {
    class func coloredTriangleNavigationController(withRootViewController viewController: UIViewController, forObservee observeeID: String? = nil) -> UINavigationController {
        let navController = UINavigationController(navigationBarClass: TriangleGradientNavigationBar.classForCoder(), toolbarClass: UIToolbar.classForCoder())

        if let observeeID = observeeID, triangleGradientNavBar = navController.navigationBar as? TriangleGradientNavigationBar {
            let scheme = ColorCoordinator.colorSchemeForStudentID(observeeID.stringValue)
            triangleGradientNavBar.transitionToColors(scheme.tintTopColor, bottomTintColor: scheme.tintBottomColor)
        }

        navController.viewControllers = [viewController]

        return navController
    }
}
