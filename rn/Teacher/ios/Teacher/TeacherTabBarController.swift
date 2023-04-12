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
import CanvasCore
import Core
import UserNotifications

class TeacherTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        viewControllers = [coursesTab(), toDoTab(), inboxTab()]
        let paths = [ "/", "/to-do", "/conversations" ]
        selectedIndex = AppEnvironment.shared.userDefaults?.landingPath.flatMap {
            paths.firstIndex(of: $0)
        } ?? 0
        tabBar.useGlobalNavStyle()
        NotificationCenter.default.addObserver(self, selector: #selector(checkForPolicyChanges), name: UIApplication.didBecomeActiveNotification, object: nil)
        reportScreenView(for: selectedIndex, viewController: viewControllers![selectedIndex])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkForPolicyChanges()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    func coursesTab() -> UIViewController {
        let cardView = CoreHostingController(DashboardContainerView(shouldShowGroupList: false,
                                                               showOnlyTeacherEnrollment: true))
        let dashboard = DashboardContainerViewController(rootViewController: cardView) { HelmSplitViewController() }
        dashboard.tabBarItem.title = NSLocalizedString("Courses", comment: "")
        dashboard.tabBarItem.image = .coursesTab
        dashboard.tabBarItem.selectedImage = .coursesTabActive
        dashboard.tabBarItem.accessibilityIdentifier = "TabBar.dashboardTab"
        return dashboard
    }

    func toDoTab() -> UIViewController {
        let todo = HelmNavigationController(rootViewController: TodoListViewController.create())
        todo.tabBarItem.title = NSLocalizedString("To Do", comment: "")
        todo.tabBarItem.image = .todoTab
        todo.tabBarItem.selectedImage = .todoTabActive
        todo.tabBarItem.accessibilityIdentifier = "TabBar.todoTab"
        TabBarBadgeCounts.todoItem = todo.tabBarItem
        todo.viewControllers.first?.loadViewIfNeeded() // start fetching todos immediately
        return todo
    }

    func inboxTab() -> UIViewController {
        let inboxController: UIViewController
        let inboxSplit = HelmSplitViewController()

        if ExperimentalFeature.nativeTeacherInbox.isEnabled {
            inboxController = InboxAssembly.makeInboxViewController()
        } else {
            let inboxVC = HelmViewController(moduleName: "/conversations", props: [:])
            inboxVC.navigationItem.titleView = Core.Brand.shared.headerImageView()
            let inboxNav = HelmNavigationController(rootViewController: inboxVC)
            inboxNav.navigationBar.useGlobalNavStyle()
            inboxController = inboxNav
        }

        let empty = HelmNavigationController()
        empty.navigationBar.useGlobalNavStyle()

        inboxSplit.viewControllers = [inboxController, empty]
        let title = NSLocalizedString("Inbox", comment: "Inbox tab title")
        inboxSplit.tabBarItem = UITabBarItem(title: title, image: .inboxTab, selectedImage: .inboxTabActive)
        inboxSplit.tabBarItem.accessibilityIdentifier = "TabBar.inboxTab"
        inboxSplit.extendedLayoutIncludesOpaqueBars = true
        TabBarBadgeCounts.messageItem = inboxSplit.tabBarItem

        return inboxSplit
    }

    private func reportScreenView(for tabIndex: Int, viewController: UIViewController) {
        let map = ["dashboard", "todo", "conversations"]
        let event = map[tabIndex]
        Analytics.shared.logScreenView(route: "/tabs/" + event, viewController: viewController)
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
}
