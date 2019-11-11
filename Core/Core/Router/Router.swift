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

public struct RouteOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let modal = RouteOptions(rawValue: 1)
    public static let embedInNav = RouteOptions(rawValue: 2)
    public static let addDoneButton = RouteOptions(rawValue: 4)
    public static let formSheet = RouteOptions(rawValue: 8)
    public static let detail = RouteOptions(rawValue: 16)
}

public protocol RouterProtocol {
    func match(_ url: URLComponents) -> UIViewController?
    func route(to: Route, from: UIViewController, options: RouteOptions?)
    func route(to url: URL, from: UIViewController, options: RouteOptions?)
    func route(to url: String, from: UIViewController, options: RouteOptions?)
    func route(to url: URLComponents, from: UIViewController, options: RouteOptions?)
    func show(_ view: UIViewController, from: UIViewController, options: RouteOptions?, completion: (() -> Void)?)
}

public extension RouterProtocol {
    func route(to: Route, from: UIViewController, options: RouteOptions? = nil) {
        return route(to: to.url, from: from, options: options)
    }

    func route(to url: URL, from: UIViewController, options: RouteOptions? = nil) {
        return route(to: .parse(url), from: from, options: options)
    }

    func route(to url: String, from: UIViewController, options: RouteOptions? = nil) {
        return route(to: .parse(url), from: from, options: options)
    }

    func show(_ view: UIViewController, from: UIViewController, options: RouteOptions? = nil, completion: (() -> Void)? = nil) {
        if view is UIAlertController { return from.present(view, animated: true) }

        if let displayModeButton = from.displayModeButtonItem,
            from.splitViewController?.isCollapsed == false,
            options?.contains(.detail) == true || from.isInSplitViewDetail,
            options?.contains(.modal) != true {
            view.addNavigationButton(displayModeButton, side: .left)
            view.navigationItem.leftItemsSupplementBackButton = true
        }

        if options?.contains(.modal) == true {
            if options?.contains(.embedInNav) == true {
                if options?.contains(.addDoneButton) == true {
                    view.addDoneButton(side: .left)
                }
                let nav = view as? UINavigationController ?? UINavigationController(rootViewController: view)
                nav.navigationBar.useModalStyle()
                if options?.contains(.formSheet) == true {
                    nav.modalPresentationStyle = .formSheet
                }
                from.present(nav, animated: true, completion: completion)
            } else {
                if options?.contains(.formSheet) == true {
                    view.modalPresentationStyle = .formSheet
                }
                from.present(view, animated: true, completion: completion)
            }
        } else if options?.contains(.detail) == true && !from.isInSplitViewDetail {
            if options?.contains(.embedInNav) == true {
                from.showDetailViewController(UINavigationController(rootViewController: view), sender: from)
            } else {
                from.showDetailViewController(view, sender: from)
            }
        } else {
            from.show(view, sender: nil)
        }
    }
}

// The Router stores all routes that can be routed to in the app
public class Router: RouterProtocol {
    public typealias FallbackHandler = (URLComponents, UIViewController, RouteOptions?) -> Void

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
        url.query = url.query?.replacingOccurrences(of: "+", with: " ")
        return url
    }

    public func match(_ url: URLComponents) -> UIViewController? {
        let url = cleanURL(url)
        for route in handlers {
            if let params = route.match(url) {
                return route.factory(url, params)
            }
        }
        return nil
    }

    public func route(to url: URLComponents, from: UIViewController, options: RouteOptions? = nil) {
        let url = cleanURL(url)
        #if DEBUG
        DeveloperMenuViewController.recordRouteInHistory(url.url?.absoluteString)
        #endif
        for route in handlers {
            if let params = route.match(url) {
                if let view = route.factory(url, params) {
                    show(view, from: from, options: options)
                }
                return // don't fall back if a matched route returns no view
            }
        }
        fallback(url, from, options)
    }
}
