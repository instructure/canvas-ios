//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import Foundation
import UIKit
import CanvasCore
import Core

func rootViewController(_ session: Session) -> UIViewController {
    let tabs = CanvasTabBarController()
    tabs.viewControllers = [
        dashboardTab(session: session),
        calendarTab(session: session),
        todoTab(),
        notificationsTab(),
    ]
    if AppEnvironment.shared.currentSession?.isFakeStudent == false {
        tabs.viewControllers?.append(inboxTab())
    }

    let paths = [ "/", "/calendar", "/to-do", "/notifications", "/conversations" ]
    tabs.selectedIndex = AppEnvironment.shared.userDefaults?.landingPath
        .flatMap { paths.firstIndex(of: $0) } ?? 0
    tabs.tabBar.useGlobalNavStyle()
    return tabs
}

func dashboardTab(session: Session) -> UIViewController {
    let dashboardVC = HelmViewController(moduleName: "/", props: [:])
    let dashboardNav = HelmNavigationController(rootViewController: dashboardVC)
    let dashboardSplit = EnrollmentSplitViewController()
    let emptyNav = UINavigationController(rootViewController: EmptyViewController())
    dashboardNav.delegate = dashboardSplit
    dashboardNav.navigationBar.useGlobalNavStyle()
    dashboardSplit.viewControllers = [dashboardNav, emptyNav]
    dashboardSplit.tabBarItem.title = NSLocalizedString("Dashboard", comment: "dashboard page title")
    dashboardSplit.tabBarItem.image = .icon(.dashboardTab)
    dashboardSplit.tabBarItem.selectedImage = .icon(.dashboardTabActive)
    dashboardSplit.tabBarItem.accessibilityIdentifier = "TabBar.dashboardTab"
    dashboardSplit.navigationItem.titleView = Brand.shared.headerImageView()
    return dashboardSplit
}

func calendarTab(session: Session) -> UIViewController {
    let split = HelmSplitViewController()
    split.viewControllers = [
        UINavigationController(rootViewController: PlannerViewController.create()),
        UINavigationController(rootViewController: EmptyViewController()),
    ]
    split.view.tintColor = Brand.shared.primary.ensureContrast(against: .named(.backgroundLightest))
    split.tabBarItem.title = NSLocalizedString("Calendar", comment: "Calendar page title")
    split.tabBarItem.image = .icon(.calendarTab)
    split.tabBarItem.selectedImage = .icon(.calendarTabActive)
    split.tabBarItem.accessibilityIdentifier = "TabBar.calendarTab"
    return split
}

func todoTab() -> UIViewController {
    let todo = HelmSplitViewController()
    todo.viewControllers = [
        UINavigationController(rootViewController: TodoListViewController.create()),
        UINavigationController(rootViewController: EmptyViewController()),
    ]
    todo.tabBarItem.title = NSLocalizedString("To Do", comment: "Title of the Todo screen")
    todo.tabBarItem.image = .icon(.todoTab)
    todo.tabBarItem.selectedImage = .icon(.todoTabActive)
    todo.tabBarItem.accessibilityIdentifier = "TabBar.todoTab"
    return todo
}

func notificationsTab() -> UIViewController {
    let split = HelmSplitViewController()
    split.viewControllers = [
        UINavigationController(rootViewController: ActivityStreamViewController.create()),
        UINavigationController(rootViewController: EmptyViewController()),
    ]
    split.tabBarItem.title = NSLocalizedString("Notifications", comment: "Notifications tab title")
    split.tabBarItem.image = .icon(.alertsTab)
    split.tabBarItem.selectedImage = .icon(.alertsTabActive)
    split.tabBarItem.accessibilityIdentifier = "TabBar.notificationsTab"
    return split
}
