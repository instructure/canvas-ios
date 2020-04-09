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

import Foundation
import CanvasCore
import Core

extension AppDelegate {
    @objc func registerNativeRoutes() {
        HelmManager.shared.registerNativeViewController(for: "/courses/:courseID/attendance/:toolID", factory: { props in
            guard let courseID = props["courseID"] as? String else { return nil }
            guard let toolID = props["toolID"] as? String else { return nil }
            return AttendanceViewController(
                context: ContextModel(.course, id: courseID),
                toolID: toolID
            )
        })

        if ExperimentalFeature.nativeDashboard.isEnabled {
            HelmManager.shared.registerNativeViewController(for: "/courses", factory: { _ in
                return CourseListViewController.create()
            })
        }

        HelmManager.shared.registerNativeViewController(for: "/courses/:courseID/modules", factory: { props in
            guard let courseID = props["courseID"] as? String else { return nil }
            return ModuleListViewController.create(courseID: courseID)
        })

        HelmManager.shared.registerNativeViewController(for: "/courses/:courseID/modules/:moduleID", factory: { props in
            guard let courseID = props["courseID"] as? String else { return nil }
            guard let moduleID = props["moduleID"] as? String else { return nil }
            return ModuleListViewController.create(courseID: courseID, moduleID: moduleID)
        })

        HelmManager.shared.registerNativeViewController(for: "/courses/:courseID/pages", factory: { props in
            guard let courseID = props["courseID"] as? String else { return nil }
            return PageListViewController.create(context: ContextModel(.course, id: courseID), app: .teacher)
        })

        HelmManager.shared.registerNativeViewController(for: "/courses/:courseID/users", factory: { props in
            guard let courseID = props["courseID"] as? String else { return nil }
            return PeopleListViewController.create(context: ContextModel(.course, id: courseID))
        })

        HelmManager.shared.registerNativeViewController(for: "/courses/:courseID/pages/:url", factory: { props in
            guard let courseID = props["courseID"] as? String else { return nil }
            guard let pageURL = props["url"] as? String else { return nil }
            return PageDetailsViewController.create(context: ContextModel(.course, id: courseID), pageURL: pageURL, app: .teacher)
        })

        HelmManager.shared.registerNativeViewController(for: "/courses/:courseID/wiki/:url", factory: { props in
            guard let courseID = props["courseID"] as? String else { return nil }
            guard let pageURL = props["url"] as? String else { return nil }
            return PageDetailsViewController.create(context: ContextModel(.course, id: courseID), pageURL: pageURL, app: .teacher)
        })

        HelmManager.shared.registerNativeViewController(for: "/courses/:courseID/wiki/:url", factory: { props in
            guard let courseID = props["courseID"] as? String else { return nil }
            guard let pageURL = props["url"] as? String else { return nil }
            return PageDetailsViewController.create(context: ContextModel(.course, id: courseID), pageURL: pageURL, app: .teacher)
        })

        HelmManager.shared.registerNativeViewController(for: "/courses/:courseID/modules/:moduleID/items/:itemID", factory: { props in
            guard
                let courseID = props["courseID"] as? String,
                let itemID = props["itemID"] as? String,
                let location = props["location"] as? [String: Any],
                let url = (location["href"] as? String).flatMap(URLComponents.parse)
            else {
                return nil
            }
            return ModuleItemSequenceViewController.create(courseID: courseID, assetType: .moduleItem, assetID: itemID, url: url)
        })

        HelmManager.shared.registerNativeViewController(for: "/courses/:courseID/modules/items/:itemID", factory: { props in
            guard
                let courseID = props["courseID"] as? String,
                let itemID = props["itemID"] as? String,
                let location = props["location"] as? [String: Any],
                let url = (location["href"] as? String).flatMap(URLComponents.parse)
            else {
                return nil
            }
            return ModuleItemSequenceViewController.create(courseID: courseID, assetType: .moduleItem, assetID: itemID, url: url)
        })

        HelmManager.shared.registerNativeViewController(for: "/courses/:courseID/module_item_redirect/:itemID", factory: { props in
            guard
                let courseID = props["courseID"] as? String,
                let itemID = props["itemID"] as? String,
                let location = props["location"] as? [String: Any],
                let url = (location["href"] as? String).flatMap(URLComponents.parse)
            else {
                return nil
            }
            return ModuleItemSequenceViewController.create(courseID: courseID, assetType: .moduleItem, assetID: itemID, url: url)
        })

        HelmManager.shared.registerNativeViewController(for: "/groups/:groupID/pages/:url", factory: { props in
            guard let groupID = props["groupID"] as? String else { return nil }
            guard let pageURL = props["url"] as? String else { return nil }
            return PageDetailsViewController.create(context: ContextModel(.group, id: groupID), pageURL: pageURL, app: .teacher)
        })

        HelmManager.shared.registerNativeViewController(for: "/groups/:groupID/wiki/:url", factory: { props in
            guard let groupID = props["groupID"] as? String else { return nil }
            guard let pageURL = props["url"] as? String else { return nil }
            return PageDetailsViewController.create(context: ContextModel(.group, id: groupID), pageURL: pageURL, app: .teacher)
        })

        HelmManager.shared.registerNativeViewController(for: "/act-as-user", factory: { _ in
            guard let loginDelegate = UIApplication.shared.delegate as? LoginDelegate else { return nil }
            return ActAsUserViewController.create(loginDelegate: loginDelegate)
        })

        HelmManager.shared.registerNativeViewController(for: "/act-as-user/:userID", factory: { props in
            guard let loginDelegate = UIApplication.shared.delegate as? LoginDelegate else { return nil }
            return ActAsUserViewController.create(loginDelegate: loginDelegate, userID: props["userID"] as? String)
        })

        HelmManager.shared.registerNativeViewController(for: Route.wrongApp.url.path, factory: { _ in
            guard let loginDelegate = UIApplication.shared.delegate as? LoginDelegate else { return nil }
            return WrongAppViewController.create(delegate: loginDelegate)
        })

        HelmManager.shared.registerNativeViewController(for: "/courses/:courseID/assignments/:assignmentID/post_policy", factory: { props in
            guard let courseID = props["courseID"] as? String, let assignmentID = props["assignmentID"] as? String else { return nil }
            return PostSettingsViewController.create(courseID: courseID, assignmentID: assignmentID)
        })

        HelmManager.shared.registerNativeViewController(for: "/profile", factory: { _ in
            return ProfileViewController.create(enrollment: .teacher)
        })

        HelmManager.shared.registerNativeViewController(for: "/profile/settings", factory: { _ in
            return ProfileSettingsViewController.create()
        })

        HelmManager.shared.registerNativeViewController(for: "/dev-menu/experimental-features", factory: { _ in
            let vc = ExperimentalFeaturesViewController()
            vc.afterToggle = {
                HelmManager.shared.reload()
            }
            return vc
        })

        CanvasCore.registerSharedNativeViewControllers()
    }
}

// MARK: - HelmModules

extension ModuleListViewController: HelmModule {
    public var moduleName: String { return "/courses/:courseID/modules" }
}

extension WrongAppViewController: HelmModule {
    public var moduleName: String { return Route.wrongApp.url.path }
}
