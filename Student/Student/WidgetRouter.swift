//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

struct WidgetRouter {

    struct ViewProxy {
        let env: AppEnvironment
        let tabController: UITabBarController

        var selectedTabSplitController: UISplitViewController? {
            tabController.selectedViewController as? UISplitViewController
        }

        var selectedTabMasterController: UINavigationController? {
            selectedTabSplitController?.masterNavigationController
        }

        var selectedTabMasterRootController: UIViewController? {
            selectedTabMasterController?.viewControllers.first
        }
        var selectedNavigationController: UINavigationController? {
            tabController.selectedViewController as? UINavigationController
        }

        func selectTab(at index: Int) {
            tabController.selectedIndex = index
        }

        func resetSplitMasterToRoot() {
            selectedTabSplitController?.resetToRoot()
        }

        func resetNavigationToRoot(animated: Bool = false) {
            selectedNavigationController?.popToRootViewController(animated: animated)
        }
    }

    struct RouteHandler {
        let route: Route
        let action: (URLComponents, [String: String], ViewProxy) -> Void

        init(
            _ template: String,
            action: @escaping (URLComponents, [String: String], ViewProxy) -> Void
        ) {
            self.route = Route(template)
            self.action = action
        }
    }

    private let originValue: String
    private let handlers: [RouteHandler]

    init(originValue: String, handlers: [RouteHandler]) {
        self.originValue = originValue
        self.handlers = handlers
    }

    func handling(_ url: URLComponents, in window: UIWindow?, env: AppEnvironment) -> Bool {
        guard url.hasOrigin(originValue),
              let rootViewController = window?.rootViewController,
              let tabController = rootViewController as? StudentTabBarController
        else { return false }

        // Dismiss all modals
        rootViewController.dismiss(animated: false)

        let viewProxy = ViewProxy(
            env: env,
            tabController: tabController
        )

        for handler in handlers {
            if let params = handler.route.match(url) {
                handler.action(url, params, viewProxy)
                return true
            }
        }

        return false
    }
}
