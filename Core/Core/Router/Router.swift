//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

// The Router stores all routes that can be routed to in the app
public class Router {
    public struct RouteOptions: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        static let modal = RouteOptions(rawValue: 1)
    }

    private let routes: [Route]

    public init(routes: [Route]) {
        self.routes = routes
    }

    public var count: Int {
        return routes.count
    }

    public func match(_ url: URLComponents) -> UIViewController? {
        for route in routes {
            if let view = route.match(url) {
                return view
            }
        }
        return nil
    }

    public func route(to url: String, from: UIViewController, options: RouteOptions? = nil) {
        return route(to: .parse(url), from: from, options: options)
    }

    public func route(to url: URL, from: UIViewController, options: RouteOptions? = nil) {
        return route(to: .parse(url), from: from, options: options)
    }

    public func route(to url: URLComponents, from: UIViewController, options: RouteOptions? = nil) {
        guard let view = match(url) else { return }

        from.show(view, sender: nil)
    }
}
