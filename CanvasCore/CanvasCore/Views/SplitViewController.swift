//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit

open class SplitViewController: UISplitViewController {
    public var shouldCollapseDetail: Bool = true

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
}

extension SplitViewController: UISplitViewControllerDelegate {
    public func targetDisplayModeForAction(in svc: UISplitViewController) -> UISplitViewControllerDisplayMode {
        if svc.displayMode == .primaryOverlay || svc.displayMode == .primaryHidden {
            if let nav = svc.viewControllers.last as? UINavigationController {
                nav.topViewController?.navigationItem.leftBarButtonItem = prettyDisplayModeButtonItem
            }
            return .allVisible;
        } else {
            if let nav = svc.viewControllers.last as? UINavigationController {
                nav.topViewController?.navigationItem.leftBarButtonItem = prettyDisplayModeButtonItem
            }
            return .primaryHidden;
        }
    }

    public func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        // Returns true, cuz on iPad we don't use overlay types (so far). It's either hidden or all. If that changes, change this and logic in EnrollmentsTab to handle everything correctly
        return shouldCollapseDetail
    }
}

extension UISplitViewController {
    open var prettyDisplayModeButtonItem: UIBarButtonItem {
        let defaultButton = self.displayModeButtonItem
        let icon: UIImage
        if displayMode == .primaryOverlay || displayMode == .primaryHidden {
            icon = .icon(.collapse)
        } else {
            icon = .icon(.expand)
        }
        let prettyButton = UIBarButtonItem(image: icon, style: .plain, target: defaultButton.target, action: defaultButton.action)
        return prettyButton
    }
}
