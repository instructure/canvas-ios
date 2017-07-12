//
//  HelmSplitViewController.swift
//  Teacher
//
//  Created by Garrett Richards on 5/2/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit

class HelmSplitViewControllerWrapper: UIViewController {
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return childViewControllers.first
    }
    
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return childViewControllers.first
    }
}

class HelmSplitViewController: UISplitViewController {

    public init() {
        super.init(nibName: nil, bundle: nil)
        delegate = self
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        if let firstNav = viewControllers.first as? UINavigationController {
            return firstNav.navigationBar.barStyle == .black ? .lightContent : .default
        } else {
            return viewControllers.first!.preferredStatusBarStyle
        }
    }
    
    override open var prefersStatusBarHidden: Bool {
        return viewControllers.first?.prefersStatusBarHidden ?? false
    }
}

extension HelmSplitViewController: UISplitViewControllerDelegate {
    public func targetDisplayModeForAction(in svc: UISplitViewController) -> UISplitViewControllerDisplayMode {
        if svc.displayMode == .primaryOverlay || svc.displayMode == .primaryHidden {
            if let nav = svc.viewControllers.last as? UINavigationController {
                nav.topViewController?.navigationItem.leftBarButtonItem = prettyDisplayModeButtonItem
                nav.topViewController?.navigationItem.leftItemsSupplementBackButton = true
            }
            return .allVisible;
        } else {
            if let nav = svc.viewControllers.last as? UINavigationController {
                nav.topViewController?.navigationItem.leftBarButtonItem = prettyDisplayModeButtonItem
                nav.topViewController?.navigationItem.leftItemsSupplementBackButton = true
            }
            return .primaryHidden;
        }
    }

    public func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if let nav = secondaryViewController as? UINavigationController {
            if let _ = nav.topViewController as? EmptyViewController {
                return true
            } else if let helmVC = nav.topViewController as? HelmViewController, helmVC.moduleName.contains("placeholder") {
                return true
            } else {
                // Remove the display mode button item
                nav.topViewController?.navigationItem.leftBarButtonItem = nil
            }
        }
        
        return false
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        if let nav = primaryViewController as? UINavigationController, nav.viewControllers.count >= 2 {
            var newDeets = nav.viewControllers[nav.viewControllers.count - 1]
            nav.popViewController(animated: true)
            
            if let helmVC = newDeets as? HelmViewController {
                if HelmManager.shared.masterModules.contains(helmVC.moduleName) {
                    newDeets = UINavigationController(rootViewController: EmptyViewController())
                }
            }
            
            if !(newDeets is UINavigationController) {
                let nav = HelmNavigationController(rootViewController: newDeets)
                return nav
            }
            
            return newDeets
        }
        
        return nil
    }
}

extension UISplitViewController {
    open var prettyDisplayModeButtonItem: UIBarButtonItem {
        let defaultButton = self.displayModeButtonItem
        let icon: UIImage
        if displayMode == .primaryOverlay || displayMode == .primaryHidden {
            icon = UIImage(named: "collapse")!
        } else {
            icon = UIImage(named: "expand")!
        }
        let prettyButton = UIBarButtonItem(image: icon, style: .plain, target: defaultButton.target, action: defaultButton.action)
        return prettyButton
    }
}
