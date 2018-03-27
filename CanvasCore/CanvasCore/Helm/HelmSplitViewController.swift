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

open class HelmSplitViewController: UISplitViewController {

    public init() {
        super.init(nibName: nil, bundle: nil)
        delegate = self
        preferredDisplayMode = .allVisible
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        preferredDisplayMode = .allVisible
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        if let firstNav = viewControllers.first as? UINavigationController {
            if let presented = firstNav.presentedViewController, presented.isBeingDismissed == false {
                return presented.preferredStatusBarStyle
            } else {
                return firstNav.navigationBar.barStyle == .black ? .lightContent : .default
            }
        } else {
            guard let first = viewControllers.first else { return .default }
            return first.preferredStatusBarStyle
        }
    }
    
    override open var prefersStatusBarHidden: Bool {
        return viewControllers.first?.prefersStatusBarHidden ?? false
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let notification = Notification.Name(rawValue: "HelmSplitViewControllerTraitsUpdated")
        NotificationCenter.default.post(name: notification, object: nil, userInfo: nil)
    }
    
    open override func showDetailViewController(_ vc: UIViewController, sender: Any?) {
        super.showDetailViewController(vc, sender: sender)
        self.masterNavigationController?.syncStyles()
    }
    
    open override func show(_ vc: UIViewController, sender: Any?) {
        super.show(vc, sender: sender)
        self.masterNavigationController?.syncStyles()
    }
}

extension HelmSplitViewController: UISplitViewControllerDelegate {
    open func targetDisplayModeForAction(in svc: UISplitViewController) -> UISplitViewControllerDisplayMode {
        if svc.displayMode == .primaryOverlay || svc.displayMode == .primaryHidden {
            if let nav = svc.viewControllers.last as? UINavigationController {
                nav.topViewController?.navigationItem.leftBarButtonItem = prettyDisplayModeButtonItem
                nav.topViewController?.navigationItem.leftItemsSupplementBackButton = true
            }
            return .allVisible;
        } else {
            if let nav = svc.viewControllers.last as? UINavigationController, let top = nav.topViewController, !top.isKind(of: EmptyViewController.self) {
                nav.topViewController?.navigationItem.leftBarButtonItem = prettyDisplayModeButtonItem
                nav.topViewController?.navigationItem.leftItemsSupplementBackButton = true
            }
            return .primaryHidden;
        }
    }

    open func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
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
    
    open func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
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

