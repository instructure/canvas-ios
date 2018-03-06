//
//  UITabBarController+Core.swift
//  CanvasCore
//
//  Created by Layne Moseley on 3/5/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import Foundation

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
            let masterNav = splitViewController.viewControllers.first as? UINavigationController {
            masterNav.dismiss(animated: false, completion: nil)
            if (splitViewController.displayMode == .allVisible) {
                masterNav.popToRootViewController(animated: true)
            } else {
                // I was unable to get this to animate nicely, there were some weird side effects.
                // Seemed resonable to punt on animations and just make it work
                masterNav.popToRootViewController(animated: false)
                splitViewController.preferredDisplayMode = .allVisible
            }
        }
    }
    
    public func resetSelectedViewController() {
        guard let selected = selectedViewController else { return }
        resetViewControllerIfSelected(selected)
    }
}
