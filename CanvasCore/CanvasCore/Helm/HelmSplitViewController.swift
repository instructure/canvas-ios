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

public class HelmSplitViewController: UISplitViewController {

    public override init(nibName: String? = nil, bundle: Bundle? = nil) {
        super.init(nibName: nibName, bundle: bundle)
        delegate = self
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func viewDidLoad() {
        preferredDisplayMode = .oneBesideSecondary
    }

    public override var prefersStatusBarHidden: Bool {
        return masterNavigationController?.prefersStatusBarHidden ?? false
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let notification = Notification.Name(rawValue: "HelmSplitViewControllerTraitsUpdated")
        NotificationCenter.default.post(name: notification, object: nil, userInfo: nil)
        updateTitleViews()
    }

    public override func showDetailViewController(_ vc: UIViewController, sender: Any?) {
        super.showDetailViewController(vc, sender: sender)
        self.masterNavigationController?.syncStyles()
    }

    public override func show(_ vc: UIViewController, sender: Any?) {
        super.show(vc, sender: sender)
        self.masterNavigationController?.syncStyles()
    }

    private func updateTitleViews() {
        // Recreating the titleView seems to be the most reliable way to get it to draw
        // correctly when the traitCollection changes on iPad
        if let titleView = masterTopViewController?.navigationItem.titleView as? TitleSubtitleView {
            masterTopViewController?.navigationItem.titleView = titleView.recreate()
        }
        if let titleView = detailTopViewController?.navigationItem.titleView as? TitleSubtitleView {
            detailTopViewController?.navigationItem.titleView = titleView.recreate()
        }
    }

    public func prettyDisplayModeButtonItem(_ displayMode: DisplayMode) -> UIBarButtonItem {
        let defaultButton = self.displayModeButtonItem
        let collapse = displayMode == .oneOverSecondary || displayMode == .secondaryOnly
        let icon: UIImage = collapse ? .exitFullScreenLine : .fullScreenLine
        let prettyButton = UIBarButtonItem(image: icon, style: .plain, target: defaultButton.target, action: defaultButton.action)
        prettyButton.accessibilityLabel = collapse ?
            NSLocalizedString("Collapse detail view", bundle: .canvas, comment: "") :
            NSLocalizedString("Expand detail view", bundle: .canvas, comment: "")
        return prettyButton
    }
}

extension HelmSplitViewController: UISplitViewControllerDelegate {
    public func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        if svc.viewControllers.count == 2 {
            let top = (svc.viewControllers.last as? UINavigationController)?.topViewController
            top?.navigationItem.leftItemsSupplementBackButton = true
            if top?.isKind(of: EmptyViewController.self) == false {
                top?.navigationItem.leftBarButtonItem = prettyDisplayModeButtonItem(displayMode)
                NotificationCenter.default.post(name: NSNotification.Name.SplitViewControllerWillChangeDisplayModeNotification, object: self)
            }
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
                for vc in nav.viewControllers {
                    vc.navigationItem.leftBarButtonItem = nil
                }
            }
        }
        
        return false
    }
    
    public func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {

        // Setup default detail view provided by the master view controller
        if let nav = primaryViewController as? UINavigationController,
           nav.viewControllers.count > 1,
           let defaultViewProvider = nav.viewControllers.last as? DefaultViewProvider,
           let defaultRoute = defaultViewProvider.defaultViewRoute,
           let defaultViewController = AppEnvironment.shared.router.match(defaultRoute, userInfo: nil)
        {
            let detailNavController = HelmNavigationController(rootViewController: defaultViewController)
            detailNavController.syncStyles(from: nav, to: detailNavController)

            if let routeTemplate = AppEnvironment.shared.router.template(for: defaultRoute) {
                Analytics.shared.logScreenView(route: routeTemplate, viewController: defaultViewController)
            }

            return detailNavController
        }

        // Default behaviour of putting the current top viewcontroller into a nav controller and moving it to the detail view
        if let nav = primaryViewController as? UINavigationController, nav.viewControllers.count >= 2 {
            var newDeets = nav.viewControllers[nav.viewControllers.count - 1]
            nav.popViewController(animated: true)

            if let helmVC = newDeets as? HelmViewController {
                if HelmManager.shared.masterModules.contains(helmVC.moduleName) {
                    newDeets = UINavigationController(rootViewController: EmptyViewController())
                }
            }

            if !(newDeets is UINavigationController) {
                newDeets = HelmNavigationController(rootViewController: newDeets)
            }

            let viewControllers = (newDeets as? UINavigationController)?.viewControllers ?? [newDeets]
            for vc in viewControllers {
                vc.navigationItem.leftItemsSupplementBackButton = true
                vc.navigationItem.leftBarButtonItem = prettyDisplayModeButtonItem(splitViewController.displayMode)
            }

            if let nav = newDeets as? UINavigationController {
                // If newDeets is a newly created navigation controller then it won't have a splitViewController yet, so syncStyles() won't work at this point.
                if newDeets.splitViewController == nil, let masterNav = primaryViewController as? UINavigationController {
                    nav.syncStyles(from: masterNav, to: nav)
                } else {
                    nav.syncStyles()
                }
            }

            return newDeets
        }
        
        return nil
    }
}

// - MARK: Master Navigation Controller Transition Actions

extension HelmSplitViewController: UINavigationControllerDelegate {

    /**
     This method gets called only when a real transition occurs. UINavigationControllerDelegate.willShow/didShow also
     gets called when the navigation controller is removed from the screen and re-added for example on a tab bar change
     event so we can't use those to determine when a view controller is pushed for the first time.
     */
    open func navigationController(_ navigationController: UINavigationController,
                                   animationControllerFor operation: UINavigationController.Operation,
                                   from fromVC: UIViewController,
                                   to toVC: UIViewController)
    -> UIViewControllerAnimatedTransitioning? {
        toVC.showDefaultDetailViewIfNeeded()
        return nil
    }
}

// Needed for the above bug mentioned in comments
extension HelmSplitViewController: UIGestureRecognizerDelegate { }
