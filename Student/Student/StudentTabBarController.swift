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

import UIKit
import CanvasCore
import Core

class StudentTabBarController: UITabBarController {
    private var previousSelectedIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        viewControllers = [
            dashboardTab(),
            calendarTab(),
            todoTab(),
            notificationsTab(),
        ]
        if AppEnvironment.shared.currentSession?.isFakeStudent == false {
            viewControllers?.append(inboxTab())
        }

        let paths = [ "/", "/calendar", "/to-do", "/notifications", "/conversations" ]
        selectedIndex = AppEnvironment.shared.userDefaults?.landingPath
            .flatMap { paths.firstIndex(of: $0) } ?? 0
        tabBar.useGlobalNavStyle()

        reportScreenView(for: selectedIndex, viewController: viewControllers![selectedIndex])
    }

    func dashboardTab() -> UIViewController {
        let result: UIViewController
        let tabBarTitle: String
        let tabBarImage: UIImage
        let tabBarImageSelected: UIImage?

        if AppEnvironment.shared.k5.isK5Enabled {
            let dashboard = HelmNavigationController(rootViewController: CoreHostingController(K5DashboardView()))
            // This causes issues with hosted SwiftUI views. If appears at multiple places maybe worth disabling globally in HelmNavigationController.
            dashboard.interactivePopGestureRecognizer?.isEnabled = false
            result = dashboard

            tabBarTitle = NSLocalizedString("Homeroom", comment: "Homeroom tab title")
            tabBarImage =  .homeroomTab
            tabBarImageSelected = .homeroomTabActive
        } else {
            let split = HelmSplitViewController()
            split.preferredDisplayMode = .oneBesideSecondary
            split.viewControllers = [
                HelmNavigationController(rootViewController: CoreHostingController(DashboardCardView(shouldShowGroupList: true, showOnlyTeacherEnrollment: false))),
                HelmNavigationController(rootViewController: EmptyViewController()),
            ]
            split.masterNavigationController?.delegate = split
            result = split

            tabBarTitle = NSLocalizedString("Dashboard", comment: "dashboard page title")
            tabBarImage = .dashboardTab
            tabBarImageSelected = .dashboardTabActive
        }

        result.tabBarItem.title = tabBarTitle
        result.tabBarItem.image = tabBarImage
        result.tabBarItem.selectedImage = tabBarImageSelected
        result.tabBarItem.accessibilityIdentifier = "TabBar.dashboardTab"
        return result
    }

    func calendarTab() -> UIViewController {
        let split = HelmSplitViewController()
        split.viewControllers = [
            HelmNavigationController(rootViewController: PlannerViewController.create()),
            HelmNavigationController(rootViewController: EmptyViewController()),
        ]
        split.view.tintColor = Brand.shared.primary.ensureContrast(against: .backgroundLightest)
        split.tabBarItem.title = NSLocalizedString("Calendar", comment: "Calendar page title")
        split.tabBarItem.image = .calendarTab
        split.tabBarItem.selectedImage = .calendarTabActive
        split.tabBarItem.accessibilityIdentifier = "TabBar.calendarTab"
        return split
    }

    func todoTab() -> UIViewController {
        let todo = HelmSplitViewController()
        let todoController = TodoListViewController.create()
        todo.viewControllers = [
            HelmNavigationController(rootViewController: todoController),
            HelmNavigationController(rootViewController: EmptyViewController()),
        ]
        todo.tabBarItem.title = NSLocalizedString("To Do", comment: "Title of the Todo screen")
        todo.tabBarItem.image = .todoTab
        todo.tabBarItem.selectedImage = .todoTabActive
        todo.tabBarItem.accessibilityIdentifier = "TabBar.todoTab"
        TabBarBadgeCounts.todoItem = todo.tabBarItem
        todoController.loadViewIfNeeded() // start fetching todos immediately
        return todo
    }

    func notificationsTab() -> UIViewController {
        let split = HelmSplitViewController()
        split.viewControllers = [
            HelmNavigationController(rootViewController: ActivityStreamViewController.create()),
            HelmNavigationController(rootViewController: EmptyViewController()),
        ]
        split.tabBarItem.title = NSLocalizedString("Notifications", comment: "Notifications tab title")
        split.tabBarItem.image = .alertsTab
        split.tabBarItem.selectedImage = .alertsTabActive
        split.tabBarItem.accessibilityIdentifier = "TabBar.notificationsTab"
        return split
    }

    func inboxTab() -> UIViewController {
        let inboxVC: UIViewController
        let inboxNav: UINavigationController
        let inboxSplit = HelmSplitViewController()

        if ExperimentalFeature.nativeStudentInbox.isEnabled || ExperimentalFeature.nativeTeacherInbox.isEnabled {
            inboxVC = CoreHostingController(InboxView())
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
        let title = NSLocalizedString("Inbox", comment: "Inbox tab title")
        inboxSplit.tabBarItem = UITabBarItem(title: title, image: .inboxTab, selectedImage: .inboxTabActive)
        inboxSplit.tabBarItem.accessibilityIdentifier = "TabBar.inboxTab"
        inboxSplit.extendedLayoutIncludesOpaqueBars = true
        TabBarBadgeCounts.messageItem = inboxSplit.tabBarItem

        return inboxSplit
    }

    private func reportScreenView(for tabIndex: Int, viewController: UIViewController) {
        let map = [AppEnvironment.shared.k5.isK5Enabled ? "homeroom": "dashboard", "calendar", "todo", "notifications", "conversations"]
        let event = map[tabIndex]
        Analytics.shared.logScreenView(route: "/tabs/" + event, viewController: viewController)
    }
}

extension StudentTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        tabBarController.resetViewControllerIfSelected(viewController)

        if let index = viewControllers?.firstIndex(of: viewController), selectedViewController != viewController {
            reportScreenView(for: index, viewController: viewController)
        }

        return true
    }
}
