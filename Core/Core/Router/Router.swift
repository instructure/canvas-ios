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
        addDoneButton: Bool = false,
        animated: Bool = true
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
        case .detail, .modal(_, _, embedInNav: true, _, _):
            return true
        default:
            return false
        }
    }
}

#if DEBUG
extension RouteOptions: Codable {
    enum CodingKeys: String, CodingKey {
        case type, style, isDissmissable, embedInNav, addDoneButton, animated
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(String.self, forKey: .type) {
        case "push":
            self = .push
        case "detail":
            self = .detail
        default:
            self = try .modal(
                container.decodeIfPresent(Int.self, forKey: .style).flatMap { UIModalPresentationStyle(rawValue: $0) },
                isDismissable: container.decode(Bool.self, forKey: .isDissmissable),
                embedInNav: container.decode(Bool.self, forKey: .embedInNav),
                addDoneButton: container.decode(Bool.self, forKey: .addDoneButton),
                animated: container.decode(Bool.self, forKey: .animated)
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .push:
            try container.encode("push", forKey: .type)
        case .detail:
            try container.encode("push", forKey: .type)
        case .modal(let style, let isDismissable, let embedInNav, let addDoneButton, let animated):
            try container.encode("modal", forKey: .type)
            try container.encodeIfPresent(style?.rawValue, forKey: .style)
            try container.encode(isDismissable, forKey: .isDissmissable)
            try container.encode(embedInNav, forKey: .embedInNav)
            try container.encode(addDoneButton, forKey: .addDoneButton)
            try container.encode(animated, forKey: .animated)
        }
    }
}
#endif

// The Router stores all routes that can be routed to in the app
open class Router {
    public typealias FallbackHandler = (URLComponents, [String: Any]?, UIViewController, RouteOptions) -> Void
    public static let DefaultRouteOptions: RouteOptions = .push

    public var count: Int { handlers.count }

    private let handlers: [RouteHandler]
    private let fallback: FallbackHandler

    public init(routes: [RouteHandler], fallback: @escaping FallbackHandler = { url, _, _, _ in open(url: url) }) {
        self.handlers = routes
        self.fallback = fallback
    }

    // MARK: - Route Matching

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

    open func template(for url: URL) -> String? {
        template(for: .parse(url))
    }
    public func template(for url: String) -> String? {
        template(for: .parse(url))
    }
    public func template(for url: URLComponents) -> String? {
        handler(for: url)?.template
    }

    public func isRegisteredRoute(_ url: URL) -> Bool {
        isRegisteredRoute(.parse(url))
    }
    public func isRegisteredRoute(_ url: String) -> Bool {
        isRegisteredRoute(.parse(url))
    }
    public func isRegisteredRoute(_ url: URLComponents) -> Bool {
        handler(for: url) != nil
    }

    // MARK: - Routing

    public func route(to url: URL, userInfo: [String: Any]? = nil, from: UIViewController, options: RouteOptions = DefaultRouteOptions) {
        return route(to: .parse(url), userInfo: userInfo, from: from, options: options)
    }
    public func route(to url: String, userInfo: [String: Any]? = nil, from: UIViewController, options: RouteOptions = DefaultRouteOptions) {
        return route(to: .parse(url), userInfo: userInfo, from: from, options: options)
    }
    open func route(to url: URLComponents, userInfo: [String: Any]? = nil, from: UIViewController, options: RouteOptions = DefaultRouteOptions) {
        let url = cleanURL(url)

        if url.isExternalWebsite, !url.originIsNotification, let url = url.url {
            Analytics.shared.logScreenView(route: "/external_url")
            AppEnvironment.shared.loginDelegate?.openExternalURL(url)
            return
        }

        #if DEBUG
        DeveloperMenuViewController.recordRouteInHistory(url.url?.absoluteString)
        #endif

        for route in handlers {
            if let params = route.match(url) {
                var analyticsViewController: UIViewController?

                if let view = route.factory(url, params, userInfo) {
                    print(String(describing: type(of: view)), "ROUTER OPEN CONTROLLER")
                    analyticsViewController = view
                    show(view, from: from, options: options, analyticsRoute: nil)
                }

                Analytics.shared.logScreenView(route: route.template, viewController: analyticsViewController)
                return // don't fall back if a matched route returns no view
            }
        }
        fallback(url, userInfo, from, options)
    }

    // MARK: - View Controller Presentation

    /**
     - parameters:
        - analyticsRoute: The route to be reported as screen\_view analytics event. If nil, no route is reported but this is only for internal usage to avoid both the `route` and `show` functions reporting the same event.
     */
    open func show(_ view: UIViewController, from: UIViewController, options: RouteOptions = DefaultRouteOptions, analyticsRoute: String? = "/unknown", completion: (() -> Void)? = nil) {
        if view is UIAlertController { return from.present(view, animated: true, completion: completion) }

        if let analyticsRoute = analyticsRoute {
            Analytics.shared.logScreenView(route: analyticsRoute, viewController: view)
        }

        if let displayModeButton = from.splitDisplayModeButtonItem,
            from.splitViewController?.isCollapsed == false,
            options.isDetail || from.isInSplitViewDetail,
            !options.isModal {
            view.addNavigationButton(displayModeButton, side: .left)
            view.navigationItem.leftItemsSupplementBackButton = true
        }

        var nav: UINavigationController?
        if options.embedInNav {
            nav = view as? UINavigationController ?? HelmNavigationController(rootViewController: view)
        }

        switch options {
        case let .modal(style, isDismissable, _, addDoneButton, animated):
            if addDoneButton {
                view.addDoneButton(side: .left)
            }
            nav?.navigationBar.useModalStyle()
            if let presentationStyle = style {
                (nav ?? view).modalPresentationStyle = presentationStyle
            }
            if !isDismissable {
                (nav ?? view).isModalInPresentation = true
            }
            from.present(nav ?? view, animated: animated, completion: completion)
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
        if view.presentingViewController != nil {
            view.dismiss(animated: true, completion: completion)
        } else {
            pop(from: view)
            completion?()
        }
    }

    // MARK: - External URL

    public static func open(url: URLComponents) {
        Analytics.shared.logScreenView(route: "/external_url")

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
        guard url.scheme?.hasPrefix("http") == true else {
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

    // MARK: - Private Methods

    private func cleanURL(_ url: URLComponents) -> URLComponents {
        // URLComponents does all the encoding we care about except we often have + meaning space in query
        var url = url
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%20")
        return url
    }

    private func handler(for url: URLComponents) -> RouteHandler? {
        let url = cleanURL(url)
        return handlers.first { $0.match(url) != nil }
    }
}
