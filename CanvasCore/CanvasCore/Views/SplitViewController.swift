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

open class SplitViewController: UISplitViewController {
    @objc public var shouldCollapseDetail: Bool = true

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
    
    open override func showDetailViewController(_ vc: UIViewController, sender: Any?) {
        super.showDetailViewController(vc, sender: sender)
        self.masterNavigationController?.syncStyles()
    }
    
    open override func show(_ vc: UIViewController, sender: Any?) {
        super.show(vc, sender: sender)
        self.masterNavigationController?.syncStyles()
    }
}

extension SplitViewController: UISplitViewControllerDelegate {
    public func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        if svc.viewControllers.count == 2 {
            let top = (svc.viewControllers.last as? UINavigationController)?.topViewController
            top?.navigationItem.leftItemsSupplementBackButton = true
            if top?.isKind(of: EmptyViewController.self) == false {
                top?.navigationItem.leftBarButtonItem = prettyDisplayModeButtonItem(displayMode)
            }
        }
    }

    public func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        // Returns true, cuz on iPad we don't use overlay types (so far). It's either hidden or all. If that changes, change this and logic in EnrollmentsTab to handle everything correctly
        return shouldCollapseDetail
    }
}

extension UISplitViewController {
    @objc open func prettyDisplayModeButtonItem(_ displayMode: DisplayMode) -> UIBarButtonItem {
        let defaultButton = self.displayModeButtonItem
        let collapse = displayMode == .primaryOverlay || displayMode == .primaryHidden
        let icon: UIImage = collapse ? .icon(.collapse) : .icon(.expand)
        let prettyButton = UIBarButtonItem(image: icon, style: .plain, target: defaultButton.target, action: defaultButton.action)
        prettyButton.accessibilityLabel = collapse ? NSLocalizedString("Collapse", comment: "") : NSLocalizedString("Expand", comment: "")
        return prettyButton
    }
}
