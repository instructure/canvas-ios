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
import HorizonUI
import SwiftUI

final class HorizonTabBarController: UITabBarController, UITabBarControllerDelegate {
    // MARK: - Properties

    private let horizonTabBar = HorizonTabBar()
    private let router = AppEnvironment.shared.router

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setValue(horizonTabBar, forKey: "tabBar")
        horizonTabBar.backgroundColor = .backgroundLightest

        viewControllers = [
            dashboardTab(),
            learnTab(),
            fakeTab(),
            careerTab(),
            accountTab()
        ]
        tabBar.tintColor = .textDarkest
        UINavigationBar.appearance().tintColor = .textDarkest
        guard let tabBar = tabBar as? HorizonTabBar else { return }

        tabBar.didTapButton = { [weak self] in
            self?.presentChatBot()
        }
    }

    // MARK: - Functions

    private func presentChatBot() {
        let vc = CoreHostingController(AssistAssembly.makeAssistChatView())
        vc.modalPresentationStyle = .pageSheet
        router.show(vc, from: self, options: .modal(isDismissable: false))
    }

    private func dashboardTab() -> UIViewController {
        let vc = CoreNavigationController(
            rootViewController: CoreHostingController(DashboardAssembly.makeView())
        )
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()

        appearance.backgroundColor = UIColor(Color.huiColors.surface.pagePrimary)
        appearance.shadowImage = UIImage()
        appearance.shadowColor = nil

        vc.navigationBar.shadowImage = UIImage()
        vc.navigationBar.setBackgroundImage(UIImage(), for: .default)
        vc.navigationBar.standardAppearance = appearance
        vc.navigationBar.scrollEdgeAppearance = appearance

        vc.tabBarItem.title = String(localized: "Home", bundle: .horizon)
        vc.tabBarItem.image = getHorizonImage(name: "home")
        vc.tabBarItem.selectedImage = getHorizonImage(name: "home_filled")
        return vc
    }

    private func learnTab() -> UIViewController {
        let vc = CoreNavigationController(
            rootViewController: CoreHostingController(LearnAssembly.makeCoursesView())
        )
        vc.tabBarItem.title = String(localized: "Learn", bundle: .horizon)
        vc.tabBarItem.image = getHorizonImage(name: "book_2")
        vc.tabBarItem.selectedImage = getHorizonImage(name: "book_2_filled")
        return vc
    }

    private func fakeTab() -> UIViewController {
        if shouldPresentChatBot {
            let vc = UIViewController()
            vc.tabBarItem.image = UIImage(resource: .chatBot)
            return vc
        } else {
            return .init()
        }
    }

    private func careerTab() -> UIViewController {
        let vc = CoreNavigationController(
            rootViewController: CoreHostingController(Storybook())
        )
        vc.navigationBar.prefersLargeTitles = true
        vc.tabBarItem.title = String(localized: "Skillspace", bundle: .horizon)
        vc.tabBarItem.image = getHorizonImage(name: "hub")
        vc.tabBarItem.selectedImage = getHorizonImage(name: "hub_filled")
        return vc
    }

    private func accountTab() -> UIViewController {
        let vc = CoreNavigationController(
            rootViewController: CoreHostingController(AccountAssembly.makeView())
        )
        vc.tabBarItem.title = String(localized: "Account", bundle: .horizon)
        vc.tabBarItem.image = getHorizonImage(name: "account_circle")
        vc.tabBarItem.selectedImage = getHorizonImage(name: "account_circle_filled")
        return vc
    }

    private func getHorizonImage(name: String) -> UIImage? {
        UIImage(named: name, in: Bundle.horizonUI, with: nil)
    }
}

extension HorizonTabBarController {
    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        guard let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController) else {
            return true
        }
        if selectedIndex == 2, shouldPresentChatBot {
            presentChatBot()
            return false
        }
        return true
    }

    private var shouldPresentChatBot: Bool {
        if #available(iOS 18, *), UIDevice.current.userInterfaceIdiom == .pad {
            return true
        }
        return false
    }
}
