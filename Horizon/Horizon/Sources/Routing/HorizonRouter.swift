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
import Foundation
import SwiftUI

enum HorizonRouter {
    private(set) static var routes: [RouteHandler] = [
        RouteHandler("/splash") { _, _, _ in
            SplashAssembly.makeViewController()
        },
        RouteHandler("/contentDetails") { _, _, _ in
            ContentDetailsAssembly.makeViewController()
        },
        RouteHandler("/courses/:courseID/module_item_redirect/:itemID") { url, params, _ in
            guard let courseID = params["courseID"], let itemID = params["itemID"] else { return nil }
            return ModuleItemSequenceViewController.create(
                courseID: courseID,
                assetType: .moduleItem,
                assetID: itemID,
                url: url
            )
        },
        RouteHandler("/:context/:contextID/pages") { url, _, _ in
            guard let context = Context(path: url.path) else { return nil }
            return PageListViewController.create(context: context, app: .student)
        },
        RouteHandler("/:context/:contextID/pages/:url", factory: pageViewController),
        RouteHandler("/programs/:programID") { _, _, userInfo in
            guard let program = userInfo?["program"] as? HProgram else { return nil }
            return ProgramsAssembly.makeProgramDetailsViewController(program: program)
        }
    ]
}

private func pageViewController(url: URLComponents, params: [String: String], userInfo _: [String: Any]?) -> UIViewController? {
    guard let context = Context(path: url.path), let pageURL = params["url"] else { return nil }
    if !url.originIsModuleItemDetails, context.contextType == .course {
        return ModuleItemSequenceViewController.create(
            courseID: context.id,
            assetType: .page,
            assetID: pageURL,
            url: url
        )
    }
    return PageDetailsViewController.create(context: context, pageURL: pageURL, app: .student)
}
