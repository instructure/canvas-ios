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

@objc
public class LTITools: NSObject {
    let env: AppEnvironment
    let context: Context
    let id: String?
    let url: URL?
    let launchType: GetSessionlessLaunchURLRequest.LaunchType?
    let assignmentID: String?
    let moduleID: String?
    let moduleItemID: String?
    let resourceLinkLookupUUID: String?

    var request: GetSessionlessLaunchURLRequest {
        GetSessionlessLaunchURLRequest(
            context: context,
            id: id,
            url: url,
            assignmentID: assignmentID,
            moduleItemID: moduleItemID,
            launchType: launchType,
            resourceLinkLookupUUID: resourceLinkLookupUUID
        )
    }

    @objc
    public static func launch(
        context: String?,
        id: String?,
        url: URL?,
        launchType: String?,
        assignmentID: String?,
        from view: UIViewController,
        animated: Bool = true,
        completionHandler: ((Bool) -> Void)? = nil
    ) {
        let tools = LTITools(
            context: context.flatMap { Context(canvasContextID: $0) },
            id: id,
            url: url,
            launchType: launchType.flatMap { GetSessionlessLaunchURLRequest.LaunchType(rawValue: $0) },
            assignmentID: assignmentID
        )
        tools.presentTool(from: view, animated: animated, completionHandler: completionHandler)
    }

    public init(
        env: AppEnvironment = .shared,
        context: Context? = nil,
        id: String? = nil,
        url: URL? = nil,
        launchType: GetSessionlessLaunchURLRequest.LaunchType? = nil,
        assignmentID: String? = nil,
        moduleID: String? = nil,
        moduleItemID: String? = nil,
        resourceLinkLookupUUID: String? = nil
    ) {
        self.env = env
        self.context = context ?? url.flatMap { Context(url: $0) } ?? .account("self")
        self.id = id
        self.url = url
        self.launchType = launchType
        self.assignmentID = assignmentID
        self.moduleID = moduleID
        self.moduleItemID = moduleItemID
        self.resourceLinkLookupUUID = resourceLinkLookupUUID
    }

    var openInSafari: Bool { UserDefaults.standard.bool(forKey: "open_lti_safari") }

    public convenience init?(env: AppEnvironment = .shared, link: URL?) {
        guard
            let retrieve = link, retrieve.host == env.api.baseURL.host,
            retrieve.path.hasSuffix("/external_tools/retrieve")
        else { return nil }

        let components = URLComponents.parse(retrieve)

        let url: URL? = {
            guard let urlQueryItem = components.queryValue(for: "url") else {
                return nil
            }
            return URL(string: urlQueryItem)
        }()
        let resourceLinkUUID = components.queryValue(for: "resource_link_lookup_uuid")

        if url == nil, resourceLinkUUID == nil {
            return nil
        }

        let context = Context(url: retrieve) ?? .account("self")
        self.init(env: env, context: context, url: url, resourceLinkLookupUUID: resourceLinkUUID)
    }

    public func presentTool(from view: UIViewController, animated: Bool = true, completionHandler: ((Bool) -> Void)? = nil) {
        getSessionlessLaunch { [weak view] response in
            guard let view = view else { return }
            guard let response = response else {
                completionHandler?(false)
                return
            }
            Analytics.shared.logEvent("external_tool_launched", parameters: ["launchUrl": response.url])
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
                    self.env.loginDelegate?.openExternalURLinSafari(url)
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
        if let url = url, url.path.hasSuffix("/external_tools/sessionless_launch") {
            env.api.makeRequest(url) { data, _, _ in performUIUpdate {
                guard let data = data else { return completionBlock(nil) }
                let response = try? APIJSONDecoder().decode(APIGetSessionlessLaunchResponse.self, from: data)
                completionBlock(response)
            } }
            return
        }
        env.api.makeRequest(request) { response, _, _ in performUIUpdate {
            completionBlock(response)
        } }
    }

    public func getSessionlessLaunchURL(completionBlock: @escaping (URL?) -> Void) {
        getSessionlessLaunch { completionBlock($0?.url) }
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
