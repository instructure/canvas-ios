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

public protocol RouterProtocol {
    func route(to: Route, from: UIViewController, options: Router.RouteOptions?)
    func route(to url: URL, from: UIViewController, options: Router.RouteOptions?)
    func route(to url: String, from: UIViewController, options: Router.RouteOptions?)
    func route(to url: URLComponents, from: UIViewController, options: Router.RouteOptions?)
    func route(to view: UIViewController, from: UIViewController, options: Router.RouteOptions?)
}

public extension RouterProtocol {
    func route(to: Route, from: UIViewController, options: Router.RouteOptions? = nil) {
        return route(to: to.url, from: from, options: options)
    }

    func route(to url: URL, from: UIViewController, options: Router.RouteOptions? = nil) {
        return route(to: .parse(url), from: from, options: options)
    }

    func route(to url: String, from: UIViewController, options: Router.RouteOptions? = nil) {
        return route(to: .parse(url), from: from, options: options)
    }

    func route(to view: UIViewController, from: UIViewController, options: Router.RouteOptions? = nil) {
        if options?.contains(.modal) == true {
            if options?.contains(.embedInNav) == true {
                if options?.contains(.addDoneButton) == true {
                    view.addDoneButton()
                }
                let nav = view as? UINavigationController ?? UINavigationController(rootViewController: view)
                from.present(nav, animated: true, completion: nil)
            } else {
                from.present(view, animated: true, completion: nil)
            }
        } else {
            from.show(view, sender: nil)
        }
    }
}

// The Router stores all routes that can be routed to in the app
public class Router: RouterProtocol {
    public struct RouteOptions: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let modal = RouteOptions(rawValue: 1)
        public static let embedInNav = RouteOptions(rawValue: 2)
        public static let addDoneButton = RouteOptions(rawValue: 4)
    }

    private let handlers: [RouteHandler]

    public init(routes: [RouteHandler]) {
        self.handlers = routes
    }

    public var count: Int {
        return handlers.count
    }

    public func match(_ url: URLComponents) -> UIViewController? {
        for route in handlers {
            if let view = route.match(url) {
                return view
            }
        }
        return nil
    }

    public func route(to url: URLComponents, from: UIViewController, options: RouteOptions? = nil) {
        guard let view = match(url) else { return }
        route(to: view, from: from, options: options)
    }
}
