//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import SafariServices

public class LTITools {
    let env: AppEnvironment
    let context: Context
    let id: String?
    let url: URL?
    let launchType: GetSessionlessLaunchURLRequest.LaunchType?
    let assignmentID: String?
    let moduleID: String?
    let moduleItemID: String?

    var request: GetSessionlessLaunchURLRequest {
        GetSessionlessLaunchURLRequest(
            context: context,
            id: id,
            url: url,
            assignmentID: assignmentID,
            moduleItemID: moduleItemID,
            launchType: launchType
        )
    }

    public init(
        env: AppEnvironment = .shared,
        context: Context = Context(.account, id: "self"),
        id: String? = nil,
        url: URL? = nil,
        launchType: GetSessionlessLaunchURLRequest.LaunchType? = nil,
        assignmentID: String? = nil,
        moduleID: String? = nil,
        moduleItemID: String? = nil
    ) {
        self.env = env
        self.context = context
        self.id = id
        self.url = url
        self.launchType = launchType
        self.assignmentID = assignmentID
        self.moduleID = moduleID
        self.moduleItemID = moduleItemID
    }

    var openInSafari: Bool { UserDefaults.standard.bool(forKey: "open_lti_safari") }

    public convenience init?(env: AppEnvironment = .shared, link: URL?) {
        guard
            let retrieve = link, retrieve.host == env.api.baseURL.host,
            retrieve.path.hasSuffix("/external_tools/retrieve"),
            let query = URLComponents.parse(retrieve).queryItems,
            let value = query.first(where: { $0.name == "url" })?.value,
            let url = URL(string: value)
        else { return nil }
        let context = LTITools.context(forRetrieveURL: retrieve) ?? Context(.account, id: "self")
        self.init(env: env, context: context, url: url)
    }

    public func presentTool(from view: UIViewController, animated: Bool, completionHandler: ((Bool) -> Void)? = nil) {
        getSessionlessLaunch { [weak view] response in
            guard let view = view else { return }
            guard let response = response else {
                completionHandler?(false)
                return
            }
            let completionHandler = { [weak self] (success: Bool) in
                self?.markModuleItemRead()
                completionHandler?(success)
            }
            let url = response.url.appendingQueryItems(URLQueryItem(name: "platform", value: "mobile"))
            if response.name == "Google Apps" {
                let controller = GoogleCloudAssignmentViewController(url: url)
                self.env.router.show(controller, from: view, options: .modal(.overFullScreen, embedInNav: true, addDoneButton: true)) {
                    completionHandler(true)
                }
            } else if self.openInSafari {
                    self.env.loginDelegate?.openExternalURL(url)
                    completionHandler(true)
            } else {
                let safari = SFSafariViewController(url: url)
                self.env.router.show(safari, from: view, options: .modal(.overFullScreen)) {
                    completionHandler(true)
                }
            }
        }
    }

    public func getSessionlessLaunch(completionBlock: @escaping (APIGetSessionlessLaunchResponse?) -> Void) {
        env.api.makeRequest(request) { response, _, _ in performUIUpdate {
            completionBlock(response)
        } }
    }

    public func getSessionlessLaunchURL(completionBlock: @escaping (URL?) -> Void) {
        getSessionlessLaunch { completionBlock($0?.url) }
    }

    private static func context(forRetrieveURL url: URL) -> Context? {
        let route = Route("/:context/:contextID/external_tools/retrieve")
        if let match = RouteHandler(route, factory: { _, _ in nil }).match(.parse(url)),
            let contextTypeRaw = match["context"],
            let contextType = ContextType(pathComponent: contextTypeRaw),
            let contextID = match["contextID"] {
            return Context(contextType, id: contextID)
        }
        return nil
    }

    private func markModuleItemRead() {
        guard launchType == .module_item, let moduleID = moduleID, let moduleItemID = moduleItemID else {
            return
        }
        env.api.makeRequest(PostMarkModuleItemRead(courseID: context.id, moduleID: moduleID, moduleItemID: moduleItemID)) { _, _, error in
            if error == nil {
                NotificationCenter.default.post(name: .CompletedModuleItemRequirement, object: nil)
            }
        }
    }
}
