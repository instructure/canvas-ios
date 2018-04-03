//
//  inboxTab.swift
//  CanvasCore
//
//  Created by Derrick Hathaway on 10/3/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
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
    let icon = UIImage.icon(.email)
    inboxSplit.tabBarItem = UITabBarItem(title: NSLocalizedString("Inbox", tableName: "Localizable", bundle: .core, value: "Inbox", comment: "Inbox tab title"), image: icon, selectedImage: nil)
    inboxSplit.tabBarItem.accessibilityIdentifier = "tab-bar.inbox-btn"
    inboxSplit.extendedLayoutIncludesOpaqueBars = true
    
    inboxSplit.tabBarItem.reactive.badgeValue <~ TabBarBadgeCounts.unreadMessageCountString
    
    return inboxSplit
}
