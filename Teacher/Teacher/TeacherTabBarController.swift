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
import UserNotifications

class TeacherTabBarController: UITabBarController, SnackBarProvider {
    let snackBarViewModel = SnackBarViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        viewControllers = [coursesTab(), calendarTab(), toDoTab(), inboxTab()]
        let paths = [ "/", "/calendar", "/to-do", "/conversations" ]
        selectedIndex = AppEnvironment.shared.userDefaults?.landingPath.flatMap {
            paths.firstIndex(of: $0)
        } ?? 0
        tabBar.useGlobalNavStyle()
        NotificationCenter.default.addObserver(self, selector: #selector(checkForPolicyChanges), name: UIApplication.didBecomeActiveNotification, object: nil)
        reportScreenView(for: selectedIndex, viewController: viewControllers![selectedIndex])
        addSnackBar()
        registerForTraitChanges()
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
    private func registerForTraitChanges() {
        let traits = [UITraitUserInterfaceStyle.self]
        registerForTraitChanges(traits) { (controller: TeacherTabBarController, _) in
            controller.tabBar.useGlobalNavStyle()

            // This changes the elevated tab bar's text color (but for some reason only in light mode)
            controller.view.tintColor = Brand.shared.tabBarHighlightColor
        }
    }

    func coursesTab() -> UIViewController {
        let cardView = CoreHostingController(DashboardContainerView(shouldShowGroupList: false,
                                                               showOnlyTeacherEnrollment: true))
        let dashboard = DashboardContainerViewController(rootViewController: cardView) { CoreSplitViewController() }
        dashboard.tabBarItem.title = String(localized: "Courses", bundle: .teacher)
        dashboard.tabBarItem.image = .coursesTab
        dashboard.tabBarItem.selectedImage = .coursesTabActive
        dashboard.tabBarItem.accessibilityIdentifier = "TabBar.dashboardTab"
        return dashboard
    }

    func calendarTab() -> UIViewController {
        let split = CoreSplitViewController()
        split.viewControllers = [
            CoreNavigationController(rootViewController: PlannerViewController.create()),
            CoreNavigationController(rootViewController: EmptyViewController())
        ]
        split.view.tintColor = Brand.shared.primary
        split.tabBarItem.title = String(localized: "Calendar", bundle: .teacher, comment: "Calendar page title")
        split.tabBarItem.image = .calendarTab
        split.tabBarItem.selectedImage = .calendarTabActive
        split.tabBarItem.accessibilityIdentifier = "TabBar.calendarTab"
        split.tabBarItem.makeUnavailableInOfflineMode()
        split.embedOfflineBanner()
        return split
    }

    func toDoTab() -> UIViewController {
        let todo = CoreNavigationController(rootViewController: TodoListViewController.create())
        todo.tabBarItem.title = String(localized: "To Do", bundle: .teacher)
        todo.tabBarItem.image = .todoTab
        todo.tabBarItem.selectedImage = .todoTabActive
        todo.tabBarItem.accessibilityIdentifier = "TabBar.todoTab"
        TabBarBadgeCounts.todoItem = todo.tabBarItem
        todo.viewControllers.first?.loadViewIfNeeded() // start fetching todos immediately
        return todo
    }

    func inboxTab() -> UIViewController {
        let inboxController: UIViewController
        let inboxSplit = CoreSplitViewController()

        inboxController = InboxAssembly.makeInboxViewController()

        let empty = CoreNavigationController()
        empty.navigationBar.useGlobalNavStyle()

        inboxSplit.viewControllers = [inboxController, empty]
        let title = String(localized: "Inbox", bundle: .teacher, comment: "Inbox tab title")
        inboxSplit.tabBarItem = UITabBarItem(title: title, image: .inboxTab, selectedImage: .inboxTabActive)
        inboxSplit.tabBarItem.accessibilityIdentifier = "TabBar.inboxTab"
        inboxSplit.extendedLayoutIncludesOpaqueBars = true
        TabBarBadgeCounts.messageItem = inboxSplit.tabBarItem

        return inboxSplit
    }

    private func reportScreenView(for tabIndex: Int, viewController: UIViewController) {
        let map = ["dashboard", "calendar", "todo", "conversations"]
        let event = map[tabIndex]
        RemoteLogger.shared.logBreadcrumb(route: "/tabs/" + event, viewController: viewController)
    }

    @objc private func checkForPolicyChanges() {
        LoginUsePolicy.checkAcceptablePolicy(from: self, cancelled: {
            AppEnvironment.shared.loginDelegate?.changeUser()
        })
    }
}

extension TeacherTabBarController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let index = viewControllers?.firstIndex(of: viewController), selectedViewController != viewController {
            reportScreenView(for: index, viewController: viewController)
        }

        return true
    }

    func tabBarController(
        _ tabBarController: UITabBarController,
        animationControllerForTransitionFrom fromVC: UIViewController,
        to toVC: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        InstUI.TabChangeTransition()
    }
}
