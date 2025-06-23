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

// A route is a place you can go in the app
// Each app defines it's own routes when creating the Router
public struct RouteHandler {
    public typealias ViewFactory = (URLComponents, [String: String], [String: Any]?, AppEnvironment) -> UIViewController?
    public typealias DiscardingEnvironmentViewFactory = (URLComponents, [String: String], [String: Any]?) -> UIViewController?

    public let route: Route
    public let factory: ViewFactory

    public init(_ template: String, factory: @escaping ViewFactory = { _, _, _, _ in nil }) {
        self.route = Route(template)
        self.factory = factory
    }

    /// This is to avoid large file changes on Routes.
    /// We need to remove this while migrating to a state where AppEnvironment instance
    /// is being passed to all view of routes entry points.
    public init(_ template: String, factory: @escaping DiscardingEnvironmentViewFactory) {
        self.init(template) { url, params, userInfo, _ in
            factory(url, params, userInfo)
        }
    }

    public func match(_ url: URLComponents) -> [String: String]? {
        route.match(url)
    }
}
