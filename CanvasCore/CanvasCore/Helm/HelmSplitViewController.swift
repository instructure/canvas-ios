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
                if #available(iOS 13, *) {
                    return firstNav.navigationBar.barStyle == .black ? .lightContent : .darkContent
                }
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
        updateTitleViews()
    }
    
    open override func showDetailViewController(_ vc: UIViewController, sender: Any?) {
        super.showDetailViewController(vc, sender: sender)
        self.masterNavigationController?.syncStyles()
    }
    
    open override func show(_ vc: UIViewController, sender: Any?) {
        super.show(vc, sender: sender)
        self.masterNavigationController?.syncStyles()
    }

    private func updateTitleViews() {
        // Recreating the titleView seems to be the most reliable way to get it to draw
        // correctly when the traitCollection changes on iPad
        if let titleView = masterTopViewController?.navigationItem.titleView as? NavigationSubtitleView {
            masterTopViewController?.navigationItem.titleView = titleView.recreate()
        }
        if let titleView = detailTopViewController?.navigationItem.titleView as? NavigationSubtitleView {
            detailTopViewController?.navigationItem.titleView = titleView.recreate()
        }
    }
}

extension NavigationSubtitleView {
    func recreate() -> NavigationSubtitleView {
        let copy = TitleSubtitleView.create()
        copy.title = titleLabel?.text
        copy.subtitle = subtitleLabel?.text
        copy.titleLabel?.textColor = titleLabel?.textColor
        copy.subtitleLabel?.textColor = subtitleLabel?.textColor
        return copy
    }
}

extension HelmSplitViewController: UISplitViewControllerDelegate {
    public func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        if svc.viewControllers.count == 2 {
            let top = (svc.viewControllers.last as? UINavigationController)?.topViewController
            top?.navigationItem.leftItemsSupplementBackButton = true
            if top?.isKind(of: EmptyViewController.self) == false {
                top?.navigationItem.leftBarButtonItem = prettyDisplayModeButtonItem(displayMode)
                NotificationCenter.default.post(name: NSNotification.Name.SplitViewControllerWillChangeDisplayModeNotification, object: nil)
            }
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
                for vc in nav.viewControllers {
                    vc.navigationItem.leftBarButtonItem = nil
                }
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
                newDeets = HelmNavigationController(rootViewController: newDeets)
            }

            let viewControllers = (newDeets as? UINavigationController)?.viewControllers ?? [newDeets]
            for vc in viewControllers {
                vc.navigationItem.leftItemsSupplementBackButton = true
                vc.navigationItem.leftBarButtonItem = prettyDisplayModeButtonItem(splitViewController.displayMode)
            }

            if let nav = newDeets as? UINavigationController {
                nav.syncStyles()
            }

            return newDeets
        }
        
        return nil
    }
}
