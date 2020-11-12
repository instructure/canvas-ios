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

        viewControllers = [coursesTab(), toDoTab(), inboxTab()]
        let paths = [ "/", "/to-do", "/conversations" ]
        selectedIndex = AppEnvironment.shared.userDefaults?.landingPath.flatMap {
            paths.firstIndex(of: $0)
        } ?? 0
        tabBar.useGlobalNavStyle()
    }

    func coursesTab() -> UIViewController {
        let split = HelmSplitViewController()
        split.viewControllers = [
            HelmNavigationController(rootViewController: DashboardCardViewController.create()),
            HelmNavigationController(rootViewController: EmptyViewController()),
        ]
        if !ExperimentalFeature.nativeDashboard.isEnabled {
            let dashboard = HelmViewController(moduleName: "/", props: [:])
            dashboard.navigationItem.titleView = Brand.shared.headerImageView()

            let master = HelmNavigationController(rootViewController: dashboard)
            master.navigationBar.useGlobalNavStyle()
            split.viewControllers = [
                master,
                HelmNavigationController(rootViewController: EmptyViewController()),
            ]
        }
        split.masterNavigationController?.delegate = split
        split.tabBarItem.title = NSLocalizedString("Courses")
        split.tabBarItem.image = .coursesTab
        split.tabBarItem.selectedImage = .coursesTabActive
        split.tabBarItem.accessibilityIdentifier = "TabBar.dashboardTab"
        split.preferredDisplayMode = .allVisible
        return split
    }

    func toDoTab() -> UIViewController {
        let toDoVC = HelmViewController(moduleName: "/to-do", props: [:])
        toDoVC.view.accessibilityIdentifier = "to-do-list.view"
        toDoVC.tabBarItem = UITabBarItem(title: NSLocalizedString("To Do", comment: ""), image: .todoTab, selectedImage: .todoTabActive)
        toDoVC.tabBarItem.accessibilityIdentifier = "TabBar.todoTab"
        TabBarBadgeCounts.todoItem = toDoVC.tabBarItem
        toDoVC.navigationItem.titleView = Brand.shared.headerImageView()
        let navigation = HelmNavigationController(rootViewController: toDoVC)
        navigation.navigationBar.useGlobalNavStyle()
        return navigation
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
}
