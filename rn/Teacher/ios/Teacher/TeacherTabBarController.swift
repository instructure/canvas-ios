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

        reportScreenView(for: selectedIndex, viewController: viewControllers![selectedIndex])
    }

    func coursesTab() -> UIViewController {
        let split = HelmSplitViewController()
        split.viewControllers = [
            HelmNavigationController(rootViewController: CoreHostingController(
                DashboardCardView(
                    shouldShowGroupList: false,
                    showOnlyTeacherEnrollment: true))),
            HelmNavigationController(rootViewController: EmptyViewController()),
        ]
        split.masterNavigationController?.delegate = split
        split.tabBarItem.title = NSLocalizedString("Courses", comment: "")
        split.tabBarItem.image = .coursesTab
        split.tabBarItem.selectedImage = .coursesTabActive
        split.tabBarItem.accessibilityIdentifier = "TabBar.dashboardTab"
        split.preferredDisplayMode = .oneBesideSecondary
        return split
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
        let map = ["dashboard", "todo", "conversations"]
        let event = map[tabIndex]
        Analytics.shared.logScreenView(route: "/tabs/" + event, viewController: viewController)
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
