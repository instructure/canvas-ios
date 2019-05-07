//
// Copyright (C) 2017-present Instructure, Inc.
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
import ReactiveSwift
import ReactiveCocoa

public func inboxTab() -> UIViewController {
    let inboxVC = HelmViewController(moduleName: "/conversations", props: [:])
    let inboxNav = HelmNavigationController(rootViewController: inboxVC)
    
    inboxNav.applyDefaultBranding()
    inboxVC.navigationItem.titleView = Brand.current.navBarTitleView()
    
    let inboxSplit = HelmSplitViewController()
    
    let empty = HelmNavigationController()
    empty.applyDefaultBranding()
    
    inboxSplit.viewControllers = [inboxNav, empty]
    let title = NSLocalizedString("Inbox", bundle: .core, comment: "Inbox tab title")
    inboxSplit.tabBarItem = UITabBarItem(title: title, image: .icon(.email), selectedImage: nil)
    inboxSplit.tabBarItem.accessibilityIdentifier = "tab-bar.inbox-btn"
    inboxSplit.extendedLayoutIncludesOpaqueBars = true
    
    inboxSplit.tabBarItem.reactive.badgeValue <~ TabBarBadgeCounts.unreadMessageCountString
    
    return inboxSplit
}
