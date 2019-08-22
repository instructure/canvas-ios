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
import CanvasKeymaster
import Core

extension AppDelegate {
    @objc func registerNativeRoutes() {
        HelmManager.shared.registerNativeViewController(for: "/attendance", factory: { props in
            guard
                let destinationURL = (props["launchURL"] as? String).flatMap(URL.init(string:)),
                let courseName = props["courseName"] as? String,
                let courseID = props["courseID"] as? String,
                let courseColor = props["courseColor"].flatMap(RCTConvert.uiColor)
                else { return nil }

            return try? TeacherAttendanceViewController(
                courseName: courseName,
                courseColor: courseColor,
                launchURL: destinationURL,
                courseID: courseID,
                date: Date()
            )
        })

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
            return PageListViewController.create(context: ContextModel(.course, id: courseID), appTraitCollection: UIApplication.shared.keyWindow?.traitCollection)
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

        HelmManager.shared.registerNativeViewController(for: "/courses/:courseID/assignments/:assignmentID/post_policy", factory: { _ in
            return nil
        })

        CanvasCore.registerSharedNativeViewControllers()
    }
}

// MARK: - HelmModules

extension ModuleListViewController: HelmModule {
    var moduleName: String { return "/courses/:courseID/modules" }
}

extension WrongAppViewController: HelmModule {
    public var moduleName: String { return Route.wrongApp.url.path }
}
