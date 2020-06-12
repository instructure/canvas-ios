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

public func inboxTab() -> UIViewController {
    let inboxVC: UIViewController
    let inboxNav: UINavigationController
    let inboxSplit = HelmSplitViewController()

    if ExperimentalFeature.nativeStudentInbox.isEnabled || ExperimentalFeature.nativeTeacherInbox.isEnabled {
        inboxVC = ConversationsViewController.create()
        inboxNav = UINavigationController(rootViewController: inboxVC)
    } else {
        inboxVC = HelmViewController(moduleName: "/conversations", props: [:])
        inboxNav = HelmNavigationController(rootViewController: inboxVC)
    }

    inboxNav.navigationBar.useGlobalNavStyle()
    inboxVC.navigationItem.titleView = Core.Brand.shared.headerImageView()

    let empty = HelmNavigationController()
    empty.navigationBar.useGlobalNavStyle()

    inboxSplit.viewControllers = [inboxNav, empty]
    let title = NSLocalizedString("Inbox", bundle: .core, comment: "Inbox tab title")
    inboxSplit.tabBarItem = UITabBarItem(title: title, image: .icon(.inboxTab), selectedImage: .icon(.inboxTabActive))
    inboxSplit.tabBarItem.accessibilityIdentifier = "TabBar.inboxTab"
    inboxSplit.extendedLayoutIncludesOpaqueBars = true
    TabBarBadgeCounts.messageItem = inboxSplit.tabBarItem
    
    return inboxSplit
}
