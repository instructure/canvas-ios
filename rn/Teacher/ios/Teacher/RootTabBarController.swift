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

class RootTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabs()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            StartupManager.shared.markStartupFinished()
        }

        NotificationKitController.registerForPushNotifications()
    }

    @objc func configureTabs() {
        viewControllers = [coursesTab(), toDoTab(), inboxTab()]
        let paths = [ "/", "/to-do", "/conversations" ]
        selectedIndex = AppEnvironment.shared.userDefaults?.landingPath
            .flatMap { paths.firstIndex(of: $0) } ?? 0
        tabBar.useGlobalNavStyle()
    }

    @objc func coursesTab() -> UIViewController {
        let split = EnrollmentSplitViewController()
        let emptyNav = HelmNavigationController(rootViewController: EmptyViewController())

        let enrollmentsVC = HelmViewController(moduleName: "/", props: [:])
        enrollmentsVC.view.accessibilityIdentifier = "favorited-course-list.view1"
        enrollmentsVC.navigationItem.titleView = Brand.shared.headerImageView()

        let masterNav = HelmNavigationController(rootViewController: enrollmentsVC)
        masterNav.view.backgroundColor = .white
        masterNav.delegate = split
        masterNav.navigationBar.useGlobalNavStyle()
        emptyNav.navigationBar.useGlobalNavStyle()
        split.viewControllers = [masterNav, emptyNav]
        split.view.accessibilityIdentifier = "favorited-course-list.view2"
        split.tabBarItem = UITabBarItem(title: NSLocalizedString("Courses", comment: ""), image: .icon(.courses), selectedImage: .icon(.courses, .solid))
        split.tabBarItem.accessibilityIdentifier = "TabBar.dashboardTab"
        split.preferredDisplayMode = .allVisible
        return split
    }

    @objc func toDoTab() -> UIViewController {
        let toDoVC = HelmViewController(moduleName: "/to-do", props: [:])
        toDoVC.view.accessibilityIdentifier = "to-do-list.view"
        toDoVC.tabBarItem = UITabBarItem(title: NSLocalizedString("To Do", comment: ""), image: .icon(.todo), selectedImage: .icon(.todoSolid))
        toDoVC.tabBarItem.accessibilityIdentifier = "TabBar.todoTab"
        TabBarBadgeCounts.todoItem = toDoVC.tabBarItem
        toDoVC.navigationItem.titleView = Brand.shared.headerImageView()
        let navigation = HelmNavigationController(rootViewController: toDoVC)
        navigation.navigationBar.useGlobalNavStyle()
        return navigation
    }
}
