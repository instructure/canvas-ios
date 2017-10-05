//
//  inboxTab.swift
//  CanvasCore
//
//  Created by Derrick Hathaway on 10/3/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

import UIKit

public func inboxTab(branding: Brand?) -> UIViewController {
    let inboxVC = HelmViewController(moduleName: "/conversations", props: [:])
    let inboxNav = HelmNavigationController(rootViewController: inboxVC)
    
    let inboxSplit = HelmSplitViewController()
    let empty = HelmNavigationController()
    if let brand = branding {
        empty.navigationBar.barTintColor = brand.navBgColor
        empty.navigationBar.tintColor = brand.navButtonColor
        empty.navigationBar.isTranslucent = false
    }
    inboxSplit.viewControllers = [inboxNav, empty]
    let icon = UIImage(named: "inbox", in: .core, compatibleWith: nil)
    inboxSplit.tabBarItem = UITabBarItem(title: NSLocalizedString("Inbox", comment: ""), image: icon, selectedImage: nil)
    inboxSplit.tabBarItem.accessibilityIdentifier = "tab-bar.inbox-btn"
    inboxSplit.extendedLayoutIncludesOpaqueBars = true
    return inboxSplit
}
