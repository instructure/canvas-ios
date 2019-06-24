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
    
    

import Foundation
import UIKit
import ReactiveSwift
import Kingfisher
import TechDebt
import CanvasCore
import Core

func rootViewController(_ session: Session) -> UIViewController {
    let tabs = CanvasTabBarController()
    
    do {
        tabs.viewControllers = [
            dashboardTab(session: session),
            UINavigationController(rootViewController: CalendarTabViewController(session: session) { vc, url in
                Router.shared().route(from: vc, to: url)
            }),
            try ToDoTabViewController(session: session) { vc, url in
                Router.shared().route(from: vc, to: url)
            },
            try NotificationsTab(session: session),
            inboxTab()
        ]
    } catch let e as NSError {
        delay(0.1) {
            ErrorReporter.reportError(e, from: tabs)
        }
    }
    
    let selectedTab = UserPreferences.landingPage(session.user.id)
    tabs.selectedIndex = selectedTab.tabIndex
    tabs.tabBar.useGlobalNavStyle()
    return tabs
}

func dashboardTab(session: Session) -> UIViewController {
    let dashboardVC = HelmViewController(moduleName: "/", props: [:])
    let dashboardNav = HelmNavigationController(rootViewController: dashboardVC)
    let dashboardSplit = EnrollmentSplitViewController()
    let emptyNav = UINavigationController(rootViewController:EmptyViewController())
    emptyNav.navigationBar.useGlobalNavStyle()
    dashboardNav.delegate = dashboardSplit
    dashboardNav.navigationBar.useGlobalNavStyle()
    dashboardSplit.viewControllers = [dashboardNav, emptyNav]
    dashboardSplit.tabBarItem.title = NSLocalizedString("Dashboard", comment: "dashboard page title")
    dashboardSplit.tabBarItem.image = .icon(.dashboard, .line)
    dashboardSplit.tabBarItem.selectedImage = .icon(.dashboardCustomSolid)
    dashboardSplit.tabBarItem.accessibilityIdentifier = "TabBar.dashboardTab"
    dashboardSplit.navigationItem.titleView = Brand.current.navBarTitleView()
    return dashboardSplit
}
