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

import Combine
import Foundation
import SafariServices
import WebKit

@objc
public class LTITools: NSObject {
    let env: AppEnvironment
    let context: Context
    let id: String?
    let url: URL?
    let launchType: GetSessionlessLaunchURLRequest.LaunchType?
    let isQuizLTI: Bool? // This is optional because not all entry points provide this info
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

    public static func launch(
        context: String?,
        id: String?,
        url: URL?,
        launchType: String?,
        isQuizLTI: Bool?,
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
            isQuizLTI: isQuizLTI,
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
        isQuizLTI: Bool?,
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
        self.isQuizLTI = isQuizLTI
        self.assignmentID = assignmentID
        self.moduleID = moduleID
        self.moduleItemID = moduleItemID
        self.resourceLinkLookupUUID = resourceLinkLookupUUID
    }

    var openInSafari: Bool { UserDefaults.standard.bool(forKey: "open_lti_safari") }

    public convenience init?(env: AppEnvironment = .shared, link: URL?, navigationType: WKNavigationType) {
        guard let link, link.host == env.api.baseURL.host else { return nil }

        if let (context, url, resourceLinkUUID) = Self.parseRegularExternalToolURL(url: link),
           navigationType == .linkActivated {
            self.init(
                env: env,
                context: context,
                url: url,
                isQuizLTI: nil,
                resourceLinkLookupUUID: resourceLinkUUID
            )
            return
        } else if let (courseID, toolID) = Self.parseQuerylessExternalToolURL(url: link), navigationType == .other {
            self.init(
                env: env,
                context: .course(courseID),
                id: toolID,
                launchType: .course_navigation,
                isQuizLTI: nil
            )
            return
        } else {
            return nil
        }
    }

    private static func parseRegularExternalToolURL(url: URL) -> (
        context: Context,
        url: URL?,
        resourceLinkUUID: String?
    )? {
        guard url.path.hasSuffix("/external_tools/retrieve") else {
            return nil
        }
        let components = URLComponents.parse(url)

        let newURL: URL? = {
            guard let urlQueryItem = components.queryValue(for: "url") else {
                return nil
            }
            return URL(string: urlQueryItem)
        }()
        let resourceLinkUUID = components.queryValue(for: "resource_link_lookup_uuid")

        if newURL == nil, resourceLinkUUID == nil {
            return nil
        }

        let context = Context(url: url) ?? .account("self")
        return (context, newURL, resourceLinkUUID)
    }

    // Parses LTI button triggered urls opened from K5 WebViews like Zoom and Microsoft LTIs.
    // Expects a url without any query parameters: `courses/:courseID/external_tools/:toolID`.
    // URLs with parameters are discarded, because there must be an already opened popup window loading the request.
    private static func parseQuerylessExternalToolURL(url: URL) -> (courseID: String, toolID: String)? {
        guard url.pathComponents.count == 5 else { return nil }

        if let queryItems = URLComponents.parse(url).queryItems, !queryItems.isEmpty {
            return nil
        }

        let components = url.pathComponents
        guard components[1] == "courses", components[3] == "external_tools" else { return nil }
        return (components[2], components[4])
    }

    public func presentTool(from view: UIViewController, animated: Bool = true, completionHandler: ((Bool) -> Void)? = nil) {
        getSessionlessLaunch { [weak view, originalUrl = url, env, isQuizLTI] response in
            guard let view else { return }
            guard let response = response else {
                completionHandler?(false)
                return
            }

            Analytics.shared.logEvent("external_tool_launched", parameters: ["launchUrl": response.url])
            let completionHandler = { [weak self] (success: Bool) in
                self?.markModuleItemRead()
                completionHandler?(success)
            }
            var url = response.url.appendingQueryItems(URLQueryItem(name: "platform", value: "mobile"))
            if url.absoluteString.contains(RemoteConfigManager.shared.placementPortalPath) {
                url = url.appendingQueryItems(URLQueryItem(name: "launch_type", value: "global_navigation"))
            }

            if isQuizLTI == true {
                let controller = CoreWebViewController(features: [
                    .invertColorsInDarkMode,
                    .hideReturnButtonInQuizLTI
                ])
                controller.webView.load(URLRequest(url: url))
                controller.title = String(localized: "Quiz", bundle: .core)
                controller.addDoneButton(side: .right)
                controller.setupBackToolbarButton()
                env.router.show(controller, from: view, options: .modal(.overFullScreen, embedInNav: true)) {
                    completionHandler(true)
                }
            } else if response.name == "Google Apps" {
                let controller = GoogleCloudAssignmentViewController(url: url)
                self.env.router.show(controller, from: view, options: .modal(.overFullScreen, embedInNav: true, addDoneButton: true)) {
                    completionHandler(true)
                }
            } else if originalUrl?.absoluteString.contains("custom_arc_launch_type=global_nav") == true {
                env.router.show(
                    StudioViewController(url: url),
                    from: view,
                    options: .modal(.overFullScreen)
                ) {
                    completionHandler(true)
                }
            } else if self.openInSafari {
                self.env.loginDelegate?.openExternalURLinSafari(url)
                completionHandler(true)
            } else {
                let safari = SFSafariViewController(url: url)
                safari.modalPresentationCapturesStatusBarAppearance = true
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

    public func getSessionlessLaunchURL() -> AnyPublisher<URL, Error> {
        Future { promise in
            self.getSessionlessLaunchURL { url in
                guard let url else {
                    return promise(.failure(NSError.internalError()))
                }
                promise(.success(url))
            }
        }
        .eraseToAnyPublisher()
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
