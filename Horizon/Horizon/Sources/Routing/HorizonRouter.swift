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
        },
        RouteHandler("/conversations/:conversationID") { _, params, userInfo in
            guard let conversationID = params["conversationID"] else { return nil }
            let allowArchive: Bool = {
                if let userInfo, let allowArchiveParam = userInfo["allowArchive"] as? Bool {
                    return allowArchiveParam
                } else {
                    return true
                }
            }()
            return MessageDetailsAssembly.makeViewController(
                env: AppEnvironment.shared,
                conversationID: conversationID,
                allowArchive: allowArchive
            )
        },
        RouteHandler("/files/:fileID", factory: fileDetails),
        RouteHandler("/files/:fileID/download", factory: fileDetails),
        RouteHandler("/files/:fileID/preview", factory: fileDetails),
        RouteHandler("/:context/:contextID/files/:fileID", factory: fileDetails),
        RouteHandler("/:context/:contextID/files/:fileID/download", factory: fileDetails),
        RouteHandler("/:context/:contextID/files/:fileID/preview", factory: fileDetails)
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

private func fileDetails(
    url: URLComponents,
    params: [String: String],
    userInfo _: [String: Any]?
) -> UIViewController? {
    guard let fileID = url.queryItems?.first(where: { $0.name == "preview" })?.value ?? params["fileID"] else { return nil }
    var context = Context(path: url.path)
    if let courseID = url.queryItems?.first(where: { $0.name == "courseID" })?.value {
        context = Context(.course, id: courseID)
    }
    let assignmentID = url.queryItems?.first(where: { $0.name == "assignmentID" })?.value
    if !url.originIsModuleItemDetails, !url.skipModuleItemSequence, let context = context, context.contextType == .course {
        return ModuleItemSequenceViewController.create(
            courseID: context.id,
            assetType: .file,
            assetID: fileID,
            url: url
        )
    }
    return FileDetailsViewController.create(
        context: context,
        fileID: fileID,
        originURL: url,
        assignmentID: assignmentID
    )
}
