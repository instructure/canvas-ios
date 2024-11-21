//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Core
import UIKit

class HorizonTabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        viewControllers = [
            dashboardTab(),
            programsTab(),
            journeyTab(),
            portfolioTab(),
            inboxTab()
        ]
        tabBar.tintColor = .textDark
        UINavigationBar.appearance().tintColor = .textDarkest
    }

    private func dashboardTab() -> UIViewController {
        let vc = CoreNavigationController(
            rootViewController: CoreHostingController(DashboardAssembly.makeView())
        )
        vc.tabBarItem.title = String(localized: "Dashboard", bundle: .horizon)
        vc.tabBarItem.image = UIImage(systemName: "house")
        return vc
    }

    private func programsTab() -> UIViewController {
        let vc = CoreNavigationController(
            rootViewController: CoreHostingController(ProgramsAssembly.makeProgramsView())
        )
        vc.tabBarItem.title = String(localized: "Programs", bundle: .horizon)
        vc.tabBarItem.image = UIImage(systemName: "books.vertical")
        return vc
    }

    private func journeyTab() -> UIViewController {
        let vc = CoreNavigationController(
            rootViewController: CoreHostingController(JourneyAssembly.makeView())
        )
        vc.tabBarItem.title = String(localized: "Journey", bundle: .horizon)
        vc.tabBarItem.image = UIImage(systemName: "graduationcap")
        return vc
    }

    private func portfolioTab() -> UIViewController {
        let vc = CoreNavigationController()
        vc.tabBarItem.title = String(localized: "Portfolio", bundle: .horizon)
        vc.tabBarItem.image = UIImage(systemName: "newspaper")
        return vc
    }

    private func inboxTab() -> UIViewController {
        let inboxController: UIViewController
        let inboxSplit = CoreSplitViewController()

        inboxController = InboxAssembly.makeInboxViewController()

        let empty = CoreNavigationController()

        inboxSplit.viewControllers = [inboxController, empty]
        let title = "Inbox"
        inboxSplit.tabBarItem = UITabBarItem(title: title, image: .inboxTab, selectedImage: .inboxTabActive)
        inboxSplit.tabBarItem.accessibilityIdentifier = "TabBar.inboxTab"
//        inboxSplit.tabBarItem.makeUnavailableInOfflineMode()
        inboxSplit.extendedLayoutIncludesOpaqueBars = true
        TabBarBadgeCounts.messageItem = inboxSplit.tabBarItem
        return inboxSplit
    }
}
