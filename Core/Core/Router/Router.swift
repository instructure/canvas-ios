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

import UIKit

public enum RouteOptions: Equatable {
    case push
    case detail
    case modal(
        _ style: UIModalPresentationStyle? = nil,
        isDismissable: Bool = true,
        embedInNav: Bool = false,
        addDoneButton: Bool = false
    )

    public var isModal: Bool {
        if case .modal = self {
            return true
        }
        return false
    }

    public var isDetail: Bool {
        if case .detail = self {
            return true
        }
        return false
    }

    public var embedInNav: Bool {
        switch self {
        case .detail, .modal(_, _, embedInNav: true, _):
            return true
        default:
            return false
        }
    }
}

// The Router stores all routes that can be routed to in the app
open class Router {
    public typealias FallbackHandler = (URLComponents, [String: Any]?, UIViewController, RouteOptions) -> Void

    private let handlers: [RouteHandler]
    private let fallback: FallbackHandler

    public init(routes: [RouteHandler], fallback: @escaping FallbackHandler) {
        self.handlers = routes
        self.fallback = fallback
    }

    public var count: Int {
        return handlers.count
    }

    private func cleanURL(_ url: URLComponents) -> URLComponents {
        // URLComponents does all the encoding we care about except we often have + meaning space in query
        var url = url
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%20")
        return url
    }

    public func match(_ url: URL, userInfo: [String: Any]? = nil) -> UIViewController? {
        return match(.parse(url), userInfo: userInfo)
    }
    public func match(_ url: String, userInfo: [String: Any]? = nil) -> UIViewController? {
        return match(.parse(url), userInfo: userInfo)
    }
    open func match(_ url: URLComponents, userInfo: [String: Any]? = nil) -> UIViewController? {
        let url = cleanURL(url)
        for route in handlers {
            if let params = route.match(url) {
                return route.factory(url, params, userInfo)
            }
        }
        return nil
    }

    public func route(to url: URL, userInfo: [String: Any]? = nil, from: UIViewController, options: RouteOptions = .push) {
        return route(to: .parse(url), userInfo: userInfo, from: from, options: options)
    }
    public func route(to url: String, userInfo: [String: Any]? = nil, from: UIViewController, options: RouteOptions = .push) {
        return route(to: .parse(url), userInfo: userInfo, from: from, options: options)
    }
    open func route(to url: URLComponents, userInfo: [String: Any]? = nil, from: UIViewController, options: RouteOptions = .push) {
        let url = cleanURL(url)
        #if DEBUG
        DeveloperMenuViewController.recordRouteInHistory(url.url?.absoluteString)
        #endif
        Analytics.shared.logEvent("route", parameters: ["url": String(describing: url)])
        for route in handlers {
            if let params = route.match(url) {
                if let view = route.factory(url, params, userInfo) {
                    show(view, from: from, options: options)
                }
                return // don't fall back if a matched route returns no view
            }
        }
        fallback(url, userInfo, from, options)
    }

    open func show(_ view: UIViewController, from: UIViewController, options: RouteOptions = .push, completion: (() -> Void)? = nil) {
        if view is UIAlertController { return from.present(view, animated: true, completion: completion) }

        if let displayModeButton = from.splitDisplayModeButtonItem,
            from.splitViewController?.isCollapsed == false,
            options.isDetail || from.isInSplitViewDetail,
            !options.isModal {
            view.addNavigationButton(displayModeButton, side: .left)
            view.navigationItem.leftItemsSupplementBackButton = true
        }

        var nav: UINavigationController?
        if options.embedInNav {
            nav = view as? UINavigationController ?? UINavigationController(rootViewController: view)
        }

        switch options {
        case let .modal(style, isDismissable, _, addDoneButton):
            if addDoneButton {
                view.addDoneButton(side: .left)
            }
            nav?.navigationBar.useModalStyle()
            if let presentationStyle = style {
                (nav ?? view).modalPresentationStyle = presentationStyle
            }
            if #available(iOS 13, *), !isDismissable {
                (nav ?? view).isModalInPresentation = true
            }
            from.present(nav ?? view, animated: true, completion: completion)
        case .detail:
            if from.splitViewController == nil || from.isInSplitViewDetail || from.splitViewController?.isCollapsed == true {
                from.show(view, sender: nil)
            } else {
                from.showDetailViewController(nav ?? view, sender: from)
            }
        case .push:
            from.show(nav ?? view, sender: nil)
        }
    }

    open func pop(from: UIViewController) {
        guard let navController = from.navigationController else {
            return
        }
        if navController.viewControllers.count == 1 {
            navController.viewControllers = [EmptyViewController(nibName: nil, bundle: nil)]
        } else {
            navController.popViewController(animated: true)
        }
    }

    open func dismiss(_ view: UIViewController, completion: (() -> Void)? = nil) {
        view.dismiss(animated: true, completion: completion)
    }

    public static func open(url: URLComponents) {
        var components = url
        // Canonicalize relative & schemes we know about.
        switch components.scheme {
        case "canvas-courses", "canvas-student", "canvas-teacher", "canvas-parent":
            components.scheme = "https"
        default:
            break
        }
        guard let url = components.url(relativeTo: AppEnvironment.shared.currentSession?.baseURL) else { return }

        // Handle tel:, mailto:, or anything else that isn't https:
        guard components.scheme?.hasPrefix("http") == true else {
            performUIUpdate {
                AppEnvironment.shared.loginDelegate?.openExternalURL(url)
            }
            return
        }

        // Start out logged in if the url does belong to canvas
        let request = GetWebSessionRequest(to: url)
        AppEnvironment.shared.api.makeRequest(request) { response, _, _ in
            performUIUpdate {
                AppEnvironment.shared.loginDelegate?.openExternalURL(response?.session_url ?? url)
            }
        }
    }
}
