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
import Core

class StudentTabBarController: UITabBarController, SnackBarProvider {
    let snackBarViewModel = SnackBarViewModel()
    private var previousSelectedIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        viewControllers = [
            dashboardTab(),
            calendarTab(),
            todoTab(),
            notificationsTab()
        ]
        if AppEnvironment.shared.currentSession?.isFakeStudent == false {
            viewControllers?.append(inboxTab())
        }

        if OfflineModeAssembly.make().isOfflineModeEnabled() {
            selectedIndex = 0
        } else {
            let paths = [ "/", "/calendar", "/to-do", "/notifications", "/conversations" ]
            selectedIndex = AppEnvironment.shared.userDefaults?.landingPath
                .flatMap { paths.firstIndex(of: $0) } ?? 0
        }
        tabBar.useGlobalNavStyle()
        NotificationCenter.default.addObserver(self, selector: #selector(checkForPolicyChanges), name: UIApplication.didBecomeActiveNotification, object: nil)
        reportScreenView(for: selectedIndex, viewController: viewControllers![selectedIndex])
        addSnackBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkForPolicyChanges()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    /// When the app was started in light mode and turned to dark the selected color was not updated so we do a force refresh.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tabBar.useGlobalNavStyle()
    }

    func dashboardTab() -> UIViewController {
        let result: UIViewController
        let tabBarTitle: String
        let tabBarImage: UIImage
        let tabBarImageSelected: UIImage?

        if AppEnvironment.shared.k5.isK5Enabled {
            let dashboard = CoreNavigationController(rootViewController: CoreHostingController(K5DashboardView()))
            // This causes issues with hosted SwiftUI views. If appears at multiple places maybe worth disabling globally in CoreNavigationController.
            dashboard.interactivePopGestureRecognizer?.isEnabled = false
            result = dashboard

            tabBarTitle = String(localized: "Homeroom", bundle: .student, comment: "Homeroom tab title")
            tabBarImage =  .homeroomTab
            tabBarImageSelected = .homeroomTabActive
        } else {
            let dashboard = CoreHostingController(DashboardContainerView(shouldShowGroupList: true,
                                                                    showOnlyTeacherEnrollment: false))
            result = DashboardContainerViewController(rootViewController: dashboard) { CoreSplitViewController() }

            tabBarTitle = String(localized: "Dashboard", bundle: .student, comment: "dashboard page title")
            tabBarImage = .dashboardTab
            tabBarImageSelected = .dashboardTabActive
        }

        result.tabBarItem.title = tabBarTitle
        result.tabBarItem.image = tabBarImage
        result.tabBarItem.selectedImage = tabBarImageSelected
        result.tabBarItem.accessibilityIdentifier = "TabBar.dashboardTab"
        result.embedOfflineBanner()
        return result
    }

    func calendarTab() -> UIViewController {
        let split = CoreSplitViewController()

        let planner: UIViewController
        if ExperimentalFeature.rebuiltCalendar.isEnabled {
            planner = PlannerAssembly.makeNewPlannerViewController()
        } else {
            planner = CoreNavigationController(rootViewController: PlannerViewController.create())
        }

        split.viewControllers = [
            planner,
            CoreNavigationController(rootViewController: EmptyViewController())
        ]
        split.view.tintColor = Brand.shared.primary
        split.tabBarItem.title = String(localized: "Calendar", bundle: .student, comment: "Calendar page title")
        split.tabBarItem.image = .calendarTab
        split.tabBarItem.selectedImage = .calendarTabActive
        split.tabBarItem.accessibilityIdentifier = "TabBar.calendarTab"
        split.tabBarItem.makeUnavailableInOfflineMode()
        split.embedOfflineBanner()
        return split
    }

    func todoTab() -> UIViewController {
        let todo = CoreSplitViewController()
        let todoController = TodoListViewController.create()
        todo.viewControllers = [
            CoreNavigationController(rootViewController: todoController),
            CoreNavigationController(rootViewController: EmptyViewController())
        ]
        todo.tabBarItem.title = String(localized: "To Do", bundle: .student, comment: "Title of the Todo screen")
        todo.tabBarItem.image = .todoTab
        todo.tabBarItem.selectedImage = .todoTabActive
        todo.tabBarItem.accessibilityIdentifier = "TabBar.todoTab"
        todo.tabBarItem.makeUnavailableInOfflineMode()
        todo.embedOfflineBanner()
        TabBarBadgeCounts.todoItem = todo.tabBarItem
        todoController.loadViewIfNeeded() // start fetching todos immediately
        return todo
    }

    func notificationsTab() -> UIViewController {
        let split = CoreSplitViewController()
        split.viewControllers = [
            CoreNavigationController(rootViewController: ActivityStreamViewController.create()),
            CoreNavigationController(rootViewController: EmptyViewController())
        ]
        split.tabBarItem.title = String(localized: "Notifications", bundle: .student, comment: "Notifications tab title")
        split.tabBarItem.image = .alertsTab
        split.tabBarItem.selectedImage = .alertsTabActive
        split.tabBarItem.accessibilityIdentifier = "TabBar.notificationsTab"
        split.tabBarItem.makeUnavailableInOfflineMode()
        split.embedOfflineBanner()
        return split
    }

    func inboxTab() -> UIViewController {
        let inboxController: UIViewController
        let inboxSplit = CoreSplitViewController()

        inboxController = InboxAssembly.makeInboxViewController()

        let empty = CoreNavigationController()
        empty.navigationBar.useGlobalNavStyle()

        inboxSplit.viewControllers = [inboxController, empty]
        let title = String(localized: "Inbox", bundle: .student, comment: "Inbox tab title")
        inboxSplit.tabBarItem = UITabBarItem(title: title, image: .inboxTab, selectedImage: .inboxTabActive)
        inboxSplit.tabBarItem.accessibilityIdentifier = "TabBar.inboxTab"
        inboxSplit.tabBarItem.makeUnavailableInOfflineMode()
        inboxSplit.extendedLayoutIncludesOpaqueBars = true
        inboxSplit.embedOfflineBanner()
        TabBarBadgeCounts.messageItem = inboxSplit.tabBarItem

        return inboxSplit
    }

    private func reportScreenView(for tabIndex: Int, viewController: UIViewController) {
        let map = [AppEnvironment.shared.k5.isK5Enabled ? "homeroom": "dashboard", "calendar", "todo", "notifications", "conversations"]
        let event = map[tabIndex]
        RemoteLogger.shared.logBreadcrumb(route: "/tabs/" + event, viewController: viewController)
    }

    @objc private func checkForPolicyChanges() {
        LoginUsePolicy.checkAcceptablePolicy(from: self, cancelled: {
            AppEnvironment.shared.loginDelegate?.changeUser()
        })
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
